# The PinPress module, which wraps everything
# in this gem.
module PinPress
  # The default local filepath of the Siftter Redux config file
  CONFIG_FILEPATH = File.join(ENV['HOME'], '.pinpress')

  # The default local filepath of the Siftter Redux log file
  LOG_FILEPATH = File.join(ENV['HOME'], '.pinpress_log')

  # The Gem's description
  DESCRIPTION = %q(A Pinboard application that allows for the creation of
                  pin and tag templates in almost any conceivable format.)

  # The last version to require a config update
  NEWEST_CONFIG_VERSION = '1.2.1'

  # Hash of preference files
  PREF_FILES = {
    'INIT' => File.join(
      File.dirname(__FILE__),
      '..',
      '..',
      'support/preference_prompts.yaml'
    )
  }

  # The Gem's summary
  SUMMARY = 'A simple CLI to create HTML templates of Pinboard data.'

  # The Gem's version
  VERSION = '1.5.2'
end
