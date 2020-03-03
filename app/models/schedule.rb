class Schedule < ActiveRecord::Base
    # Nothing for now, other than a has_many relationship with dances
    has_many :dances
end
