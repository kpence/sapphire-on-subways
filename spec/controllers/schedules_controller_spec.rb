require 'rails_helper'

describe SchedulesController do
  
  describe "#generate_conflict" do
    fixtures :performances
    
    it 'should give nil when there is not actually a conflict' do
      ret = controller.generate_conflict(nil, nil, [])
      expect(ret == nil)
    end
    
    it 'should convert the data given as input to a dictionary' do
      @fake_perf1 = performances(:MyPerf1)
      @fake_perf2 = performances(:MyPerf2)
      @fake_dancers = ["Troy", "Kyle", "Jeevika", "Hudson", "Divia"]
      ret = controller.generate_conflict(@fake_perf1, @fake_perf2, @fake_dancers)
      expect(ret).to have_key(:first_performance)
      expect(ret).to have_key(:second_performance)
      expect(ret).to have_key(:dancers)
      expect(ret[:first_performance]).to eq @fake_perf1.name
      expect(ret[:second_performance]).to eq @fake_perf2.name
      expect(ret[:dancers]).to eq @fake_dancers
    end
  end
  
  describe "#conflicts" do
    fixtures :dances, :dancers, :performances, :acts
    context "In the presence of an act with NO conflicts" do
      before :each do
        @fake_act = acts(:MyOtherAct1)
        
        @ordered_performances = {}
        @ordered_performances[1] = @fake_act.performances.sort_by {|p| p.id }
        controller.instance_variable_set(:@ordered_performances, @ordered_performances)
        controller.instance_variable_set(:@conflicting_performances, [])
        
        allow(controller).to receive(:generate_conflict).and_return(nil, nil)
        
        # See the fixture data: This has no conflicts
        @ret = controller.conflicts(1)
      end
      
      it 'should return an empty list' do
        expect(@ret).not_to eq nil
        expect(@ret.length).to eq 0
      end
      
      it 'should NOT add to the list of performances tracking the conflicts' do
        perfs = controller.instance_variable_get(:@conflicting_performances)
        expect(perfs.length).to eq 0
      end
    end
    
    context "In the presence of an act with conflicts" do
      before :each do
        # See the fixture data for details
        @fake_act = acts(:MyOtherAct2)
        @fake_perf1 = performances(:MyOtherPerf2)
        @fake_perf2 = performances(:MyOtherPerf3)
        @fake_dancer = dancers(:MyOtherDancer2)
        
        @ordered_performances = {}
        @ordered_performances[2] = @fake_act.performances.sort_by {|p| p.id }
        controller.instance_variable_set(:@ordered_performances, @ordered_performances)
        controller.instance_variable_set(:@conflicting_performances, [])
        
        @fake_conflict = {:first_performance => @fake_perf1.name,
                          :second_performance => @fake_perf2.name,
                          :dancers => [@fake_dancer.name]
        }
        
        allow(controller).to receive(:generate_conflict)
            .and_return(nil, @fake_conflict, nil, nil, nil)
        
        # See the fixture data: This has one conflict between
        # MyOtherPerf5 and MyOtherPerf6
        @ret = controller.conflicts(2)
      end
      
      it 'should return a list with the conflicts' do
        expect(@ret.length).to eq 1
        expect(@ret[0]).to eq @fake_conflict
      end
      
      it 'should add to the list of performances tracking the conflicts' do
        perfs = controller.instance_variable_get(:@conflicting_performances)
        expect(perfs.length).to eq 1
        expect(perfs[0]).to eq @fake_perf1.id
      end
    end
  end
  
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
    
    context "File will be uploaded" do
      context "with good data" do
        fixtures :schedules
        before:each do
          # Need fake data here to pretend to read from csv
          @fake_data= {:first => "Active Members"}
          @fake_schedule= schedules(:MySchedule)
          expect(Schedule).to receive(:check_csv).and_return(:success)
        end
        
        subject { post:import, params: {file:  fixture_file_upload("good_data_test.csv", 'text/csv')} }
        after:each do
          expect(subject).to redirect_to(:controller => "schedules", 
                                         :action => "edit", 
                                         :id => @fake_schedule.id)
          subject
          expect(flash[:success]).to eq "Successfully Imported Data!!!"
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
    fixtures :schedules, :acts, :performances
    before :each do
      @fake_schedule = schedules(:MySchedule)
    end
    
    it 'should look up the schedule by id' do
      expect(Schedule).to receive(:find).and_return(@fake_schedule)
      get :edit, params: {id: @fake_schedule.id}
    end
    
    it 'should redirect back to the upload page if it cannot find that schedule' do
      allow(Schedule).to receive(:find).and_return(nil)
      get :edit, params: {id: @fake_schedule.id}
      
      expect(subject).to redirect_to(schedules_path)
      expect(controller).to set_flash[:notice]
      expect(flash[:notice]).to eq "Schedule with id " + @fake_schedule.id.to_s + " could not be found."
    end
    
    context "It has my schedule" do
      before :each do
        allow(Schedule).to receive(:find).and_return(@fake_schedule)
        get :edit, params: {id: @fake_schedule.id}
        @ordered_performances = controller.instance_variable_get(:@ordered_performances)
      end
      
      it "should assign a dictionary that holds all the acts' performances" do
        expect(@ordered_performances).not_to eq(nil)
        
        # Good enough if it has the same number of acts and performances
        expect(@ordered_performances.length()).to eq(@fake_schedule.acts.length())
        @fake_acts = @fake_schedule.acts
        @ordered_performances.each do |act_number, perf_list|
          @fake_performances = @fake_acts.find_by_number(act_number).performances
          expect(perf_list.length()).to eq(@fake_performances.length())
        end
      end
      it 'should order the performances in each act by their schedule_index field' do
        @ordered_performances.each do |act_number, perf_list|
          correct_order = perf_list.sort_by {|d| d.position }
          given_order = perf_list
          expect(given_order).to eq(correct_order)
        end
      end
    end
    
    context "We came from the upload page" do
      it 'should generate a random schedule using the helper' do
        allow(Schedule).to receive(:find).and_return(@fake_schedule)
        expect(controller.helpers).to receive(:minimize_conflicts).exactly(2).times
        get :edit, params: {id: @fake_schedule.id}, flash: {minimize: true}
      end
    end
  end

  describe "#export" do
    fixtures :acts, :schedules, :performances
    before :each do
      @fake_schedule = schedules(:MySchedule)
      @fake_perf1 = performances(:MyPerf1)
      @fake_perf2 = performances(:MyPerf2)
      @fake_perf3 = performances(:MyPerf3)
      @fake_perf4 = performances(:MyPerf4)
      @fake_perf5 = performances(:MyPerf5)
      @performances = { 1 => [@fake_perf1, @fake_perf2, @fake_perf3], 2 => [@fake_perf4, @fake_perf5] }
      @conflicting_performances = [ @fake_perf1.id, @fake_perf2.id ]

      @conflicts_hash = {
        "1" => [
          {"first_performance" => @fake_perf1.name, "second_performance" => @fake_perf2.name, "dancers" => ["Troy", "Jeevika"]},
          {"first_performance" => @fake_perf2.name, "second_performance" => @fake_perf3.name, "dancers" => ["Divia"]},
        ],
        "2" => [
          {"first_performance" => @fake_perf4.name, "second_performance" => @fake_perf5.name, "dancers" => []}
        ]
      }
      @correct_csv = %{Act 1,Act 1 conflicts,Act 2,Act 2 conflicts\n#{@fake_perf1.name},"Troy, Jeevika",#{@fake_perf4.name},\n#{@fake_perf2.name},Divia,#{@fake_perf5.name},\n#{@fake_perf3.name},,,\n}
    end

    after :each do
      controller.instance_variable_set(:@conflicts, @conflicts_hash)
      post :export, :params => {"id" => @fake_schedule.id }, :flash => { "conflicts" => @conflicts_hash, "ordered_performances" => @performances, "conflicting_performances" => @conflicting_performances}
    end

    it 'should convert the performances and conflicts into CSV formatted string' do
      expect(Schedule).to receive(:to_csv).and_return(@correct_csv)
    end

  end
end
