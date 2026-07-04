Feature: Home page
  As a visitor
  I want to open the home page
  So that I see the TaxMate hello world

  Scenario: Visitor sees the hello world greeting
    When I visit the home page
    Then I should see "Hello, world!"
    And I should see "Turbo"
    And I should see "Stimulus"
    And I should see "Vue"
