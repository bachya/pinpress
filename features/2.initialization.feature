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
      And the following files should exist:
      | /tmp/pp/.pinpress |

  Scenario: Reinitialization (refuse)
    Given a file located at "/tmp/pp/.pinpress" with the contents:
     """
     ---
     pinpress:
       config_location: "/tmp/pp/.pinpress"
       default_pin_template: pinpress_default
       default_tag_template: pinpress_default
       log_level: WARN
       version: 1.1.1
       api_token: bachya:12345
     """
     When I run `pinpress init` interactively
       And I type ""
     Then the exit status should be 0

  Scenario: Reinitialization (accept)
    Given a file located at "/tmp/pp/.pinpress" with the contents:
    """
    ---
    pinpress:
      config_location: "/tmp/pp/.pinpress"
      default_pin_template: pinpress_default
      default_tag_template: pinpress_default
      log_level: WARN
      version: 1.1.1
      api_token: bachya:12345
    """
    When I run `pinpress init` interactively
      And I type "y"
      And I type ""
      And I type "bachya:12345"
    Then the exit status should be 0
      And the following files should exist:
      | /tmp/pp/.pinpress |

  Scenario: Reinitialization (from scratch)
    Given a file located at "/tmp/pp/.pinpress" with the contents:
    """
    ---
    pinpress:
      config_location: "/tmp/pp/.pinpress"
      default_pin_template: pinpress_default
      default_tag_template: pinpress_default
      log_level: WARN
      version: 1.1.1
      api_token: bachya:12345
    """
    When I run `pinpress init -s` interactively
      And I type ""
      And I type "bachya:12345"
    Then the exit status should be 0
      And the following files should exist:
      | /tmp/pp/.pinpress |
