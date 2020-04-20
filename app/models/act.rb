class Act < ActiveRecord::Base
    belongs_to :schedule
    has_many :performances
    
    def self.delete_performances(act)
        act.performances.each do |performance|
            Performance.delete_performance(performance)
        end
        Act.delete(act)
    end
end
