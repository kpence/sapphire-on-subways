Feature: User can see what conflicts there are between dances in a schedule

Background: Start on the homepage
  Given I am on the DAS home page
  Then I should see "Looks like you don't have any schedules yet!"
  When I attach the file "test_files/small_good_data_test.csv" to "file"
  Then the "file" field within the DAS home page should contain "small_good_data_test.csv"
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

Scenario: See Conflicts for a Small Schedule
  Then I should see "Amber Krizan" in between "All I Ask" and "Sorrow"

@selenium_chrome_headless
Scenario: See Conflicts after Updating the Schedule
  Then I should see "Amber Krizan" in between "All I Ask" and "Sorrow"
  When I drag performance "I Don’t Think About You" to "Sugar"
  And I should see the following performances in a table for act 1 in order
  | Life is Good              |
  | I Don’t Think About You   |
  | Sugar                     |
  | All I Ask                 |
  | Sorrow                    |
  And I should see no performances in the table for act 2
  Then I should see "Andrea Onate" in between "I Don’t Think About You" and "Sugar"
  And I should see "Amber Krizan" in between "All I Ask" and "Sorrow"
 
