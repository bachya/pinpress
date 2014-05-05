require 'pinpress/constants'
require 'pinpress/templates/template'
require 'pinpress/templates/pin_template'
require 'pinpress/templates/tag_template'

# The PinPress module, which wraps everything
# in this gem.
module PinPress
  class << self
    # Stores whether initalization has completed.
    # @return [Boolean]
    attr_reader :initialized

    # Stores whether verbose output is turned on.
    # @return [Boolean]
    attr_accessor :verbose
  end

  # Establishes the template to use and yields a block with that
  # template an a Pinboard client.
  # @param [Fixnum] template_type Either a Pin or Tag template
  # @param [String] template_name The neame of the template to use
  # @yield
  # @return [void]
  def self.execute_template(template_type, template_name)
    template_hash = PinPress.get_template_by_name(template_type, template_name)
    if template_hash
      template = PinPress::TagTemplate.new(template_hash)
      client = Pinboard::Client.new(token: configuration.pinpress[:api_token])
      yield template, client
    else
      fail 'Invalid template provided and/or no default template'
    end
  end

  # Generates a string of items from pins.
  # @param [Fixnum] template_type
  # @param [PinPress::Template] template
  # @param [Array] pins
  # @return [String]
  def self.generate_items(template_type, template, pins, opts)
    output = ''
    case template_type
    when PinPress::Template::TEMPLATE_TYPE_PIN
      pins.each do |p|
        href        = p[:href]
        description = p[:description]
        extended    = p[:extended]
        tag         = p[:tag]
        time        = p[:time]
        replace     = p[:replace]
        shared      = p[:shared]
        toread      = p[:toread]
        output += ERB.new(template.item).result(binding)
      end
      configuration.pinpress[:last_pins_run] = Date.today
    when PinPress::Template::TEMPLATE_TYPE_TAG
      tags = []
      pins.each { |p| tags += p[:tag] }
      tags = tags.uniq.map { |t| { tag: t, count: tags.count(t) } }
      tags.each do |t|
        unless t[:tag] == opts[:tag]
          tag   = t[:tag]
          count = t[:count]
          output += ERB.new(template.item).result(binding)
        end
      end
      configuration.pinpress[:last_tags_run] = Date.today
    end
    output
  end

  # Generic function to get data from Pinboard.
  # @param [Fixnum] template_type
  # @param [Array] args
  # @param [Hash] options
  # @return [String]
  def self.get_data(template_type, args, options)
    output = ''

    # Two scenarios covered here:
    #   1. If the user passes a valid name, grab that template.
    #   2. If no name is passed, grabbed the default template
    # If both of these conditions fail, an error message is shown.
    # t_type = PinPress::Template::TEMPLATE_TYPE_PIN
    # t_name = args.empty? ? nil : args[0]
    t_name = args.empty? ? nil : args[0]

    PinPress.execute_template(template_type, t_name) do |template, client|
      opts = {}
      opts.merge!(todt: Chronic.parse(options[:e])) if options[:e]
      opts.merge!(fromdt: Chronic.parse(options[:s])) if options[:s]

      if options[:n]
        opts.merge!(results: options[:n])
      elsif configuration.pinpress[:default_num_results]
        opts.merge!(results: configuration.pinpress[:default_num_results])
      end

      if options[:t]
        tags = options[:t].split(',')
      elsif configuration.pinpress[:default_tags]
        tags = configuration.pinpress[:default_tags]
      end

      ignored_tags = configuration.pinpress[:ignored_tags]
      tags -= ignored_tags if ignored_tags
      opts.merge!(tag: tags) if tags

      begin
        pins = client.posts(opts)
        if pins.empty?
          messenger.warn('No matching pins...')
        else
          output += template.opener if template.opener
          output += PinPress.generate_items(template_type, template, pins, opts)
          output += template.closer if template.closer
        end

        configuration.save
        return output
      rescue StandardError => e
        messenger.debug(e.to_s)
        raise "Pinboard API failed; are you sure you've run " \
             " `pinpress init` (and that your API key is correct)?"
      end
    end
  end

  # Determines whether a template exists.
  # @param [Fixnum] template_type
  # @param [<String, Symbol>] template_name
  # @return [Template]
  def self.get_template_by_name(template_type, template_name = nil)
    case template_type
    when Template::TEMPLATE_TYPE_PIN
      default_t_name = configuration.pinpress[:default_pin_template]
      templates = configuration.pin_templates
    when Template::TEMPLATE_TYPE_TAG
      default_t_name = configuration.pinpress[:default_tag_template]
      templates = configuration.tag_templates
    else
      fail 'Invalid template type given'
    end

    if template_name.nil?
      return templates.find { |t| t[:name] == default_t_name }
    else
      return templates.find { |t| t[:name] == template_name }
    end
  end

  # Initializes PinPress by downloading and
  # collecting all necessary items and info.
  # @param [Boolean] from_scratch
  # @return [void]
  def self.init(from_scratch = false)
    messenger.section('INITIALIZING...')
    if from_scratch
      configuration.reset
      configuration.add_section(:pinpress)
      configuration.add_section(:pin_templates)
      configuration.add_section(:tag_templates)

      configuration.pinpress.merge!(
        config_location: configuration.config_path,
        default_pin_template: 'pinpress_default',
        default_tag_template: 'pinpress_default',
        log_level: 'WARN',
        version: PinPress::VERSION
      )

      default_pin_template = {
        name: 'pinpress_default',
        opener: '<ul>',
        item: '<li><b><a title="<%= description %>" href="<%= href %>" target="_blank"><%= description %></a>.</b> <%= extended %></li>',
        closer: '</ul>'
      }

      default_tag_template = {
        name: 'pinpress_default',
        item: '<%= tag %> (<%= count %>),'
      }

      configuration.data['pin_templates'] = [default_pin_template]
      configuration.data['tag_templates'] = [default_tag_template]
    end

    pm = CLIUtils::Prefs.new(PinPress::PREF_FILES['INIT'], configuration)
    pm.ask
    configuration.ingest_prefs(pm)

    messenger.debug("Configuration values after pref collection: #{ configuration.data }")

    configuration.save
    @initialized = true
  end

  # Present a list of installed templates to the user
  # @return [void]
  def self.list_templates
    pin_templates = configuration.pin_templates
    tag_templates = configuration.tag_templates

    messenger.section('AVAILABLE PIN TEMPLATES:')
    if pin_templates
      pin_templates.each_with_index do |template, index|
        messenger.info("#{ index + 1 }. #{ template[:name] }")
      end
    else
      messenger.warn('No templates defined...')
    end

    messenger.section('AVAILABLE TAG TEMPLATES:')
    if tag_templates
      tag_templates.each_with_index do |template, index|
        messenger.info("#{ index + 1 }. #{ template[:name] }")
      end
    else
      messenger.warn('No templates defined...')
    end
  end

  # Notifies the user that the config file needs to be
  # re-done and does it.
  # @return [void]
  def self.update_config_file
    m = "This version needs to make some config changes. Don't worry; " \
        "when prompted, your current values for existing config options " \
        "will be presented (so it'll be easier to fly through the upgrade)."
    messenger.info(m)
    messenger.prompt('Press enter to continue')
    PinPress.init(true)
  end
end
