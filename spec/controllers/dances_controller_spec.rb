require 'rails_helper'

describe DancesController do
    describe "#method" do
       it 'should do something' do
          expect(Dance).to receive(:something) 
       end
    end
end