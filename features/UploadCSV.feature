Feature: User can upload a .csv file to the database
  
Scenario: Upload a CSV
  Given I am on the DAS home page
  Then I should see "Looks like you don't have any schedules yet! Click the button to upload your first one!"
  When I attach the file "test.csv" to "csv"
<<<<<<< HEAD
  Then the "csv" field within the DAS home page should contain "test.csv"
=======
  Then the "csv" field within the DAS home page should contain "test.csv"
>>>>>>> 0f27a67bcdadca5ec415ab739b41fc2d9b6869db
