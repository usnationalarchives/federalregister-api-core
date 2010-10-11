Feature: Search Articles
  In order for users to find the documents of interest 
  Users should be able to search the full database
  
  Scenario: Searching for a document in the full text
    Given I am on the home page
    When I search for '"FMCSA removes turbochargers from the list of noise dissipative devices"'
    Then I should see a link to '/articles/2010/09/20/2010-23419/compliance-with-interstate-motor-carrier-noise-emission-standards-exhaust-systems'