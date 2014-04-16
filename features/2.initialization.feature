@announce
Feature: Initialization
  As a user, when I initialize PinPress,
  I should be guided through the process as
  necessary.

  Scenario: Basic Initialization
    Given no file located at "/tmp/srd/.pinpress"
    When I run `pinpress init` interactively
    Then the exit status should be 0
