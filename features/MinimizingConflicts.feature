Feature: User can be given a preliminary, conflict-minimized schedule upon uploading an excel file.

Background: Start on the homepage
  Given I am on the DAS home page
  Then I should see "Looks like you don't have any schedules yet!"

Scenario: Press the refresh button to generate a new schedule (no locked dances)
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
  When I press "Regenerate"
  Then I should see the following performances in a table for act 1 in order
  | I Don’t Think About You   |
  | Life is Good              |
  | Sugar                     |
  | All I Ask                 |
  | Sorrow                    |
  And I should see no performances in the table for act 2
  And I should see "Amber Krizan" in between "All I Ask" and "Sorrow"
  
@selenium_chrome_headless
Scenario: Regenerating after moving dances (still all unlocked)
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
  When I drag performance "Sugar" to "Life is Good"
  Then I should see the following performances in a table for act 1 in order
  | I Don’t Think About You   |
  | Sugar                     |
  | Life is Good              |
  | All I Ask                 |
  | Sorrow                    |
  And I should see no performances in the table for act 2
  And I should see "Andrea Onate" in between "I Don’t Think About You" and "Sorrow"
  And I should see "Amber Krizan" in between "Life is Good" and "All I Ask"
  And I should see "Audrey Harris" in between "Life is Good" and "All I Ask"
  And I should see "Amber Krizan" in between "All I Ask" and "Sorrow"
  When I press "Regenerate"
  
Scenario: Removing a dance and regenerating shouldn't revive that dance
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
  When I remove dance "All I Ask" 
  Then I should see the following performances in a table for act 1 in order
  | I Don’t Think About You   |
  | Life is Good              |
  | Sugar                     |
  | Sorrow                    |
  And I should see no performances in the table for act 2
  And I should see "Amanda Hohlt" in between "Sugar" and "Sorrow"
  And I should see "Andrea Onate" in between "Sugar" and "Sorrow"
  Then I press "Regenerate"
  Then I should see the following performances in a table for act 1 in order
  | Sugar                     |
  | Life is Good              |
  | I Don’t Think About You   |
  | Sorrow                    |
  And I should see no performances in the table for act 2
  And I should see "Andrea Onate" in between "I Don’t Think About You" and "Sorrow"
  
Scenario: Locking one dance at the beginning
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
  Then I lock dance "I Don’t Think About You"
  When I press "Regenerate"
  Then I should see the following performances in a table for act 1 in order
  | I Don’t Think About You   |
  | Life is Good              |
  | Sugar                     |
  | All I Ask                 |
  | Sorrow                    |
  And I should see no performances in the table for act 2
  
Scenario: Locking one dance at the end
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
  Then I lock dance "Sorrow"
  When I press "Regenerate"
  Then I should see the following performances in a table for act 1 in order
  | I Don’t Think About You   |
  | Life is Good              |
  | Sugar                     |
  | All I Ask                 |
  | Sorrow                    |
  And I should see no performances in the table for act 2
  
Scenario: Locking a dance that causes a conflict
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
  When I drag performance "Sugar" to "Life is Good"
  Then I should see the following performances in a table for act 1 in order
  | I Don’t Think About You   |
  | Sugar                     |
  | Life is Good              |
  | All I Ask                 |
  | Sorrow                    |
  And I should see no performances in the table for act 2
  And I should see "Andrea Onate" in between "I Don’t Think About You" and "Sorrow"
  And I should see "Amber Krizan" in between "Life is Good" and "All I Ask"
  And I should see "Audrey Harris" in between "Life is Good" and "All I Ask"
  And I should see "Amber Krizan" in between "All I Ask" and "Sorrow"
  Then I lock dance "Sugar"
  When I press "Regenerate"
  Then I should see the following performances in a table for act 1 in order
  | Life is Good              |
  | Sugar                     |
  | All I Ask                 |
  | I Don’t Think About You   |
  | Sorrow                    |
  And I should see no performances in the table for act 2
  And I should see "Andrea Onate" in between "I Don’t Think About You" and "Sorrow"
  
Scenario: Using a big schedule, should not see a whole lot of conflicts
  When I attach the file "test_files/good_data_test.csv" to "file"
  Then the "file" field within the DAS home page should contain "good_data_test.csv"
  When I press "Import from file"
  Then I should be on the Edit Schedule page
  And I should see "Successfully Imported Data!!!"
  Given I am on the Edit Schedule page
  Then I should see the following performances in tables
  | I Don’t Think About You   |
  | Sugar                     |
  | Sorrow                    |
  | All I Ask                 |
  | Life is Good              |
  | Fall                      |
  | Rivers & Roads            |
  | Shallow                   |
  | Let me think about it     |
  | Lost                      |
  | This Gift                 |
  | I Will Wait               |
  | Falling                   |
  | Show Me How You Burlesque |
  | Lost Without You          |
  | Move Your Feet            |
  | Crazy in Love             |
  | Old Money                 |
  | Flesh & Bone              |
  | Cringe- Stripped          |
  | Nails, Hair, Hips, Heels  |
  And I should see 10 performances in act 1
  And I should see 11 performances in act 2
  When I press "Regenerate"
  # All you can guarantee is that the performances are all there
  Then I should see the following performances in tables
  | I Don’t Think About You   |
  | Sugar                     |
  | Sorrow                    |
  | All I Ask                 |
  | Life is Good              |
  | Fall                      |
  | Rivers & Roads            |
  | Shallow                   |
  | Let me think about it     |
  | Lost                      |
  | This Gift                 |
  | I Will Wait               |
  | Falling                   |
  | Show Me How You Burlesque |
  | Lost Without You          |
  | Move Your Feet            |
  | Crazy in Love             |
  | Old Money                 |
  | Flesh & Bone              |
  | Cringe- Stripped          |
  | Nails, Hair, Hips, Heels  |
  And I should see 10 performances in act 1
  And I should see 11 performances in act 2
  
Scenario: When I lock a performances in a big schedule, it shouldn't change position
  When I attach the file "test_files/good_data_test.csv" to "file"
  Then the "file" field within the DAS home page should contain "good_data_test.csv"
  When I press "Import from file"
  Then I should be on the Edit Schedule page
  And I should see "Successfully Imported Data!!!"
  Given I am on the Edit Schedule page
  Then I should see the following performances in tables
  | I Don’t Think About You   |
  | Sugar                     |
  | Sorrow                    |
  | All I Ask                 |
  | Life is Good              |
  | Fall                      |
  | Rivers & Roads            |
  | Shallow                   |
  | Let me think about it     |
  | Lost                      |
  | This Gift                 |
  | I Will Wait               |
  | Falling                   |
  | Show Me How You Burlesque |
  | Lost Without You          |
  | Move Your Feet            |
  | Crazy in Love             |
  | Old Money                 |
  | Flesh & Bone              |
  | Cringe- Stripped          |
  | Nails, Hair, Hips, Heels  |
  And I should see 10 performances in act 1
  And I should see 11 performances in act 2
  When I lock dance "Old Money"
  #...