require 'spec_helper'
require 'cliutils'
require 'pinpress'

describe PinPress do
  it 'lists templates found in the configuration file' do
    configuration = double(CLIUtils::Configurator)
    p configuration
    PinPress.list_templates
  end
end
