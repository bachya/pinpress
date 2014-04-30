# @active
Feature: Templates
  As a user, I should be able to list available
  templates and choose one.

  Scenario: List Templates (implicit)
    Given an existing current configuration file located at "/tmp/pp/.pinpress"
    When I run `pinpress templates` interactively
    Then the exit status should be 0
      And the output should contain:
      """
      ---> AVAILABLE PIN TEMPLATES:
      # 1. pinpress_default
      ---> AVAILABLE TAG TEMPLATES:
      # 1. pinpress_default
      """

  Scenario: List Templates (explicit)
    Given an existing current configuration file located at "/tmp/pp/.pinpress"
    When I run `pinpress templates list` interactively
    Then the exit status should be 0
      And the output should contain:
      """
      ---> AVAILABLE PIN TEMPLATES:
      # 1. pinpress_default
      ---> AVAILABLE TAG TEMPLATES:
      # 1. pinpress_default
      """
