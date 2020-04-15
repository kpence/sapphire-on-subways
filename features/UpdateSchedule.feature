Feature: User can move performances in the schedule.

@selenium_chrome_headless
Scenario: Click and drag to swap "Fall" with "Sugar"
  Given I am on the DAS home page
  Then I should see "Looks like you don't have any schedules yet!"
  When I attach the file "test_files/good_data_test.csv" to "file"
  Then the "file" field within the DAS home page should contain "good_data_test.csv"
  When I press "Import from file"
  Then I should be on the Edit Schedule page
  And I should see "Successfully Imported Data!!!"
  Given I am on the Edit Schedule page
  Then I should see the following performances in a table for act 1
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
  And I should see the following table for act 2
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
  When I drag performance "Fall" to "Sugar"
  Then performance "Fall" should be right before "Sugar"

#Scenario: Click and drag to move "Lost" into "Act 2"
  When I drag performance "Lost" to "Falling"
  Then performance "Lost" should be in act 2

#Scenario: Click and drag to swap "Falling" and "Lost"
  When I drag performance "Falling" to "Lost"
  Then performance "Falling" should be right before "Lost"
  Then I should see the following performances in a table for act 1
  | I Don’t Think About You   |
  | Sugar                     |
  | All I Ask                 |
  | Life is Good              |
  | Fall                      |
  | Rivers & Roads            |
  | Shallow                   |
  | Let me think about it     |
  And I should see the following table for act 2
  | This Gift                 |
  | I Will Wait               |
  | Falling                   |
  | Lost                      |
  | Show Me How You Burlesque |
  | Lost Without You          |
  | Move Your Feet            |
  | Crazy in Love             |
  | Old Money                 |
  | Flesh & Bone              |
  | Cringe- Stripped          |
  | Nails, Hair, Hips, Heels  |
