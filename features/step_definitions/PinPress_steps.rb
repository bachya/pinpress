When /^I get help for "([^"]*)"$/ do |app_name|
  @app_name = app_name
  step %(I run `#{app_name} help`)
end

Given(/^no file located at "(.*?)"$/) do |filepath|
  step %(the file "#{ filepath }" should not exist)
end
