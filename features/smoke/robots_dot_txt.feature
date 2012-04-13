Feature: Accessible robots.txt 
  In order to be indexed by major search engines, we should have a functioning robots.txt page.
  
  Scenario: Loading robots.txt 
    Given I am on the robots.txt page
    Then I should get OK response code
    And I should get this content
      """

      Sitemap: https://www.federalregister.gov/sitemap_index.xml.gz

      User-Agent: *
      Disallow: /subscriptions
      Disallow: /articles/current
      Disallow: /articles/email-a-friend
      Disallow: /my/


      """
