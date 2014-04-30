# @active
Feature: Initialization
  As a user, when I initialize PinPress,
  I should be guided through the process as
  necessary.

  Scenario: Basic Initialization
    Given no file located at "/tmp/pp/.pinpress"
    When I run `pinpress init` interactively
      And I type ""
      And I type "bachya:12345"
    Then the exit status should be 0
      And a valid configuration file should exist at "/tmp/pp/.pinpress"

  Scenario: Reinitialization (refuse)
    Given an existing current configuration file located at "/tmp/pp/.pinpress"
    When I run `pinpress init` interactively
      And I type ""
    Then the exit status should be 0

  Scenario: Reinitialization (accept)
    Given an existing current configuration file located at "/tmp/pp/.pinpress"
    When I run `pinpress init` interactively
      And I type "y"
      And I type ""
      And I type "bachya:12345"
    Then the exit status should be 0
      And a valid configuration file should exist at "/tmp/pp/.pinpress"

  Scenario: Reinitialization (accept)
    Given an existing current configuration file located at "/tmp/pp/.pinpress"
    When I run `pinpress init -s` interactively
      And I type ""
      And I type "bachya:12345"
    Then the exit status should be 0
      And a valid configuration file should exist at "/tmp/pp/.pinpress"

  Scenario: Update out-of-date configuration file
    Given an existing old configuration file located at "/tmp/pp/.pinpress"
    When I run `pinpress init` interactively
      And I type ""
      And I type ""
      And I type "bachya:12345"
    Then the exit status should be 0
      And a valid configuration file should exist at "/tmp/pp/.pinpress"