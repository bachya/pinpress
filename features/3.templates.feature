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
      1.  Name:   pinpress_default
        Opener:   <ul>
          Item:   <li><%= href %></li>
        Closer:   </ul>
      ---> AVAILABLE TAG TEMPLATES:
      1.  Name:   pinpress_default
        Opener:   
          Item:   <%= tag %> (<%= count %>),
        Closer:   
      """

  Scenario: List Templates (explicit)
    Given an existing current configuration file located at "/tmp/pp/.pinpress"
    When I run `pinpress templates list` interactively
    Then the exit status should be 0
      And the output should contain:
      """
      ---> AVAILABLE PIN TEMPLATES:
      1.\tName:   pinpress_default
            Opener:   <ul>
              Item:   <li><%= href %></li>
            Closer:   </ul>
      ---> AVAILABLE TAG TEMPLATES:
      1.      Name:   pinpress_default
            Opener:   
              Item:   <%= tag %> (<%= count %>),
            Closer:   
      """
