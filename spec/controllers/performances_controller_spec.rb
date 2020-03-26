require 'rails_helper'

describe PerformancesController do
  describe "#sort" do
    fixtures :performances
    before :each do
      @fake_perf1 = performances(:MyPerf1)
      @fake_perf2 = performances(:MyPerf2)
      @fake_perf3 = performances(:MyPerf3)
      @fake_performances = [@fake_perf2, @fake_perf3, @fake_perf1]
    end
    
    it 'should update all the performances positions by id' do
      @fake_performances.each_with_index do |perf, index|
        expect(Performance).to receive(:where).with({id: perf.id.to_s}).and_return(perf)
        expect(perf).to receive(:update).with(position: index + 1)
      end
      
      put :sort, {params: {:performance => @fake_performances}}
    end
  end
  
  describe '#create' do
    fixtures :schedules, :acts, :performances
    
    before :each do
      @new_fake_performance = performances(:InsertPerformance1)
      @fake_schedule_inserted_into = schedules(:MySchedule)
      edit_schedule_path(@fake_schedule_inserted_into.id)     
    end
    
    subject {edit_schedule_path(id: @fake_schedule_inserted_into.id)}
    after:each do
      expect(subject).to redirect_to(:controller => "schedules", 
                                     :action => "edit", 
                                     :id => @fake_schedule_inserted_into.id)
      subject
    end
    

    #Insert should only be available if a schedule has been loaded in, so we can assume a schedule has been loaded already
    
    it 'should create a new performance' do
      expect(Performance).to receive(:create!).and_return(@new_fake_performance)
      post :create, params: {act_id: 1, name: "InsertPerformance1", position: 4, scheduled: false, locked: false}
    end

  end
end