class Act < ActiveRecord::Base
    belongs_to :schedule
    has_many :performances
end
