require 'pinpress/constants'
require 'pinpress/template'

# The PinPress module, which wraps everything
# in this gem.
module PinPress
  extend self

  class << self
    # Stores whether initalization has completed.
    # @return [Boolean]
    attr_reader :initialized

    # Stores whether verbose output is turned on.
    # @return [Boolean]
    attr_accessor :verbose
  end

  # Grabs Pinboard data (passed on passed options) and yields a block that
  # allows the user to act upon that returned data.
  # @param [Hash] pinboard_opts
  # @yield pins
  # @raise StandardError if Pinboard client fails
  def execute_template(pinboard_opts)
    begin
      client = Pinboard::Client.new(token: configuration.pinpress.api_token)
      pins = client.posts(pinboard_opts)
      if pins.empty?
        messenger.warn('No data matching your arguments...')
      else
        yield pins
      end
    rescue StandardError => e
      messenger.debug(e.to_s)
      puts e.to_s
      raise "Pinboard API failed; are you sure you've run " \
           " `pinpress init` (and that your API key is correct)?"
    end
  end

  # Returns a template Hash from the configuration file.
  # @param [String] template_name The name of the template to get
  # @param [Fixnum] template_type The template type
  # @return [Hash]
  def get_template(template_name, template_type)
    case template_type
    when PinPress::Template::TYPE_PIN
      templates = configuration.pin_templates
    when PinPress::Template::TYPE_TAG
      templates = configuration.tag_templates
    end
    templates.find { |t| t[:name] == template_name }
  end

  # "Initializes" a passed template:
  #    1. If the template exists, returns it.
  #    2. If not, return a default template (if it exists).
  #    3. Throw an exception if #1 and #2 fail.
  # @param [String] explicit_template A template name passed in via the CLI
  # @param [Fixnum] template_type The template type
  # @return [Hash]
  # @raise StandardError if no explicit or default template is found
  def init_template(explicit_template, template_type)
    pin_t_sym = :default_pin_template
    tag_t_sym = :default_tag_template
    s = (template_type == PinPress::Template::TYPE_PIN ? pin_t_sym : tag_t_sym)
    default_template = configuration.pinpress[s]
    if PinPress.is_template?(explicit_template, template_type)
      messenger.debug("Using explicit template: #{ explicit_template }")
      return PinPress.get_template(explicit_template, template_type)
    elsif PinPress.is_template?(default_template, template_type)
      messenger.debug("Using default template: #{ default_template }")
      return PinPress.get_template(default_template, template_type)
    else
      fail 'Invalid template defined and/or no default template specified'
    end
  end

  # Initializes PinPress by downloading and
  # collecting all necessary items and info.
  # @param [Boolean] from_scratch
  # @return [void]
  def init(from_scratch = false)
    messenger.section('INITIALIZING...')
    if from_scratch
      configuration.reset

      # Add initial configuration info.
      configuration.add_section(:pinpress)
      configuration.pinpress = {
        config_location: configuration.config_path,
        default_pin_template: 'pinpress_default',
        default_tag_template: 'pinpress_default',
        log_level: 'WARN',
        version: PinPress::VERSION
      }

      # Add a single default pin and tag template
      default_pin_template = {
        name: 'pinpress_default',
        opener: '<ul>',
        item: '<li><%= href %></li>',
        closer: '</ul>'
      }
      default_tag_template = {
        name: 'pinpress_default',
        item: '<%= tag %> (<%= count %>),'
      }
      configuration.pin_templates = [default_pin_template]
      configuration.tag_templates = [default_tag_template]
    end

    # Run through installation prompts and ingest the results into
    # the configuration.
    pm = CLIUtils::Prefs.new(PinPress::PREF_FILES['INIT'], configuration)
    pm.ask
    configuration.ingest_prefs(pm)

    m = "Configuration values after pref collection: #{ configuration.data }"
    messenger.debug(m)
    configuration.save
    @initialized = true
  end

  # Determines whether a template exists in the configuration file.
  # @param [String] template_name The name of the template to search for
  # @param [Fixnum] template_type The template type
  def is_template?(template_name, template_type)
    case template_type
    when PinPress::Template::TYPE_PIN
      templates = configuration.pin_templates
    when PinPress::Template::TYPE_TAG
      templates = configuration.tag_templates
    end
    !templates.find { |t| t[:name] == template_name }.nil?
  end

  # Present a list of installed templates to the user
  # @return [void]
  def list_templates
    pin_templates = configuration.pin_templates
    tag_templates = configuration.tag_templates

    messenger.section('AVAILABLE PIN TEMPLATES:')
    if pin_templates
      pin_templates.each_with_index do |template, index|
        puts "#{ index + 1 }.\tName:   ".blue + "#{ template[:name] }"
        puts "Opener:".blue.rjust(22) + "\t#{ template[:opener] }".truncate(80)
        puts "Item:".blue.rjust(22) + "\t#{ template[:item] }".truncate(80)
        puts "Closer:".blue.rjust(22) + "\t#{ template[:closer] }".truncate(80)
      end
    else
      messenger.warn('No templates defined...')
    end

    messenger.section('AVAILABLE TAG TEMPLATES:')
    if tag_templates
      tag_templates.each_with_index do |template, index|
        puts "#{ index + 1 }.\tName:   ".blue + "#{ template[:name] }"
        puts "Opener:".blue.rjust(22) + "\t#{ template[:opener] }".truncate(80)
        puts "Item:".blue.rjust(22) + "\t#{ template[:item] }".truncate(80)
        puts "Closer:".blue.rjust(22) + "\t#{ template[:closer] }".truncate(80)
      end
    else
      messenger.warn('No templates defined...')
    end
  end

  # Helper method to merge command line options that are relevant for both pin
  # and tag requests.
  # @param [Hash] options
  # @return [Hash]
  def merge_common_options(options)
    opts = {}
    if options[:n]
      opts.merge!(results: options[:n])
    elsif configuration.pinpress.default_num_results
      opts.merge!(results: configuration.pinpress.default_num_results)
    end

    if options[:t]
      opts.merge!(tag: options[:t])
    elsif configuration.pinpress.default_tags
      opts.merge!(tag: configuration.pinpress.default_tags.join(','))
    end
    opts
  end

  # Creates text output from pin data (based upon a passed template).
  # @param [Hash] template The template to use
  # @param [Hash] opts CLI options to use
  # @return [String]
  def pin_yield(template, opts)
    output = ''
    PinPress.execute_template(opts) do |data|
      html_coder = HTMLEntities.new

      output += template[:opener] if template[:opener]
      data.each do |i|
        href        = i[:href]
        description = html_coder.encode(i[:description])
        extended    = i[:extended]
        tag         = i[:tag]
        time        = i[:time]
        replace     = i[:replace]
        shared      = i[:shared]
        toread      = i[:toread]
        output += ERB.new(template[:item]).result(binding)
      end
      output += template[:closer] if template[:closer]
    end
    output
  end

  # Creates text output from tag data (based upon a passed template).
  # @param [Hash] template The template to use
  # @param [Hash] opts CLI options to use
  # @return [String]
  def tag_yield(template, opts)
    output = ''
    PinPress.execute_template(opts) do |data|
      tags = []
      ignored_tags = configuration.pinpress.ignored_tags

      data.each { |i| tags += i[:tag] }
      tags = (tags -= ignored_tags if ignored_tags).uniq.map do |t|
        { tag: t, count: tags.count(t) }
      end

      output += template[:opener] if template[:opener]
      tags.each do |t|
        unless t[:tag] == opts[:tag]
          tag   = t[:tag]
          count = t[:count]
          output += ERB.new(template.item).result(binding)
        end
      end
      output += template[:closer] if template[:closer]
    end
    output
  end

  # Notifies the user that the config file needs to be
  # re-done and does it.
  # @return [void]
  def update_config_file
    m = "This version needs to make some config changes. Don't worry; " \
        "when prompted, your current values for existing config options " \
        "will be presented (so it'll be easier to fly through the upgrade)."
    messenger.info(m)
    messenger.prompt('Press enter to continue')
    PinPress.init(true)
  end
end
