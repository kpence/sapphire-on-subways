class Dancer < ActiveRecord::Base
    has_and_belongs_to_many :dancers
end
