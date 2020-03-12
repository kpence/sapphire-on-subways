class Schedule < ActiveRecord::Base
    require 'csv'
    require 'activerecord-import'

    has_many :acts

    # Loads a file and returns status about whether it is a validly formatted csv file
    def self.check_csv(file)
      if file == nil
        return :no_file
      end

      begin
        csv = CSV.read(file.path, headers: false)
      rescue CSV::MalformedCSVError
        return :failed
      end

      # If the csv file is empty
      if csv == nil || csv.first == nil
        return :failed
      end

      minimum_dances = 1
      minimum_dancers = 1

      num_cols = csv.first.length

      # CSV must have (Minimum # of Performers) + 2 or more rows
      if csv.length < minimum_dancers + 2
        return :failed

      # CSV must have (Minimum # of Dances) + 2 or more columns
      elsif num_cols < minimum_dances + 2
        return :failed

      # First column must be "Active Members"
      elsif csv[0][0] != "Active Members"
        return :failed
      end

      # Cells after the second column and after the second row must be either Blank or x
      csv.drop(2).each do |row|
        if row.length != num_cols
          return :failed
        end
        boolmap = row.first(row.size-1).drop(2).map { |e| e != nil && e != 'x' }
        if boolmap.any?
          puts row.drop(2)
          return :failed
        end
      end

      # Valid csv format
      return :success
    end


    # Read csv: loads a csv file and returns an object that will get passed to the import method
    def self.read_csv(file)
        csv = CSV.read(file.path, headers: true)
        performance_names = csv[0].drop(2).select {|e| e[0] != "TOTAL" }.map {|e| e[0]}

        hashes = csv.drop(1).map do |row|
          row.to_h.select do |entry|
            entry != "TOTAL" && entry != nil
          end
        end

        filtered_hashes = hashes.select {|hash| hash["Active Members"] != nil }

        return { performance_names: performance_names, dancer_hashes: filtered_hashes }
    end


    # Creates new schedule and imports data from CSV into it
    def self.upload_csv(file)
        schedule = Schedule.create!(filename: file.path)
        act = Act.create!(number: 1, schedule_id: schedule.id)
        Act.create!(number: 2, schedule_id: schedule.id)

        schedule.import(self.read_csv(file), 1)
    end


    # Imports schedule parameters in bulk from schedule params object ( performance_names, dancer_hashes )
    def import(schedule_params, act_number)
        performances = []
        schedule_params[:performance_names].each do |name|
          performances << Performance.new(name: name,
                                  act_id: Act.find_by_number(act_number).id)
        end
        Performance.import performances, recursive: true

        # Below imports dances and dancers
        dances = []
        schedule_params[:dancer_hashes].each do |hash|
          dancer = Dancer.create!(name: hash["Active Members"])
          hash.drop(1).each do |key,value|
            dances << Dance.new(performance_id: Performance.find_by_name(key).id,
                                dancer_id: dancer.id)
          end
        end
        Dance.import dances, recursive: true

    end

end
