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

When ("I remove dance {string}") do |string1|
  find("#remove"+string1.gsub(" ", "_")).click
end

When ("I revive dance {string}") do |string1|
  find("#revive"+string1.gsub(" ", "_")).click
end

When /^(?:|I )follow "([^"]*)"$/ do |link|
  click_link(link)
end

When("I fill insert dance into {string} with {string}") do |string, string2|
  within("#" + string + "insert"){fill_in("new_performance_name", :with => string2)}
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

When ("I lock dance {string}") do |string1|
  #puts page.to_s
  find("#lock"+string1.gsub(" ", "_")).click
end

Then ("I should see that dance {string} changed to {string}") do |string1, string2|
  within("#lock"+string1){page.should have_selector("input[type=image][src='#{string2}']")}
end

Then ("I write in {string} for the schedule name") do |value|
  fill_in("schedule_name", :with => value)
end

Then ("I click the link {string}") do |value|
  click_link(value)
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
		original_item_position = item_dragged.position
		original_act_id = item_dragged.act_id
		pos = item_dropped.position
		item_new_pos = pos
		item_dropped_act_id = item_dropped.act_id
		nxt = Performance.all.filter{ |e| e.position == pos && e.act_id == item_dropped_act_id}[0]
		index = pos + 1
		while true
			item = nxt
			nxt = Performance.all.filter{ |e| e.position == pos+1 && e.act_id == item_dropped_act_id}[0]
			if item == nil
				break
			end
			if item.id == item_dragged.id
				pos += 1
				next
			end
			item.position = index
			Performance.where( id: item.id.to_i ).update(position: index)
			index += 1
			pos += 1
		end
		item_dragged.position = item_new_pos
		item_dragged.act_id = item_dropped.act_id
		Performance.where( id: item_dragged.id.to_i ).update(position: item_new_pos, act_id: item_dropped.act_id)

		if original_act_id != item_dropped.act_id
			nxt = Performance.all.filter{ |e| e.position == original_item_position + 1 && e.act_id == original_act_id}[0]
			index = original_item_position
			pos = index + 1
			while true
				item = nxt
				nxt = Performance.all.filter{ |e| e.position == pos+1 && e.act_id == item_dropped_act_id}[0]
				if item == nil
					break
				end
				item.position = index
				Performance.where( id: item.id.to_i ).update(position: index)
				index += 1
				pos += 1
			end
		end

    #if item_dragged.act_id == item_dropped.act_id
      #page.execute_script %{ $("tr#performance_#{item_dragged.id}").simulateDragSortable({ move: #{item_dropped.position - item_dragged.position}}); }
			# Now i'm just going to build the :params, but swap the dragged and target
    #else
      #page.execute_script %{ $("tr#performance_#{item_dragged.id}").simulateDragSortable({ move: #{item_dropped.position}, dropOn: $("tr#performance_#{item_dropped.id}") }); }
    #end
    sleep(2)
		current_path = URI.parse(current_url).path
		visit current_path
    sleep(2)
  rescue Exception => ex
    puts "Error: #{ex.class} #{ex.message}"
  end
end


When /^I drop performance "([^"]*)" into the empty act$/ do |item_name|
  item = Performance.all.filter { |e| e.name == item_name }[0]
  dom = page.find("tr#performance_#{item.id}", visible: :all)

  page.execute_script %{ $("tr#performance_#{item.id}").simulate('drag-n-drop', { dragTarget: $(".unmoveable") }); }
  sleep(15)
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

Then /^performance "([^"]*)" should be right (before|after) "([^"]*)"$/ do |item_name1,order,item_name2|
  item1 = Performance.all.filter { |e| e.name == item_name1 }[0]
  item2 = Performance.all.filter { |e| e.name == item_name2 }[0]
  item1.position.to_i.should == (item2.position.to_i+((order=="after")?0:-1))
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

Then /^(?:|I )should see "([^"]*)" in between "([^"]*)" and "([^"]*)"$/ do |thing, before_thing, after_thing|
  if page.body.respond_to? :should
    page.should have_content(text)
  else
    assert page.has_content?(text)
  end
  page.body.should =~ /#{before_thing}.*#{thing}/m
  page.body.should =~ /#{thing}.*#{after_thing}/m
end

Then /^(?:|I )should see the following (?:|performances in a )table(?:| for act ([0-9]))(?:| (in order))$/ do |act_number, in_order, values|
  list = values.raw.map {|e| e[0]}
  within("#act"+act_number) do
    list.each do |text|
      find("td", text: /^#{text}$/)
    end
  end
  if in_order
    regex_str = ""
    list.each_with_index do |text, i|
      if i < list.length - 1
        regex_str += text + ".*"
      else
        regex_str += text
      end
    end
    regex = /#{regex_str}/m
    page.body.should =~ regex
  end
end

Then /^(?:|I )should see no performances in the table for act ([0-9])$/ do |act_number|
  within("#act"+act_number) do
    page.body.should =~ /This act is empty. Dragging a performance here will move it into this act./m
  end
end

Then /^(?:|I )should see the following (?:|performances )in tables$/ do |values|
  list = values.raw.map {|e| e[0]}
  list.each do |perf|
    # To get an exact match for the performance exactly once in the tables
    act1_count = page.all('#act1 td div.floatLeft', text: /^#{perf}$/).count
    act2_count = page.all('#act2 td div.floatLeft', text: /^#{perf}$/).count
    
    (act1_count + act2_count).should eq 1
  end
end

Then /^(?:|I )should see ([0-9]+) performances in act ([0-9])$/ do |num_perfs, act_number|
  page.all("#act"+act_number.to_s+" td div.floatLeft").count.should eq num_perfs.to_i
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

Then /^(?:|I )should not see dance "([^"]*)" for act ([0-9])$/ do |text, act_number|
  within("#act"+act_number) do
    page.should have_no_content(text)
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
