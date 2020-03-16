require 'rails_helper'

describe Dancer do
    it 'has many dances it belongs to' do
        should have_many(:dances)
    end
    it 'has many performances it belongs to' do
        should have_many(:performances)
    end
    
    describe "#method" do
       it 'should do something'
    end
end