# TL;DR: YOU SHOULD DELETE THIS FILE
#
# This file was generated by Cucumber-Rails and is only here to get you a head start
# These step definitions are thin wrappers around the Capybara/Webrat API that lets you
# visit pages, interact with widgets and make assertions about page content.
#
# If you use these step definitions as basis for your features you will quickly end up
# with features that are:
#
# * Hard to maintain
# * Verbose to read
#
# A much better approach is to write your own higher level step definitions, following
# the advice in the following blog posts:
#
# * http://benmabey.com/2008/05/19/imperative-vs-declarative-scenarios-in-user-stories.html
# * http://dannorth.net/2011/01/31/whose-domain-is-it-anyway/
# * http://elabs.se/blog/15-you-re-cuking-it-wrong
#


require 'uri'
require 'cgi'
require File.expand_path(File.join(File.dirname(__FILE__), "..", "support", "paths"))
require File.expand_path(File.join(File.dirname(__FILE__), "..", "support", "selectors"))

module WithinHelpers
  def with_scope(locator)
    locator ? within(*selector_for(locator)) { yield } : yield
  end
end
World(WithinHelpers)

# Single-line step scoper
When /^(.*) within (.*[^":])$/ do |step, parent|
  with_scope(parent) { When step }
end

# Multi-line step scoper
When /^(.*) within (.*[^:]):$/ do |step, parent, table_or_string|
  with_scope(parent) { When "#{step}:", table_or_string }
end

Given /^(?:|I )am on (.+)$/ do |page_name|
  visit path_to(page_name)
end

When /^(?:|I )go to (.+)$/ do |page_name|
  visit path_to(page_name)
end

When /^(?:|I )press "([^"]*)"$/ do |button|
  click_button(button)
end

When /^(?:|I )press "([^"]*)" for "([^"]*)"$/ do |button, dance_name|
  click_button(button)
end

When /^(?:|I )follow "([^"]*)"$/ do |link|
  click_link(link)
end

When("I fill insert dance into {string} with {string}") do |string, string2|
  within("#" + string){fill_in("new_performance_name", :with => string2)}
end

Then("I press insert new dance for {string}") do |string|
  click_button(string)
end

Then("I go back to schedule {string}") do |string|
  visit "/schedules/" + string + "/edit"
end
When /^(?:|I )fill in "([^"]*)" for "([^"]*)"$/ do |value, field|
  fill_in(field, :with => value)
end

# Use this to fill in an entire form with data from a table. Example:
#
#   When I fill in the following:
#     | Account Number | 5002       |
#     | Expiry date    | 2009-11-01 |
#     | Note           | Nice guy   |
#     | Wants Email?   |            |
#
# TODO: Add support for checkbox, select or option
# based on naming conventions.


# Click Drag stuff
When /^I drag performance "([^"]*)" to "([^"]*)"$/ do |item_dragged_name, item_dropped_name|
  item_dragged = Performance.all.filter { |e| e.name == item_dragged_name }[0]
  item_dropped = Performance.all.filter { |e| e.name == item_dropped_name }[0]

  begin
    if item_dragged.act_id == item_dropped.act_id
      page.execute_script %{ $("tr#performance_#{item_dragged.id}").simulateDragSortable({ move: #{item_dropped.position - item_dragged.position}}); }
    else
      page.execute_script %{ $("tr#performance_#{item_dragged.id}").simulate('drag-n-drop', { dragTarget: $("tr#performance_#{item_dropped.id}") }); }
    end
    sleep(1)
  rescue Exception => ex
    puts "Error: #{ex.class} #{ex.message}"
  end
end


When /^I drop performance "([^"]*)" into the empty act$/ do |item_name|
  item = Performance.all.filter { |e| e.name == item_name }[0]
  dom = page.find("tr#performance_#{item.id}", visible: :all)

  page.execute_script %{ $("tr#performance_#{item.id}").simulate('drag-n-drop', { dragTarget: $(".unmoveable") }); }
  sleep(1)
end

Then /^performance "([^"]*)" should not be next to "([^"]*)"$/ do |item_name1,item_name2|
  item1 = Performance.all.filter { |e| e.name == item_name1 }[0]
  item2 = Performance.all.filter { |e| e.name == item_name2 }[0]
  diff = (item1.position.to_i - item2.position.to_i).abs
  diff.should !=1
end

Then /^performance "([^"]*)" should be next to "([^"]*)"$/ do |item_name1,item_name2|
  item1 = Performance.all.filter { |e| e.name == item_name1 }[0]
  item2 = Performance.all.filter { |e| e.name == item_name2 }[0]
  diff = (item1.position.to_i - item2.position.to_i).abs
  diff.should ==1
end

Then /^performance "([^"]*)" should be after "([^"]*)"$/ do |item_name1,item_name2|
  item1 = Performance.all.filter { |e| e.name == item_name1 }[0]
  item2 = Performance.all.filter { |e| e.name == item_name2 }[0]
  item1.position.to_i.should > item2.position.to_i
end

Then /^performance "([^"]*)" should be right after "([^"]*)"$/ do |item_name1,item_name2|
  item1 = Performance.all.filter { |e| e.name == item_name1 }[0]
  item2 = Performance.all.filter { |e| e.name == item_name2 }[0]
  item1.position.to_i.should == (item2.position.to_i+1)
end

Then /^performance "([^"]*)" should be in act ([0-9])$/ do |item_name,act_number|
  item = Performance.all.filter { |e| e.name == item_name }[0]
  act = Act.all.filter { |e| e.id == item.act_id }[0]
  act.number.should ==act_number.to_i
end

#
When /^(?:|I )fill in the following:$/ do |fields|
  pending
end

When /^(?:|I )fill in the following:$/ do |fields|
  fields.rows_hash.each do |name, value|
    When %{I fill in "#{name}" with "#{value}"}
  end
end

Then(/^I go back to the homepage$/) do
  visit root_path
end

When /^(?:|I )select "([^"]*)" from "([^"]*)"$/ do |value, field|
  select(value, :from => field)
end

When /^(?:|I )check "([^"]*)"$/ do |field|
  check(field)
