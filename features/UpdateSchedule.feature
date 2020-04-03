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
  Then I should see the following performances in a table
  | Act 1                     |
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
  And I should see the following table
  | Act 2                     |
  | This act is empty. Dragging a performance here will move it into this act. |
  When I drag performance "Fall" to "Sugar"
  Then performance "Sugar" should be right after "Fall"
  When I drag performance "Fall" to "Sugar"
  Then performance "Fall" should be right after "Sugar"

#Scenario: Click and drag to move "Falling", "Old Money", and "Lost" into "Act 2"
  And performance "Falling" should be in act 1
  When I drop performance "Falling" into the empty act
  Then performance "Falling" should be in act 2

  When I drag performance "Old Money" to "Falling"
  Then performance "Old Money" should be in act 2
  And performance "Old Money" should be right after "Falling"

  When I drag performance "Lost" to "Falling"
  Then performance "Lost" should be in act 2
  And performance "Lost" should be right after "Falling"

#Scenario: Click and drag to swap "Falling" and "Lost"
  And performance "Lost" should be right after "Falling"
  When I drag performance "Falling" to "Lost"
  Then performance "Falling" should be right after "Lost"
  Then I should see the following performances in a table
  | Act 1                     |
  | I Don’t Think About You   |
  | Sugar                     |
  | Sorrow                    |
  | All I Ask                 |
  | Life is Good              |
  | Fall                      |
  | Rivers & Roads            |
  | Shallow                   |
  | Let me think about it     |
  | This Gift                 |
  | I Will Wait               |
  | Show Me How You Burlesque |
  | Lost Without You          |
  | Move Your Feet            |
  | Crazy in Love             |
  | Flesh & Bone              |
  | Cringe- Stripped          |
  | Nails, Hair, Hips, Heels  |
  And I should see the following table
  | Act 2                     |
  | Lost                      |
  | Falling                   |
  | Old Money                 |

#Scenario: Click and drag to move "Falling", "Old Money", and "Lost" into "Act 1"
  When I drag performance "Falling" to "Sugar"
  Then performance "Falling" should be in act 1
  When I drag performance "Lost" to "Sugar"
  Then performance "Lost" should be in act 1
  When I drag performance "Old Money" to "Sugar"
  Then performance "Old Money" should be in act 1
  Then I should see the following performances in a table
  | Act 1                     |
  | I Don’t Think About You   |
  | Sugar                     |
  | Sorrow                    |
  | All I Ask                 |
  | Life is Good              |
  | Fall                      |
  | Rivers & Roads            |
  | Shallow                   |
  | Let me think about it     |
  | This Gift                 |
  | I Will Wait               |
  | Show Me How You Burlesque |
  | Lost Without You          |
  | Move Your Feet            |
  | Crazy in Love             |
  | Flesh & Bone              |
  | Cringe- Stripped          |
  | Nails, Hair, Hips, Heels  |
  | Lost                      |
  | Falling                   |
  | Old Money                 |
  And I should see the following table
  | Act 2                     |
  | This act is empty. Dragging a performance here will move it into this act. |
