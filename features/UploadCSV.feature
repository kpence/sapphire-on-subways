Feature: User can upload a .csv file to the database
  
Scenario: Upload a CSV
  Given I am on the DAS home page
  Then I should see "Looks like you don't have any schedules yet! Click the button to upload your first one!"
  When I attach the file "test.csv" to "file"
  Then the "file" field within the DAS home page should contain "test.csv"

