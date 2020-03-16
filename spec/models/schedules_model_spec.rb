require 'rails_helper'

describe Schedule do
    it 'should have many acts' do
        should have_many(:acts)
    end
    
    describe "#method" do
        it 'should recognize a blank file'
        it 'should recognize a malformed file'
        it 'should reject a csv file with no headers'
        it 'should reject a csv file with only headers'
        it 'should accept a csv file with at least one dance and one dancer'
        # will need several more to get full coverage...
    end
end