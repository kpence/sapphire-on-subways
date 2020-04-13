Feature: User can be given a preliminary, conflict-minimized schedule upon uploading an excel file.

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

Scenario: Press the refresh button to generate a new schedule (no locked dances)
  When I press "Regenerate"
  Then I should see the following performances in a table for act 1 in order
  | I Don’t Think About You   |
  | Life is Good              |
  | Sugar                     |
  | All I Ask                 |
  | Sorrow                    |
  And I should see no performances in the table for act 2
  
@selenium_chrome_headless
Scenario: Move unlocked but not unlocked dances on regenerate
  When I drag performance "Sorrow" to "I Don’t Think About You"
  Then I should see the following performances in a table for act 1 in order
  | I Don’t Think About You   |
  | Life is Good              |
  | Sorrow                    |
  | Sugar                     |
  | All I Ask                 |
  And I should see no performances in the table for act 2
  And I should see "Amber Krizan" in between "Life is Good" and "Sorrow"
  And I should see "Ashley Carey" in between "Life is Good" and "Sorrow"
  And I should see "Amanda Hohlt" in between "Sorrow" and "Sugar"
  And I should see "Andrea Onate" in between "Sorrow" and "Sugar"
  # If I change this to "All I Ask", it breaks:
  When I lock dance "Sugar" 
  Then I press "Regenerate"
  Then I should see the following performances in a table for act 1 in order
  | Sorrow                    |
  | I Don’t Think About You   |
  | Life is Good              |
  | Sugar                     |
  | All I Ask                 |
  And I should see no performances in the table for act 2