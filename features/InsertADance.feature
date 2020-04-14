Feature: User can insert a dance into an Act.

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


Scenario: Insert "InsertPerformance1" into Act 1
  When I fill insert dance into "act1" with "InsertPerformance1"
  Then I press insert new dance for "Insert Dance into Act1"
  Then I should see the following performances in a table for act 1 in order
  | I Don’t Think About You   |
  | Life is Good              |
  | Sugar                     |
  | All I Ask                 |
  | Sorrow                    |
  | InsertPerformance1        |
  And I should see no performances in the table for act 2

Scenario: Insert "InsertPerformance1" into Act 2
  When I fill insert dance into "act2" with "InsertPerformance1"
  Then I press insert new dance for "Insert Dance into Act2"
  Then I should see the following performances in a table for act 1 in order
  | I Don’t Think About You   |
  | Life is Good              |
  | Sugar                     |
  | All I Ask                 |
  | Sorrow                    |
  And I should see the following performances in a table for act 2 in order
  | InsertPerformance1        |

Scenario: Insert "InsertPerformance1" into Act 1, then upload a new schedule and see that they are different
  When I fill insert dance into "act1" with "InsertPerformance1"
  Then I press insert new dance for "Insert Dance into Act1"
  Then I should see the following performances in a table for act 1 in order
  | I Don’t Think About You   |
  | Life is Good              |
  | Sugar                     |
  | All I Ask                 |
  | Sorrow                    |
  | InsertPerformance1        |
  And I should see no performances in the table for act 2
  Then I go back to the homepage
  When I attach the file "test_files/small_good_data_test.csv" to "file"
  Then the "file" field within the DAS home page should contain "small_good_data_test.csv"
  When I press "Import from file"
  Then I should not see "InsertPerformance1"


Scenario: Upload a schedule, then upload a second one, insert "InsertPerformance1" into it then go back to the first schedule and make sure it doesn't contain "InsertPerformance1"
  Then I go back to the homepage
  When I attach the file "test_files/small_good_data_test.csv" to "file"
  Then the "file" field within the DAS home page should contain "small_good_data_test.csv"
  When I press "Import from file"
  And I should see "Successfully Imported Data!!!"
  Then I should see the following performances in a table for act 1 in order
  | I Don’t Think About You   |
  | Life is Good              |
  | Sugar                     |
  | All I Ask                 |
  | Sorrow                    |
  And I should see no performances in the table for act 2
  When I fill insert dance into "act1" with "InsertPerformance1"
  Then I press insert new dance for "Insert Dance into Act1"
  Then I should see the following performances in a table for act 1 in order
  | I Don’t Think About You   |
  | Life is Good              |
  | Sugar                     |
  | All I Ask                 |
  | Sorrow                    |
  | InsertPerformance1        |
  And I should see no performances in the table for act 2
  Then I go back to schedule "1"
  Then I should not see "InsertPerformance1"
  


