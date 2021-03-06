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
        @fake_act = acts(:MyOtherAct1)
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
            .and_return(nil, @fake_conflict)
        
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
  
  describe "#remove_unscheduled" do
    fixtures :performances
    it 'should return a filtered list if there are unscheduled performances' do
      @fake_perf1 = performances(:MyPerf1)
      @fake_perf2 = performances(:MyPerf2)
      @fake_perf3 = performances(:MyPerf3)
      @fake_perf2.scheduled = false;
      
      ret = controller.remove_unscheduled([@fake_perf1, @fake_perf2, @fake_perf3])
      expect(ret).to eq ([@fake_perf1, @fake_perf3])
    end
  end
  
  describe "#form_schedule" do
    fixtures :schedules, :acts, :performances
    before :each do
      @ordered_before = {}
      controller.instance_variable_set(:@ordered_performances, @ordered_before)
      @unscheduled_before = {}
      controller.instance_variable_set(:@unscheduled_performances, @unscheduled_before)
      @conflicts_before = {}
      controller.instance_variable_set(:@conflicts, @conflicts_before)
      @fake_schedule = schedules(:MySchedule)
      controller.instance_variable_set(:@schedule, @fake_schedule)
    end
    
    context "Conflicts do not need to be generated" do
      before :each do
        # So that we have some unscheduled ones
        @fake_schedule.acts[0].performances[0].scheduled = false
        @fake_schedule.acts[1].performances[0].scheduled = false
        controller.form_schedule(false)
      end
      
      it 'should order the performances in a special variable' do
        @ordered_after = controller.instance_variable_get(:@ordered_performances)
        expect(@ordered_after.keys).to eq [1, 2]
        [1,2].each do |idx|
          @ordered_after[idx].each do |perf|
            expect(perf.scheduled)
          end
        end
        expect(@ordered_after[1]).to eq @ordered_after[1].sort_by {|p| p.position}
        expect(@ordered_after[2]).to eq @ordered_after[2].sort_by {|p| p.position}
      end
      
      it 'should collect the unscheduled performances as well' do
        @unscheduled_after = controller.instance_variable_get(:@unscheduled_performances)
        expect(@unscheduled_after.keys).to eq [1, 2]
        [1,2].each do |idx|
          @unscheduled_after[idx].each do |perf|
            expect(!perf.scheduled)
          end
        end
        expect(@unscheduled_after[1]).to eq @unscheduled_after[1].sort_by {|p| p.position}
        expect(@unscheduled_after[2]).to eq @unscheduled_after[2].sort_by {|p| p.position}
      end
    end
    
    context "If conflicts need to be generated" do
      before :each do
        allow(controller).to receive(:conflicts).and_return(["Me", "You"])
        controller.form_schedule(true)
      end
      
      it 'should generate those conflicts' do
        controller.form_schedule(true)
        @conflicts_after = controller.instance_variable_get(:@conflicts)
        expect(@conflicts_after.keys).to eq [1,2]
        expect(@conflicts_after[1].length).to eq 2
        expect(@conflicts_after[2].length).to eq 2
      end
    end
  end
  
  describe "#init_schedule" do
    it 'should set all the variables used to empty' do
      controller.init_schedule
      expect(controller.instance_variable_get(:@ordered_performances).length).to eq 0
      expect(controller.instance_variable_get(:@conflicts).length).to eq 0
      expect(controller.instance_variable_get(:@conflicting_performances).length).to eq 0
      expect(controller.instance_variable_get(:@unscheduled_performances).length).to eq 0
    end
  end
  
  describe "#minimize_schedule" do
    it 'should both minimize the schedule and reform the ordered performances for the view' do
      expect(controller.helpers).to receive(:minimize_conflicts)
      expect(controller).to receive(:form_schedule).with(true)
      controller.minimize_schedule
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
      it 'should simply initialize and order the performances' do
        allow(Schedule).to receive(:find).and_return(@fake_schedule)
        expect(controller).to receive(:init_schedule)
        expect(controller).to receive(:form_schedule).with(true)
        expect(controller).not_to receive(:minimize_schedule)
        get :edit, params: {id: @fake_schedule.id}
      end
    end
    
    context "We came from the a page that wants us to minimize" do
      it 'should generate a random schedule using the helper' do
        allow(Schedule).to receive(:find).and_return(@fake_schedule)
        expect(controller).to receive(:init_schedule)
        expect(controller).to receive(:form_schedule).with(false)
        expect(controller).to receive(:minimize_schedule).exactly(:once)
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
      @correct_csv = %{Act 1,Act 1 conflicts,Act 2,Act 2 conflicts\n#{@fake_perf1.name},"Troy, Jeevika",#{@fake_perf4.name}\n#{@fake_perf2.name},Divia,#{@fake_perf5.name}\n#{@fake_perf3.name}\n}
    end

    after :each do
      controller.instance_variable_set(:@conflicts, @conflicts_hash)
      post :export, :params => {"id" => @fake_schedule.id }, :flash => { "conflicts" => @conflicts_hash, "ordered_performances" => @performances, "conflicting_performances" => @conflicting_performances}
    end

    it 'should convert the performances and conflicts into CSV formatted string' do
      expect(Schedule).to receive(:to_csv).and_return(@correct_csv)
    end
  end

  
  describe "#minimize" do
    it 'should redirect back to edit with the flash set' do
      get :minimize, params: {:id => 100}
      expect(controller).to set_flash[:minimize]
      expect(subject).to redirect_to(:controller => "schedules", 
                                     :action => "edit", 
                                     :id => 100)
    end
  end
  
  describe "#delete" do
    fixtures :schedules, :acts, :performances, :dances, :dancers
    
    context "schedule can't be found" do
      it 'should redirect to the root page with the following notice' do
        allow(Schedule).to receive(:find).and_return(nil)
        post :delete, params: {id: -1}
        
        expect(subject).to redirect_to(schedules_path)
        expect(controller).to set_flash[:notice]
        expect(flash[:notice]).to eq "Schedule with id -1 could not be found."
      end
    end

    context "schedule is found" do
      before :each do
        @schedule = schedules(:MySchedule)
        @acts = acts(:MyAct1,:MyAct2)
        @performances = performances(:MyPerf1,:MyPerf2,:MyPerf3,:MyPerf4,:MyPerf5,:MyPerf6,:MyPerf7,:MyPerf8)
        @dances = dances(:MyDance1,:MyDance2,:MyDance3,:MyDance4,:MyDance5,:MyDance6,
                          :MyDance7,:MyDance8,:MyDance9,:MyDance10,:MyDance11,:MyDance12,
                          :MyDance13,:MyDance14,:MyDance15,:MyDance16,:MyDance17)
      end
    
      it 'should find the schedule by the schedule id' do
        expect(Schedule).to receive(:find).with(@schedule.id.to_s)  
        post:delete, params: {id: @schedule.id.to_i}
      end
      
      it 'should delete all of the dancers' do
        post:delete, params: {id: @schedule.id.to_i}
        @dances.each do |dance|
          expect(dance.dancer).to be(nil)
          #expect { Dancer.find(dance.dancer.id) }.to raise_exception(ActiveRecord::RecordNotFound)
          #dance.dancer is nil so we cannot do this one like the others
        end
      end
      
      it 'should delete all of the dances' do
        post:delete, params: {id: @schedule.id.to_i}
        @dances.each do |dance|
          #expect(Dance.find(dance.id)).to raise_exception(ActiveRecord::RecordNotFound)
          expect { Dance.find(dance.id) }.to raise_exception(ActiveRecord::RecordNotFound)
        end
      end
      
      it 'should delete all of the performances' do
        post:delete, params: {id: @schedule.id.to_i}
        @performances.each do |performance|
          expect { Performance.find(performance.id) }.to raise_exception(ActiveRecord::RecordNotFound)
        end
      end
      
      it 'should delete all of the acts' do
        post:delete, params: {id: @schedule.id.to_i}
        @acts.each do |act|
          expect { Act.find(act.id) }.to raise_exception(ActiveRecord::RecordNotFound)
        end
      end
      
      it 'should delete the schedule' do
          post:delete, params: {id: @schedule.id.to_i}
          expect { Schedule.find(@schedule.id) }.to raise_exception(ActiveRecord::RecordNotFound)
      end
      
      
    end
  end
  
  describe '#reindex' do
    fixtures :performances
    
    before :each do 
      @fake_perf1 = performances(:MyPerf1)
      @fake_perf2 = performances(:MyPerf2)
      @fake_perf3 = performances(:MyPerf3)
      @fake_perf1.position = 1
      @fake_perf2.position = 2
      @fake_perf3.position = 3
    end
    
    it 'should shift positions attribute down 1 after remove' do
      @fake_perf1.scheduled = false;
      expect @fake_perf2.position == 1
      expect @fake_perf3.position == 2
    end
    
    after :each do
      #updates when dance is rescheduled
      @fake_perf1.scheduled = true;
      expect @fake_perf1.position == 1
      expect @fake_perf2.position == 2
      expect @fake_perf3.position == 3
    end
  end
end
