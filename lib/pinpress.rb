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

  # Determines whether an invalid combination of linking options
  # (auto and manual, via either a switch or a config parameter)
  # has been given.
  # @param [Hash] opts
  # @return [Bool]
  def conflicting_link_opts?(opts)
    auto_link_flag = opts[:a]
    auto_link_conf = configuration.pinpress.auto_link
    manual_link_flag = opts[:l]
    manual_link_conf = configuration.pinpress.manual_link
    ((auto_link_conf && manual_link_conf) || (auto_link_flag && manual_link_flag))
  end

  # Determines which URL linking options to set. There are some
  # basic rules:
  #    1. You can't specify both switches or both config options simultaneously.
  #    2. Switches will take priority.
  #    3. Config options are a last resort
  # @param [Hash] opts_hash
  # @return [Hash]
  def determine_link_opts(opts_hash)
    opts = {}
    if opts_hash[:a_switch] || opts_hash[:m_switch]
      opts.merge!(auto_link: true) if opts_hash[:a_switch]
      opts.merge!(link: true) if opts_hash[:m_switch]
    else
      opts.merge!(auto_link: true) if opts_hash[:a_config]
      opts.merge!(link: true) if opts_hash[:m_config]
    end
    opts
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
      configuration.pin_templates.find { |t| t.keys[0] == template_name.to_sym}.values[0]
    when PinPress::Template::TYPE_TAG
      configuration.tag_templates.find { |t| t.keys[0] == template_name.to_sym}.values[0]
    end
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

    if explicit_template && PinPress.is_template?(explicit_template, template_type)
      messenger.debug("Using explicit template: #{ explicit_template }")
      return explicit_template, PinPress.get_template(explicit_template, template_type)
    elsif PinPress.is_template?(default_template, template_type)
      messenger.debug("Using default template: #{ default_template }")
      return default_template, PinPress.get_template(default_template, template_type)
    else
      fail 'Invalid template specified and/or no default template defined'
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
      configuration.add_section(:links)
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
    !templates.find { |t| t.keys[0] == template_name.to_sym }.nil?
  end

  def link_urls_in_desc(name, description, method)
    fail "Unknown link creation methdo: #{ method.to_s }" unless [:AUTO, :MANUAL].include? method
    urls = URI.extract(description, ['http', 'https'])
    urls.each do |u|
      link_text = nil
      pin_id = Digest::MD5.hexdigest(description + u)

      # I don't get why, but URL.extract is loose enough to include
      # weird characters. This is my evolving regex to handle those.
      u.sub!(/[()\.]+$/, '')

      if configuration.links.send(pin_id)
        # First, check the configuration file to see if we've stored
        # this URL before (so that we can grab the saved value).
        link_text = configuration.links.send(pin_id).link_text
      else
        if method == :AUTO
          # If the configuration file doesn't have an entry for this
          # link, no worries; create one.
          link_text = u
        elsif method == :MANUAL
          # If the configuration file doesn't have an entry for this
          # link, no worries; create one.
          CLIUtils::PrettyIO.wrap = false
          messenger.section('URL FOUND!')
          messenger.info("URL:\t\t#{ u }")
          messenger.info("TITLE:\t#{ name }")
          messenger.info("POSITION:\t..." + description.scan(/.{0,40}#{ u }.{0,40}/)[0] + '...')
          until !link_text.nil?
            link_text = messenger.prompt('What do you want the link text to say?')
            messenger.warn('Please provide some link text.') if link_text.nil?
          end
          CLIUtils::PrettyIO.wrap = true
        end

        # Store this newly created link info back in the configuration
        # file.
        configuration.links.merge!(pin_id => {
          title: name,
          url: u,
          link_text: link_text
        })
      end
      description.sub!(u, "<a href=\"#{ u }\" target=\"_blank\">#{ link_text }</a>")
    end
    description
  end

  # Present a list of installed templates to the user
  # @return [void]
  def list_templates
    %w(pin tag).each do |type|
      templates = configuration.send("#{ type }_templates")
      messenger.section("AVAILABLE #{ type.upcase } TEMPLATES:")
      if templates
        templates.each_with_index do |template, index|
          template_name, template = template.first
          puts "#{ index + 1 }.\tName:   ".blue + "#{ template_name }"
          puts "Opener:".blue.rjust(22) + "\t#{ template[:opener] }".truncate(80)
          puts "Item:".blue.rjust(22) + "\t#{ template[:item] }".truncate(80)
          puts "Closer:".blue.rjust(22) + "\t#{ template[:closer] }".truncate(80)
        end
      else
        messenger.warn('No templates defined...')
      end
    end
  end

  # Helper method to merge command line options that are relevant for both pin
  # and tag requests.
  # @param [Hash] options
  # @raise StandardError if an invalid combo of linking options is given
  # @return [Hash]
  def merge_common_options(options, template_name, template_type)
    case template_type
    when PinPress::Template::TYPE_PIN
      section = configuration.pin_templates.find { |t| t.keys[0] == template_name.to_sym}.values[0]
    when PinPress::Template::TYPE_TAG
      section = configuration.tag_templates.find { |t| t.keys[0] == template_name.to_sym}.values[0]
    end

    opts = {}
    if options[:n]
      opts.merge!(results: options[:n])
    elsif section.default_num_results
      opts.merge!(results: section.default_num_results)
    end

    if options[:t]
      opts.merge!(tag: options[:t])
    elsif section.default_tags
      opts.merge!(tag: section.default_tags.join(','))
    end

    # These options are PinPress-related, not necessarily Pinboard-related;
    # for the sake of convenience, they're included here.

    # Auto-linking and prompting for link text don't go together, so make
    # sure to let the user know if they include both.
    if conflicting_link_opts?(options)
      fail "You can't specify (a) both the `-a` and `-l` switches or " \
        "(b) both the `auto_link` and `manual_link` configuration options."
    else
      link_opts = determine_link_opts({
        a_switch: options[:a],
        m_switch: options[:l],
        a_config: configuration.pinpress.auto_link,
        m_config: configuration.pinpress.manual_link
      })
      opts.merge!(link_opts) if link_opts
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
      output += template[:opener] if template[:opener]
      data.each do |i|
        name = HTMLEntities.new.encode(i[:description])

        if opts[:link]
          desc = link_urls_in_desc(name, i[:extended], :MANUAL)
        elsif opts[:auto_link]
          desc = link_urls_in_desc(name, i[:extended], :AUTO)
        else
          desc = i[:extended]
        end

        href        = i[:href]
        description = name
        extended    = desc
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
      data.each { |i| tags += i[:tag] }
      tags = tags.uniq.map do |t|
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
