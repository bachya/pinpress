require 'vcr'

VCR.configure do |c|
  c.cassette_library_dir = 'features/vcr_cassettes'
  c.hook_into :webmock
end