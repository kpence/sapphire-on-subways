require 'rails_helper'

describe DancersController do
    describe "#method" do
       it 'should do something' do
          expect(Dancer).to receive(:something) 
       end
    end
end