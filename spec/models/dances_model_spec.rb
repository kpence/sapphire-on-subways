require 'rails_helper'

describe Dance do
    it 'has a performance it belongs to' do
        should belong_to(:performance)
    end
    it 'has a dancer it belongs to' do
        should belong_to(:dancer)
    end
    
    describe "#method" do
       it 'should do something'
    end
end