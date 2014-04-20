@announce
Feature: UI
  As a user, when I ask for help, I should be presented
  with instructions on how to run the app.

  Scenario: Display help instructions
    When I get help for "pinpress"
    Then the exit status should be 0