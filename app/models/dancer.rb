class Dancer < ActiveRecord::Base
  has_many :dances
  has_many :performances, through :dances
end
