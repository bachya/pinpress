require 'pinpress/constants'

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

  # Presents the user with a list of templates and
  # allows them to choose one.
  # @return [void]
  def self.choose_template
    templates = configuration.templates
    if !templates.nil?
      messenger.section('CHOOSE A DEFAULT TEMPLATE')
      messenger.success("Current Default Template: #{ configuration.pinpress[:default_template] }")
      messenger.info("Choose a New Template:")
      templates.each_with_index do |template, index|
        messenger.info("#{ index + 1}. #{ template[:name] }")
      end

      # Loop through the possible template choices and collect the user's
      # input. If a valid choice is made, set the default; otherwise,
      # force the user to pick.
      valid_choice_made = false
      until valid_choice_made
        choice = messenger.prompt("Choose from the list above")
        array_index = choice.to_i - 1

        if array_index >= 0 && !templates[array_index].nil?
          default_template_name = templates[array_index][:name]
          configuration.pinpress[:default_template] = default_template_name
          configuration.save

          messenger.success("New default template chosen: #{ default_template_name }")
          valid_choice_made = true
        else
          messenger.error("Invalid choice: #{ choice }")
        end
      end
    else
      messenger.warn('No templates defined...')
    end
  end

  # Initializes PinPress by downloading and
  # collecting all necessary items and info.
  # @param [Boolean] from_scratch
  # @return [void]
  def self.init(from_scratch = false)
    messenger.section_block('INITIALIZING') {
      if from_scratch
        configuration.reset
        configuration.add_section(:pinpress)
      end

      configuration.pinpress.merge!({
        config_location: configuration.config_path,
        log_level: 'WARN',
        version: PinPress::VERSION,
      })

      pm = CLIUtils::Prefs.new(PinPress::PREF_FILES['INIT'], configuration)
      pm.ask
      configuration.ingest_prefs(pm)

      messenger.debug { "Configuration values after pref collection: #{ configuration.data }" }
      configuration.save
      @initialized = true
    }
  end

  def self.list_templates
    templates = configuration.templates
    if !templates.nil?
      messenger.section('AVAILABLE TEMPLATES')
      templates.each_with_index do |template, index|
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
