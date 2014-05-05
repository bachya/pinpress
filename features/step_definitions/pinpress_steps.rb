def create_config_file(version)
  config = YAML.load_file(File.join(LIB_DIR, '..', 'support/sample_config.yaml'))
  config['pinpress'].merge!('version' => version)
  File.open('/tmp/pp/.pinpress', 'w') { |f| f.write(config.to_yaml) }
end

Given(/^no file located at "(.*?)"$/) do |filepath|
  step %(the file "#{ filepath }" should not exist)
end

Given(/^an existing current configuration file located at "(.*?)"$/) do |filepath|
  create_config_file(PinPress::VERSION)
end

Given(/^an existing old configuration file located at "(.*?)"$/) do |filepath|
  create_config_file('0.0.1')
end

When /^I get help for "([^"]*)"$/ do |app_name|
  @app_name = app_name
  step %(I run `#{app_name} help`)
end

Then(/^the following files should not be empty:$/) do |table|
  table.cell_matrix.flatten.each do |file|
    expect(File.file?(file.value)).to eq(true)
    expect(File.read(file.value)).not_to be_empty
  end
end

Then(/^a valid configuration file should exist at "(.*?)"$/) do |filepath|
  expect(File.file?(filepath)).to eq(true)
  stub_data = YAML.load_file(File.join(LIB_DIR, '..', 'support/sample_config.yaml'))
  config_data = YAML.load_file(filepath)
  config_data['pinpress'].delete('version')
  expect(config_data).to eq(stub_data)
end
