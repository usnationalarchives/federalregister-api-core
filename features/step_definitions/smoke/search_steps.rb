Given /^I am on the home page$/ do
  visit '/'
end

When /^I search for '([^\']*)'$/ do |query|
  fill_in "Search the Federal Register", :with => query
  click_button "Go"
end

Then /^I should see a link to '([^\']*)'$/ do |url|
  response_body.should have_selector("a[href='#{ url }']")
end
