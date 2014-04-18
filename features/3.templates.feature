Feature: Templates
  As a user, I should be able to list available
  templates and choose one.
  
  Scenario: List Templates (implicit)
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
    - name: secondary
      item: "* <%= href %>"
    """
    When I run `pinpress template` interactively
    Then the exit status should be 0
    And the output should contain:
    """
    ---> AVAILABLE TEMPLATES
    # 1. pinpress_default
    # 2. secondary
    """
    
  Scenario: List Templates (explicit)
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
    - name: secondary
      item: "* <%= href %>"
    """
    When I run `pinpress template list` interactively
    Then the exit status should be 0
      And the output should contain:
      """
      ---> AVAILABLE TEMPLATES
      # 1. pinpress_default
      # 2. secondary
      """
    
  Scenario: Choose Default Template
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
    - name: secondary
      item: "* <%= href %>"
    """
    When I run `pinpress template default` interactively
      And I type "4"
      And I type "0"
      And I type "asd"
      And I type "2"
    Then the exit status should be 0
      And the output should contain:
      """
      ---> CHOOSE A DEFAULT TEMPLATE
      # Current Default Template: pinpress_default
      # Choose a New Template:
      # 1. pinpress_default
      # 2. secondary
      # Invalid choice: 4
      # Invalid choice: 0
      # Invalid choice: asd
      # New default template chosen: secondary
      """
      And the file "/tmp/pp/.pinpress" should contain:
      """
      ---
      pinpress:
        config_location: "/tmp/pp/.pinpress"
        default_template: secondary
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