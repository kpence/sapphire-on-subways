Feature: User can be given a preliminary, conflict-minimized schedule upon uploading an excel file.

Background: Start on the homepage
  Given I am on the DAS home page
  Then I should see "Looks like you don't have any schedules yet! Click the button to upload your first one!"
  When I attach the file "test_files/good_data_test.csv" to "file"
  Then the "file" field within the DAS home page should contain "good_data_test.csv"
  When I press "Import from file"
  Then I should be on the Edit Schedule page
  And I should see "Successfully Imported Data!!!"
Scenario: See a Schedule after uploading first data
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
