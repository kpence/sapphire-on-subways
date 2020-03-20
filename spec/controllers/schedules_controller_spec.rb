require 'rails_helper'

describe SchedulesController do
  
  describe '#index' do
    it 'should call Schedule#all to get all schedules in the DB' do
    expect(Schedule).to receive(:all)
    get :index
    end
  end
    
  describe '#import' do
    # Using "good" data here, although these things should happen regardless
    #
    # All tests require checking the csv and a redirection upon completion
    
    after:each do
      expect(controller).to set_flash[:notice]
    end
        
    context "File will be uploaded" do
      
      context "with good data" do
        fixtures :schedules
        before:each do
          # Need fake data here to pretend to read from csv
          @fake_data= {:first => "Active Members"}
          @fake_schedule= schedules(:MySchedule)
          allow(@fake_schedule).to receive(:id).and_return(1234)
                    
          expect(Schedule).to receive(:check_csv).and_return(:success)
        end
        
        subject { post:import, params: {file:  fixture_file_upload("good_data_test.csv", 'text/csv')} }
        after:each do
          expect(subject).to redirect_to(:controller => "schedules", 
                                         :action => "edit", 
                                         :id => @fake_schedule.id)
          subject
          expect(flash[:notice]).to eq "Successfully Imported Data!!!"
          expect(flash[:schedule_id]).to eq @fake_schedule.id
        end
        
        it 'should create the schedule/acts 1 and 2 and import the data' do
          # In other words, "expect" everything to happen in that block:
          expect(Schedule).to receive(:read_csv).and_return(@fake_data)
          expect(Schedule).to receive(:create!).with(hash_including :filename)
                                                                  .and_return(@fake_schedule)
          expect(Act).to receive(:create!).with(hash_including :number => 1, 
                                                          :schedule_id => @fake_schedule.id)
          expect(Act).to receive(:create!).with(hash_including :number => 2, 
                                                          :schedule_id => @fake_schedule.id)
          expect(@fake_schedule).to receive(:import)
        end
      end
      
      context "bad/missing (NOT good) data" do
        before:each do
          expect(Schedule).to receive(:check_csv).and_return(:failed)
                  
          # Make sure we never do this if the data are bad:
          expect(Schedule).not_to receive(:read_csv)
          expect(Schedule).not_to receive(:create!)
          expect(Act).not_to receive(:create!)
          expect(Act).not_to receive(:create!)
        end
        
        after:each do
          expect(flash[:notice]).to eq "Failed to Import Data!!!"
          expect(subject).to redirect_to(:controller => "schedules", 
                                         :action => "index")
        end
        
        it 'should not upload a messed up csv' do
          post:import, params: {file:  fixture_file_upload("bad_data_test.csv", 'text/csv')}
          subject { post:import, params: {file:  fixture_file_upload("bad_data_test.csv", 'text/csv')} }
        end
        
        it 'should not upload a file with random data' do
          post:import, params: {file:  fixture_file_upload("random_test.csv", 'text/csv')}
          subject { post:import, params: {file:  fixture_file_upload("random_test.csv", 'text/csv')} }
        end
        
        it 'should not upload a file with no data' do
          post:import, params: {file:  fixture_file_upload("empty_test.csv", 'text/csv')}
          subject { post:import, params: {file:  fixture_file_upload("empty_test.csv", 'text/csv')} }
        end
      end
    end
      
    context "No File will be uploaded" do
      before:each do
        expect(Schedule).to receive(:check_csv).and_return(:no_file)
      end
      
      after:each do
        expect(flash[:notice]).to eq "No file selected"
        expect(subject).to redirect_to(:controller => "schedules", 
                                       :action => "index")
      end
      
      it 'should notify the user that they did not attach a file' do
        post:import # with no parameters
      end
    end
  end
    
  describe "#edit" do
    
  end
end


