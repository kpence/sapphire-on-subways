require_relative './rails_helper.rb'
require_relative '../app/models/dancer.rb'

describe Dancer, type: :model do 
    it 'has many dances it belongs to' do
        should have_many(:dances)
    end
end