Given /^I am on the home page$/ do
  visit '/'
end

When /^I search for '([^\']*)'$/ do |query|
  within '.search_form' do |scope|
    scope.fill_in "Search the Federal Register", :with => query
    scope.click_button 'Go'
  end
end

Then /^I should see a link to '([^\']*)'$/ do |url|
  response_body.should have_selector("a[href='#{ url }']")
end
