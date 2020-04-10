Feature: User can insert a dance into an Act.

Background: Start on the homepage
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


Scenario: Insert "InsertPerformance1" into Act 1
  When I fill insert dance into "act1" with "InsertPerformance1"
  Then I press insert new dance for "Insert Dance into Act1"
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
  | InsertPerformance1        |
  And I should see the following table
  | Act 2                     |

Scenario: Insert "InsertPerformance1" into Act 2
  When I fill insert dance into "act2" with "InsertPerformance1"
  Then I press insert new dance for "Insert Dance into Act2"
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
  | InsertPerformance1        |

Scenario: Insert "InsertPerformance1" into Act 1, then upload a new schedule with "good_data_test" and see that they are different
  When I fill insert dance into "act1" with "InsertPerformance1"
  Then I press insert new dance for "Insert Dance into Act1"
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
  | InsertPerformance1        |
  And I should see the following table
  | Act 2                     |
  Then I go back to the homepage
  When I attach the file "test_files/good_data_test.csv" to "file"
  Then the "file" field within the DAS home page should contain "good_data_test.csv"
  When I press "Import from file"
  Then I should not see "InsertPerformance1"


Scenario: Upload a schedule, then upload a second one, insert "InsertPerformance1" into it then go back to the first schedule and make sure it doesn't contain "InsertPerformance1"
  Then I go back to the homepage
  When I attach the file "test_files/good_data_test.csv" to "file"
  Then the "file" field within the DAS home page should contain "good_data_test.csv"
  When I press "Import from file"
  And I should see "Successfully Imported Data!!!"
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
  When I fill insert dance into "act1" with "InsertPerformance1"
  Then I press insert new dance for "Insert Dance into Act1"
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
  | InsertPerformance1        |
  And I should see the following table
  | Act 2                     |
  Then I go back to schedule "1"
  Then I should not see "InsertPerformance1"
  


