Feature: User can revive a dance in an Act.

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
  And I should see "Amber Krizan" in between "All I Ask" and "Sorrow"

Scenario: Revive "Sugar" in "Act 1"
  When I remove dance "Sugar"
  Then I should see the following performances in a table for act 1 in order
  | I Don’t Think About You   |
  | Life is Good              |
  | All I Ask                 |
  | Sorrow                    |
  And I should see no performances in the table for act 2
  And I should see "Amber Krizan" in between "All I Ask" and "Sorrow"
  And I should see "Amber Krizan" in between "Life is Good" and "All I Ask"
  And I should see "Audrey Harris" in between "Life is Good" and "All I Ask"
  And I should not see dance "Sugar" for act 1
  When I revive dance "Sugar"
  Then I should see the following performances in a table for act 1 in order
  | Sugar                     |
  | I Don’t Think About You   |
  | Life is Good              |
  | All I Ask                 |
  | Sorrow                    |
  And I should see no performances in the table for act 2
  And I should see "Andrea Onate" in between "Sugar" and "I Don’t Think About You"
  And I should see "Amber Krizan" in between "Life is Good" and "All I Ask"
  And I should see "Audrey Harris" in between "Life is Good" and "All I Ask"
  And I should see "Amber Krizan" in between "All I Ask" and "Sorrow"

Scenario: Revive the first dance
  When I remove dance "I Don’t Think About You"
  Then I should see the following performances in a table for act 1 in order
  | Life is Good              |
  | Sugar                     |
  | All I Ask                 |
  | Sorrow                    |
  And I should see no performances in the table for act 2
  And I should see "Amber Krizan" in between "All I Ask" and "Sorrow"
  And I should not see dance "I Don't Think About You" for act 1
  When I revive dance "I Don’t Think About You"
  Then I should see the following performances in a table for act 1 in order
  | I Don’t Think About You   |
  | Life is Good              |
  | Sugar                     |
  | All I Ask                 |
  | Sorrow                    |
  And I should see no performances in the table for act 2
  And I should see "Amber Krizan" in between "All I Ask" and "Sorrow"
  
  Scenario: Revive the last dance
  When I remove dance "Sorrow"
  Then I should see the following performances in a table for act 1 in order
  | I Don’t Think About You   |
  | Life is Good              |
  | Sugar                     |
  | All I Ask                 |
  And I should see no performances in the table for act 2
  And I should not see dance "Sorrow" for act 1
  When I revive dance "Sorrow"
  Then I should see the following performances in a table for act 1 in order
  | Sorrow                    |
  | I Don’t Think About You   |
  | Life is Good              |
  | Sugar                     |
  | All I Ask                 |
  And I should see no performances in the table for act 2
  And I should see "Andrea Onate" in between "Sorrow" and "I Don’t Think About You"