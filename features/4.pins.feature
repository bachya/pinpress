@active
Feature: Data
  As a user, I should be able get pins and tags
  from Pinboard and output them based on templates.

  Scenario: Invalid API Key
    Given an existing current configuration file located at "/tmp/pp/.pinpress"
    When I make the Pinboard request `pinpress pins`
    Then the exit status should be 0