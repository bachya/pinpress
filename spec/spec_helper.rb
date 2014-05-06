# require 'coveralls'
require 'rspec'
require 'simplecov'
require 'stringio'

SimpleCov.start
# Coveralls.wear!

def capture_stdout
  old = $stdout
  $stdout = fake = StringIO.new
  yield
  fake.string
ensure
  $stdout = old
end
