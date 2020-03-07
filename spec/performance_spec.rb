require_relative './rails_helper.rb'
require_relative '../app/models/performance.rb'

describe Performance, type: :model do 
    it 'has a act it belongs to' do
        should belong_to(:act)
    end
    it 'has many dances it belongs to' do
        should have_many(:dances)
    end
    it 'has many dancers it belongs to' do
        should have_many(:dancers)
    end
end