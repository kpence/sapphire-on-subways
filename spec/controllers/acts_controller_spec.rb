require 'rails_helper'

describe ActsController do
    describe "#method" do
       it 'should do something' do
          expect(Act).to receive(:something) 
       end
    end
end