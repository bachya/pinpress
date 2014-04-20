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

  def self.execute_template(template_type, template_name)
    template_hash = PinPress.get_template_by_name(template_type, template_name)
    if !template_hash.nil?
      template = PinPress::TagTemplate.new(template_hash)
      client = Pinboard::Client.new(token: configuration.pinpress[:api_token])
      yield template, client
    else
      fail 'Invalid template provided and/or no default template'
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
        item: '<li><b><a title="<%= description %>" href="<%= href %>" target="_blank"><%= description %></a>.</b><%= extended %></li>',
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

    messenger.debug {
      "Configuration values after pref collection: #{ configuration.data }"
    }
    configuration.save
    @initialized = true
  end

  # Present a list of installed templates to the user
  # @return [void]
  def self.list_templates
    pin_templates = configuration.pin_templates
    tag_templates = configuration.tag_templates

    messenger.section('AVAILABLE PIN TEMPLATES:')
    if !pin_templates.nil?
      pin_templates.each_with_index do |template, index|
        messenger.info("#{ index + 1 }. #{ template[:name] }")
      end
    else
      messenger.warn('No templates defined...')
    end

    messenger.section('AVAILABLE TAG TEMPLATES:')
    if !tag_templates.nil?
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
