require 'simplecov'
require 'aruba/cucumber'
require 'cucumber/rspec/doubles'

ENV['PATH'] = "#{File.expand_path(File.dirname(__FILE__) + '/../../bin')}#{File::PATH_SEPARATOR}#{ENV['PATH']}"
LIB_DIR = File.join(File.expand_path(File.dirname(__FILE__)),'..','..','lib')

Before do
  # Using "announce" causes massive warnings on 1.9.2
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
