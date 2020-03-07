require_relative './rails_helper.rb'
require_relative '../app/models/act.rb'

describe Act, type: :model do 
    it 'has a schedule it belongs to' do
        should belong_to(:schedule)
    end
    it 'has many performances it belongs to' do
        should have_many(:performances)
    end
end