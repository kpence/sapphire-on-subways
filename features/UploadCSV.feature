Feature: User can upload a .csv file to the database

Background: Start on the homepage
  Given I am on the DAS home page
  Then I should see "Looks like you don't have any schedules yet!"

Scenario: First Successful CSV File Upload
  When I attach the file "test_files/good_data_test.csv" to "file"
  Then the "file" field within the DAS home page should contain "good_data_test.csv"
  When I press "Import from file"
  Then I should be on the Edit Schedule page
  And I should see "Successfully Imported Data!!!"
  
Scenario: First CSV File Upload with Random Bytes in File
  When I attach the file "test_files/random_test.csv" to "file"
  Then the "file" field within the DAS home page should contain "random_test.csv"
  When I press "Import from file"
  Then I should be on the DAS home page
  And I should see "Failed to Import Data!!!"
  
Scenario: First CSV File Upload with Empty File
  When I attach the file "test_files/empty_test.csv" to "file"
  Then the "file" field within the DAS home page should contain "empty_test.csv"
  When I press "Import from file"
  Then I should be on the DAS home page
  And I should see "Failed to Import Data!!!"
  
Scenario: First CSV File Upload with Some Bad Data in File
  When I attach the file "test_files/bad_data_test.csv" to "file"
  Then the "file" field within the DAS home page should contain "bad_data_test.csv"
  When I press "Import from file"
  Then I should be on the DAS home page
  And I should see "Failed to Import Data!!!"
  
Scenario: Click Import with No File Selected
  When I press "Import from file"
  Then I should be on the DAS home page
  And I should see "No file selected"