end

When /^(?:|I )uncheck "([^"]*)"$/ do |field|
  uncheck(field)
end

When /^(?:|I )choose "([^"]*)"$/ do |field|
  choose(field)
end

When /^(?:|I )attach the file "([^"]*)" to "([^"]*)"$/ do |path, field|
  attach_file(field, File.expand_path(path))
end

Then /^(?:|I )should see "([^"]*)"$/ do |text|
  if page.respond_to? :should
    page.should have_content(text)
  else
    assert page.has_content?(text)
  end
end

Then /^(?:|I )should see the following (?:|performances in a )table$/ do |values|
  list = values.raw.map {|e| e[0]}
  list.each do |text|
    if page.respond_to? :should
      page.should have_content(text)
    else
      assert page.has_content?(text)
    end
  end
end

Then /^(?:|I )should see \/([^\/]*)\/$/ do |regexp|
  regexp = Regexp.new(regexp)

  if page.respond_to? :should
    page.should have_xpath('//*', :text => regexp)
  else
    assert page.has_xpath?('//*', :text => regexp)
  end
end

Then /^(?:|I )should not see "([^"]*)"$/ do |text|
  if page.respond_to? :should
    page.should have_no_content(text)
  else
    assert page.has_no_content?(text)
  end
end

Then /^(?:|I )should not see \/([^\/]*)\/$/ do |regexp|
  regexp = Regexp.new(regexp)

  if page.respond_to? :should
    page.should have_no_xpath('//*', :text => regexp)
  else
    assert page.has_no_xpath?('//*', :text => regexp)
  end
end

Then /^the "([^"]*)" field(?: within (.*))? should contain "([^"]*)"$/ do |field, parent, value|
  with_scope(parent) do
    field = find_field(field)
    field_value = (field.tag_name == 'textarea') ? field.text : field.value
    if field_value.respond_to? :should
      field_value.should =~ /#{value}/
    else
      assert_match(/#{value}/, field_value)
    end
  end
end

Then /^the "([^"]*)" field(?: within (.*))? should not contain "([^"]*)"$/ do |field, parent, value|
  with_scope(parent) do
    field = find_field(field)
    field_value = (field.tag_name == 'textarea') ? field.text : field.value
    if field_value.respond_to? :should_not
      field_value.should_not =~ /#{value}/
    else
      assert_no_match(/#{value}/, field_value)
    end
  end
end

Then /^the "([^"]*)" field should have the error "([^"]*)"$/ do |field, error_message|
  element = find_field(field)
  classes = element.find(:xpath, '..')[:class].split(' ')

  form_for_input = element.find(:xpath, 'ancestor::form[1]')
  using_formtastic = form_for_input[:class].include?('formtastic')
  error_class = using_formtastic ? 'error' : 'field_with_errors'

  if classes.respond_to? :should
    classes.should include(error_class)
  else
    assert classes.include?(error_class)
  end

  if page.respond_to?(:should)
    if using_formtastic
      error_paragraph = element.find(:xpath, '../*[@class="inline-errors"][1]')
      error_paragraph.should have_content(error_message)
    else
      page.should have_content("#{field.titlecase} #{error_message}")
    end
  else
    if using_formtastic
      error_paragraph = element.find(:xpath, '../*[@class="inline-errors"][1]')
      assert error_paragraph.has_content?(error_message)
    else
      assert page.has_content?("#{field.titlecase} #{error_message}")
    end
  end
end

Then /^the "([^"]*)" field should have no error$/ do |field|
  element = find_field(field)
  classes = element.find(:xpath, '..')[:class].split(' ')
  if classes.respond_to? :should
    classes.should_not include('field_with_errors')
    classes.should_not include('error')
  else
    assert !classes.include?('field_with_errors')
    assert !classes.include?('error')
  end
end

Then /^the "([^"]*)" checkbox(?: within (.*))? should be checked$/ do |label, parent|
  with_scope(parent) do
    field_checked = find_field(label)['checked']
    if field_checked.respond_to? :should
      field_checked.should be_true
    else
      assert field_checked
    end
  end
end

Then /^the "([^"]*)" checkbox(?: within (.*))? should not be checked$/ do |label, parent|
  with_scope(parent) do
    field_checked = find_field(label)['checked']
    if field_checked.respond_to? :should
      field_checked.should be_false
    else
      assert !field_checked
    end
  end
end
 
Then /^(?:|I )should be on (.+)$/ do |page_name|
  current_path = URI.parse(current_url).path
  if current_path.respond_to? :should
    current_path.should == path_to(page_name)
  else
    assert_equal path_to(page_name), current_path
  end
end

Then /^(?:|I )should have the following query string:$/ do |expected_pairs|
  query = URI.parse(current_url).query
  actual_params = query ? CGI.parse(query) : {}
  expected_params = {}
  expected_pairs.rows_hash.each_pair{|k,v| expected_params[k] = v.split(',')} 
  
  if actual_params.respond_to? :should
    actual_params.should == expected_params
  else
    assert_equal expected_params, actual_params
  end
end

Then /^show me the page$/ do
  save_and_open_page
end
