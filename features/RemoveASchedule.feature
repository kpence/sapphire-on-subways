Feature: User can remove a schedule

Background: Start on the homepage
  Given I am on the DAS home page
  Then I should see "Looks like you don't have any schedules yet!"
  When I attach the file "test_files/small_good_data_test.csv" to "file"
  Then the "file" field within the DAS home page should contain "small_good_data_test.csv"
  Then I write in "test schedule name1" for the schedule name
  When I press "Import from file"
  Then I should be on the Edit Schedule page
  And I should see "Successfully Imported Data!!!"
  Given I am on the Edit Schedule page
  Then I should see the following performances in a table for act 1 in order
  | I Don’t Think About You   |
  | Life is Good              |
  | Sugar                     |
  | All I Ask                 |
  | Sorrow                    |
  And I should see no performances in the table for act 2
  
Scenario: Remove the schedule
  When I press "Delete Schedule"
  Then I should be on the DAS home page
  Then I should not see "test schedule name1"
  
Scenario: Upload two schedules, then delete the second one
  Then I go back to the homepage
  When I attach the file "test_files/small_good_data_test.csv" to "file"
  Then the "file" field within the DAS home page should contain "small_good_data_test.csv"
  Then I write in "test schedule name2" for the schedule name
  When I press "Import from file"
  When I press "Delete Schedule"
  Then I should be on the DAS home page
  Then I should not see "test schedule name2"
  Then I should see "test schedule name1"

Scenario: Upload two schedules, then delete the first one
  Then I go back to the homepage
  When I attach the file "test_files/small_good_data_test.csv" to "file"
  Then the "file" field within the DAS home page should contain "small_good_data_test.csv"
  Then I write in "test schedule name2" for the schedule name
  When I press "Import from file"
  Then I go back to the homepage
  Then I click the link "test schedule name1"
  When I press "Delete Schedule"
  Then I should be on the DAS home page
  Then I should not see "test schedule name1"
  Then I should see "test schedule name2"