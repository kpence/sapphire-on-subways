class Performance < ActiveRecord::Base
  belongs_to :act
  has_many :dances
  has_many :dancers, through: :dances
  
  @dancers_data = []
  @dances_data = []
  def self.delete_performance(performance) 
    performance.dances.each do |dance|
      if dance.dancer != nil
        Dancer.destroy(dance.dancer.id)
      end
      Dance.destroy(dance.id)
    end
    Performance.destroy(performance.id)
  end
end
