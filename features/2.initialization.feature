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
      And the file "/tmp/pp/.pinpress" should contain:
      """
      ---
      pinpress:
        config_location: "/tmp/pp/.pinpress"
        default_pin_template: pinpress_default
        default_tag_template: pinpress_default
        log_level: WARN
        version: 1.1.0
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

  Scenario: Reinitialization (refuse)
    Given a file located at "/tmp/pp/.pinpress" with the contents:
    """
    ---
    pinpress:
      config_location: "/tmp/pp/.pinpress"
      default_pin_template: pinpress_default
      default_tag_template: pinpress_default
      log_level: WARN
      version: 1.1.0
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
      version: 1.1.0
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
    When I run `pinpress init` interactively
      And I type "y"
      And I type ""
      And I type "bachya:12345"
    Then the exit status should be 0
      And the file "/tmp/pp/.pinpress" should contain:
      """
      ---
      pinpress:
        config_location: "/tmp/pp/.pinpress"
        default_pin_template: pinpress_default
        default_tag_template: pinpress_default
        log_level: WARN
        version: 1.1.0
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
        
  Scenario: Reinitialization (from scratch)
    Given a file located at "/tmp/pp/.pinpress" with the contents:
    """
    ---
    pinpress:
      config_location: "/tmp/pp/.pinpress"
      default_pin_template: pinpress_default
      default_tag_template: pinpress_default
      log_level: WARN
      version: 1.1.0
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
    When I run `pinpress init -s` interactively
      And I type ""
      And I type "bachya:12345"
    Then the exit status should be 0
      And the file "/tmp/pp/.pinpress" should contain:
      """
      ---
      pinpress:
        config_location: "/tmp/pp/.pinpress"
        default_pin_template: pinpress_default
        default_tag_template: pinpress_default
        log_level: WARN
        version: 1.1.0
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