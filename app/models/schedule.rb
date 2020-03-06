class Schedule < ActiveRecord::Base
    require 'csv'
    require 'activerecord-import'

    # Nothing for now, other than a has_many relationship with dances
    has_many :acts

    def self.upload_a_csv(file)
        dances = []
        csv = CSV.read(file.path, headers: true)
        rows = csv[0].drop(2).select {|e| e[0] != "TOTAL" }.map {|e| e[0]}
        schedule = Schedule.create!(filename: file.path)
        act = Act.create!(number: 1, schedule_id: schedule.id)
        rows.each do |row|
            dances << Performance.new(name: row, act_id: act.id)
        end
        Performance.import dances, recursive: true

        # -- Below will import dancers
        #rows.drop(1).each do |row|
          #dancers << row.to_h.select {|entry| entry != "TOTAL" && entry != nil}
        #end

    end

end
