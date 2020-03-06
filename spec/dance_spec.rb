require_relative './rails_helper.rb'
require_relative '../app/models/dance.rb'

describe Dance, type: :model do 
    it 'has a schedule it belongs to' do
        should belong_to(:schedule)
    end
    it 'has dancers and belongs to dancers' do
        should have_and_belong_to_many(:dancers)
    end
end