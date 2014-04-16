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
