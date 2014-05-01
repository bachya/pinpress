require 'simplecov'
require 'aruba/cucumber'
require 'aruba/in_process'
require 'pinpress/runner'
require 'vcr'
require_relative '../../lib/pinpress/constants'

ENV['PATH'] = "#{File.expand_path(File.dirname(__FILE__) + '/../../bin')}#{File::PATH_SEPARATOR}#{ENV['PATH']}"
LIB_DIR = File.join(File.expand_path(File.dirname(__FILE__)),'..','..','lib')

VCR.configure do |c|
  c.cassette_library_dir = 'features/cassettes'
  c.hook_into :webmock
  c.ignore_localhost = true
end

VCR.cucumber_tags do |t|
  t.tag '@vcr', use_scenario_name: true
end

Aruba::InProcess.main_class = PinPress::Runner
Aruba.process = Aruba::InProcess

Before do
  @puts = true
  @original_rubylib = ENV['RUBYLIB']
  ENV['RUBYLIB'] = LIB_DIR + File::PATH_SEPARATOR + ENV['RUBYLIB'].to_s
  @original_home = ENV['HOME']
  ENV['HOME'] = "/tmp/pp"
  FileUtils.rm_rf "/tmp/pp"
  FileUtils.mkdir "/tmp/pp"
end

After do
  ENV['RUBYLIB'] = @original_rubylib
  ENV['HOME'] = @original_home
end
