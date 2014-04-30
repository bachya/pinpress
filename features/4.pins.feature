@active
Feature: Templates
  As a user, I should be able get pins from Pinboard
  and have them inherit certain templates.

  Scenario: Invalid API Key
    Given an existing current configuration file located at "/tmp/pp/.pinpress"
    When I run `pinpress pins` interactively
    Then the exit status should be 0