class Dance < ActiveRecord::Base
    belongs_to :performance
    belongs_to :dancer
end
