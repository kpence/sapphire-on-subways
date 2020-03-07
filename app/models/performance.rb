class Performance < ActiveRecord::Base
    belongs_to :act
    has_many :dances
    has_many :dancers, through: :dances
end
