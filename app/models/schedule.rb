class Schedule < ActiveRecord::Base
    require 'csv'
    require 'activerecord-import'

    # Nothing for now, other than a has_many relationship with dances
    has_many :acts

    def self.upload_a_csv(file)
        schedule = Schedule.create!(filename: file.path)
        act = Act.create!(number: 1, schedule_id: schedule.id)
        Act.create!(number: 2, schedule_id: schedule.id)

        csv = CSV.read(file.path, headers: true)
        rows = csv[0].drop(2).select {|e| e[0] != "TOTAL" }.map {|e| e[0]}
        performances = []
        rows.each do |row|
            performances << Performance.new(name: row, act_id: act.id)
        end
        Performance.import performances, recursive: true

        # -- Below will import dances and dancers
        dances = []
        csv.drop(1).each do |row|
          hash = row.to_h.select {|entry| entry != "TOTAL" && entry != nil}
          unless hash["Active Members"] == nil
            dancer = Dancer.create!(name: hash["Active Members"])
            hash.drop(1).each { |key,value| dances << Dance.new(performance_id: Performance.find_by_name(key).id, dancer_id: dancer.id) }
          end
        end
        Dance.import dances, recursive: true

    end

end
