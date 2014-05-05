require 'aruba/cucumber'
require_relative '../../lib/pinpress/constants'

ENV['PATH'] = "#{File.expand_path(File.dirname(__FILE__) + '/../../bin')}#{File::PATH_SEPARATOR}#{ENV['PATH']}"
LIB_DIR = File.join(File.expand_path(File.dirname(__FILE__)),'..','..','lib')

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
