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
end