class Schedule < ActiveRecord::Base
    require 'csv'
    require 'activerecord-import'

    # Nothing for now, other than a has_many relationship with dances
    has_many :acts

    def self.upload_a_csv(file)
        dances = []
        csv = CSV.read(file.path, headers: true)
        rows = csv[0].drop(2).select {|e| e[0] != "TOTAL" }.map {|e| e[0]}
        rows.each do |row|
            dances << Dance.new(name: row)
        end
        Dance.import dances, recursive: true

        # -- Below will import dancers
        #rows.drop(1).each do |row|
          #dancers << row.to_h.select {|entry| entry != "TOTAL" && entry != nil}
        #end

    end

end
