Feature: Initialization
  As a user, when I initialize PinPress,
  I should be guided through the process as
  necessary.

  Scenario: Basic Initialization
    Given no file located at "/tmp/pp/.pinpress"
    When I run `pinpress init` interactively
      And I type ""
      And I type "12345"
    Then the exit status should be 0
      And the file "/tmp/pp/.pinpress" should contain:
      """
      ---
      pinpress:
        config_location: "/tmp/pp/.pinpress"
        default_template: pinpress_default
        log_level: WARN
        version: 1.0.1
        api_token: '12345'
      templates:
      - name: pinpress_default
        opener: "<ul>"
        item: "<li><b><a title=\"<%= description %>\" href=\"<%= href %>\" target=\"_blank\"><%=
          description %></a>.</b> <%= extended %></li>"
        closer: "</ul>"
      """

  Scenario: Reinitialization (refuse)
    Given a file located at "/tmp/pp/.pinpress" with the contents:
    """
    ---
    pinpress:
      config_location: "/tmp/pp/.pinpress"
      default_template: pinpress_default
      log_level: WARN
      version: 1.0.1
      api_token: '12345'
    templates:
    - name: pinpress_default
      opener: "<ul>"
      item: "<li><b><a title=\"<%= description %>\" href=\"<%= href %>\" target=\"_blank\"><%=
        description %></a>.</b> <%= extended %></li>"
      closer: "</ul>"
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
      default_template: pinpress_default
      log_level: WARN
      version: 1.0.1
      api_token: '12345'
    templates:
    - name: pinpress_default
      opener: "<ul>"
      item: "<li><b><a title=\"<%= description %>\" href=\"<%= href %>\" target=\"_blank\"><%=
        description %></a>.</b> <%= extended %></li>"
      closer: "</ul>"
    """
    When I run `pinpress init` interactively
      And I type "y"
      And I type ""
      And I type "12345"
    Then the exit status should be 0
      And the file "/tmp/pp/.pinpress" should contain:
      """
      ---
      pinpress:
        config_location: "/tmp/pp/.pinpress"
        default_template: pinpress_default
        log_level: WARN
        version: 1.0.1
        api_token: '12345'
      templates:
      - name: pinpress_default
        opener: "<ul>"
        item: "<li><b><a title=\"<%= description %>\" href=\"<%= href %>\" target=\"_blank\"><%=
          description %></a>.</b> <%= extended %></li>"
        closer: "</ul>"
      """
        
  Scenario: Reinitialization (from scratch)
    Given a file located at "/tmp/pp/.pinpress" with the contents:
    """
    ---
    pinpress:
      config_location: "/tmp/pp/.pinpress"
      default_template: pinpress_default
      log_level: WARN
      version: 1.0.1
      api_token: '12345'
    templates:
    - name: pinpress_default
      opener: "<ul>"
      item: "<li><b><a title=\"<%= description %>\" href=\"<%= href %>\" target=\"_blank\"><%=
        description %></a>.</b> <%= extended %></li>"
      closer: "</ul>"
    """
    When I run `pinpress init -s` interactively
      And I type ""
      And I type "12345"
    Then the exit status should be 0
      And the file "/tmp/pp/.pinpress" should contain:
      """
      ---
      pinpress:
        config_location: "/tmp/pp/.pinpress"
        default_template: pinpress_default
        log_level: WARN
        version: 1.0.1
        api_token: '12345'
      templates:
      - name: pinpress_default
        opener: "<ul>"
        item: "<li><b><a title=\"<%= description %>\" href=\"<%= href %>\" target=\"_blank\"><%=
          description %></a>.</b> <%= extended %></li>"
        closer: "</ul>"
      """