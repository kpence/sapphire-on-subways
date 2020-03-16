require 'rails_helper'

describe Act do
    it 'has a schedule it belongs to' do
        should belong_to(:schedule)
    end
    it 'has many performances it belongs to' do
        should have_many(:performances)
    end
    
    describe "#method" do
       it 'should do something'
    end
end