require 'rails_helper'

describe PerformancesController do
  describe "#sort" do
    fixtures :performances, :acts
    before :each do
      @fake_perf1 = performances(:MyPerf1)
      @fake_perf2 = performances(:MyPerf2)
      @fake_perf3 = performances(:MyPerf3)
      @fake_act = acts(:MyAct1)
      @fake_performances = [@fake_perf2, @fake_perf3, @fake_perf1]
      allow(Performance).to receive(:find).and_return(@fake_perf1)
      allow(Act).to receive(:find).and_return(@fake_act)
    end

    it 'should update all the performances positions by id' do
      @fake_performances.each_with_index do |perf, index|
        expect(Performance).to receive(:where).with({id: perf.id.to_i}).at_least(:once).and_return(perf)
        expect(perf).to receive(:update).with(position: index + 1)
      end
      expect(@fake_perf2).to receive(:update).with(act_id: 1)
      put :sort, {params: {:performance => @fake_performances.map{|p|p.id}, :move_perf => @fake_perf2.id, :act_id => 1}}
    end

    it 'should correctly update the act of the moved performance' do
      @fake_performances.each_with_index do |perf, index|
        expect(Performance).to receive(:where).with({id: perf.id.to_i}).at_least(:once).and_return(perf)
        expect(perf).to receive(:update).with(position: index + 1)
      end
      expect(@fake_perf2).to receive(:update).with(act_id: 2)
      put :sort, {params: {:performance => @fake_performances.map{|p|p.id}, :move_perf => @fake_perf2.id, :act_id => 2}}
    end
  end
  
  describe '#create' do
    fixtures :schedules, :acts, :performances
    
    context "bad data (empty performance name)"  do
      before :each do
        @fake_schedule = schedules(:MySchedule)
        @fake_act1 = @fake_schedule.acts[0]
      end
      
      it 'should not create a new performance' do
        expect(Performance).not_to receive(:create!)
      end
      
      #Pass in real data expect for the name to simulate something that would really happen in our app
      subject { post :create, params: {act_id: @fake_act1.id, 
                                      new_performance_name: "", 
                                      position: @fake_act1.performances.length,
                                      schedule_id: @fake_schedule.id
      } }
      after:each do
        expect(subject).to redirect_to(edit_schedule_path(id: @fake_schedule.id))
        subject
      end
      
    end
    
    context "good data" do
      before :each do
        @fake_schedule = schedules(:MySchedule)
        @fake_act1 = @fake_schedule.acts[0]
      end
      
      subject { post :create, params: {act_id: @fake_act1.id, 
                                      new_performance_name: "InsertPerformance1", 
                                      position: @fake_act1.performances.length,
                                      schedule_id: @fake_schedule.id
      } }
      after:each do
        expect(subject).to redirect_to(edit_schedule_path(id: @fake_schedule.id))
        subject
      end
  
      #Insert should only be available if a schedule has been loaded in, so we can assume a schedule has been loaded already
      it 'should create a new performance' do
        #It's not important what it is supposed to return. Only what it should be called with
        expect(Performance).to receive(:create!).with(name: "InsertPerformance1", act_id: @fake_act1.id, scheduled: true,
                                                      position: @fake_act1.performances.length, locked: false)
      end
    
    end

  end
  
  describe '#remove' do 
    fixtures :schedules, :acts, :performances
    
    before :each do 
      @fake_performance = performances(:MyPerf1)
      #@original_scheduled_value = @fake_performance.scheduled
      @fake_schedule_removed_from = schedules(:MySchedule)
    end
    
    it 'should change scheduled attribute to false' do
      post :remove, params: {performance_id: @fake_performance.id, new_performance_name: "MyPerf1", position: 4, schedule_id: @fake_schedule_removed_from.id}
      expect @fake_performance.scheduled == false
    end
    
    it 'should change position attribute to -1' do
      post :remove, params: {performance_id: @fake_performance.id, new_performance_name: "MyPerf1", position: 4, schedule_id: @fake_schedule_removed_from.id}
      expect @fake_performance.position == -1
    end
  end

  describe '#lock' do
    fixtures :schedules, :acts, :performances
    
    before :each do
      @fake_performance = performances(:MyPerf1)
      @fake_schedule = schedules(:MySchedule)
      @original_locked_value = @fake_performance.locked
    end
    
    it 'should flip the boolean of locked within the performance' do
      expect(Performance).to receive(:find).with(@fake_performance.id.to_i).at_least(:once).and_return(@fake_performance)
      expect(@fake_performance).to receive(:update!).with(locked: !@fake_performance.locked).and_call_original
      post :lock, {params: {:performance_id => @fake_performance.id}}
      expect(@fake_performance.locked).not_to be(@original_locked_value)
    end
  end
  
  describe '#revive' do 
    fixtures :schedules, :acts, :performances
    
    before :each do 
      @fake_performance = performances(:MyPerf1)
      @fake_schedule_removed_from = schedules(:MySchedule)
    end
    
    it 'should change scheduled attribute to true' do
      post :revive, params: {performance_id: @fake_performance.id, new_performance_name: "InsertPerformance1", position: 4, schedule_id: @fake_schedule_removed_from.id}
      expect @fake_performance.scheduled == true
    end
  end

end
