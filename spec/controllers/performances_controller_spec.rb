require 'rails_helper'

describe PerformancesController do
    describe "#method" do
       it 'should do something' do
          expect(Performance).to receive(:something) 
       end
    end
end