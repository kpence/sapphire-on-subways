require_relative './rails_helper.rb'
require_relative '../app/models/dance.rb'

describe Dance, type: :model do 
    it 'has a performance it belongs to' do
        should belong_to(:performance)
    end
    it 'has a dancers it belongs to' do
        should belong_to(:dancers)
    end
end