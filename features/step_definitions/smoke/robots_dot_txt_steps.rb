Given /^I am on the robots\.txt page$/ do
  visit '/robots.txt'
end

Then /^I should get OK response code$/ do
  webrat_session.response_code
end

Then /^I should get this content$/ do |string|
  response_body.should == string
end
