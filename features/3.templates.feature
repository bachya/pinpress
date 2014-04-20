Feature: Templates
  As a user, I should be able to list available
  templates and choose one.
  
  Scenario: List Templates (implicit)
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
    pin_templates:
    - name: pinpress_default
      opener: |
        <ul>
      item: |
        <li>
        <b><a title="<%= description %>" href="<%= href %>" target="_blank"><%= description %></a>.</b>
        <%= extended %>
        </li>
      closer: "</ul>"
    tag_templates:
    - name: pinpress_default
      item: "<%= tag %> (<%= count %>),"
    """
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
    pin_templates:
    - name: pinpress_default
      opener: |
        <ul>
      item: |
        <li>
        <b><a title="<%= description %>" href="<%= href %>" target="_blank"><%= description %></a>.</b>
        <%= extended %>
        </li>
      closer: "</ul>"
    tag_templates:
    - name: pinpress_default
      item: "<%= tag %> (<%= count %>),"
    """
    When I run `pinpress templates list` interactively
    Then the exit status should be 0
      And the output should contain:
      """
      ---> AVAILABLE PIN TEMPLATES:
      # 1. pinpress_default
      ---> AVAILABLE TAG TEMPLATES:
      # 1. pinpress_default
      """
