class Performance < ActiveRecord::Base
  belongs_to :act
  has_many :dances
  has_many :dancers, through: :dances
  
  def self.delete_performance(performance) 
    performance.dances.each do |dance|
      Dance.delete(dance)
      Dancer.delete(dance.dancer)
    end
    Performance.delete(performance)
  end
end
