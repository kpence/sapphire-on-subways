require 'rails_helper'

describe Performance do
    it 'has a act it belongs to' do
        should belong_to(:act)
    end
    it 'has many dances it belongs to' do
        should have_many(:dances)
    end
    it 'has many dancers it belongs to' do
        should have_many(:dancers)
    end
    
    describe "#method" do
       it 'should do something'
    end
end