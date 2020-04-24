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
  Given I put the schedule in the following order for act 1
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
  And I put the schedule in the following order for act 2
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

  Then I should see the following performances in a table for act 1 in order
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
  And I should see the following performances in a table for act 2 in order
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
  And I should see the following performances in a table for act 1 in order
  | I Don’t Think About You   |
  | Fall                      |
  | Sugar                     |
  | Sorrow                    |
  | All I Ask                 |
  | Life is Good              |
  | Rivers & Roads            |
  | Shallow                   |
  | Let me think about it     |
  | Lost                      |
  And I should see the following performances in a table for act 2 in order
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
  When I drag performance "Lost" to "Falling"
  When I drag performance "Falling" to "Lost"
  Then performance "Falling" should be right before "Lost"
  And I should see the following performances in a table for act 1 in order
  | I Don’t Think About You   |
  | Fall                      |
  | Sugar                     |
  | Sorrow                    |
  | All I Ask                 |
  | Life is Good              |
  | Rivers & Roads            |
  | Shallow                   |
  | Let me think about it     |
  And I should see the following performances in a table for act 2 in order
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

@selenium_chrome_headless
Scenario: Moving into an empty act
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
  Then I should see "Amber Krizan" in between "All I Ask" and "Sorrow"
  When I drag performance "Sugar" to "Life is Good"
  Then I should see the following performances in a table for act 1 in order
  | I Don’t Think About You   |
  | Sugar                     |
  | Life is Good              |
  | All I Ask                 |
  | Sorrow                    |
  And I should see no performances in the table for act 2
  And I should see "Andrea Onate" in between "I Don’t Think About You" and "Sugar"
  And I should see "Amber Krizan" in between "Life is Good" and "All I Ask"
  And I should see "Audrey Harris" in between "Life is Good" and "All I Ask"
  Then I should see "Amber Krizan" in between "All I Ask" and "Sorrow"