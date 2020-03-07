require_relative './rails_helper.rb'
require_relative '../app/models/schedule.rb'

describe Schedule, type: :model do 
    it 'has many acts' do
        should have_many(:acts)
    end
end