class Schedule < ActiveRecord::Base
  require 'csv'
  require 'activerecord-import'

  has_many :acts

  # Some static properties of the csv file, like how many headers there are
  @@min_dances = 1
  @@min_dancers = 1
  @@min_header_cols = 2 # for "name" and "email"
  @@min_header_rows = 2 # for Performance Titles and Total dancers in each performance
  @@possible_symbols = ['x', 'X', nil]
  @@dancer_name_col_header = "Active Members"

  # Loads a file and returns status about whether it is a validly formatted csv file
  # Returns a status code as a symbol in:
  # [:no_file, :success, :failure]
  def self.check_csv(file)
    if file == nil
      return :no_file
    end

    begin
      csv = CSV.read(file.path, headers: false)
    rescue CSV::MalformedCSVError
      return :failed
    end
    
    if !self.min_csv_size?(csv) || 
       !self.correct_csv_format?(csv)
      return :failed
    end
    
    return :success
  end
    
  def self.min_csv_size?(csv)
    if csv == nil || csv.first == nil
      return false
    end
    
    num_cols = csv.first.length
    num_rows = csv.length
    
    
    # CSV must have these dimensions at a minimum
    if num_rows < @@min_header_rows + @@min_dancers
      return false
    elsif num_cols < @@min_header_cols + @@min_dances
      return false
    end
    
    return true
  end

  # Check simple features in csv, such as use of 'x' and '' and "Active Members"
  def self.correct_csv_format?(csv)
    #if csv[0][0] != @@dancer_name_col_header
    #  return false
    #end

    # Check that each row has the same number of columns
    num_cols = csv.first.length
    csv.drop(2).each do |row|
      if row.length != num_cols
        return false
      end
    end
    
    # Cells after the second column and after the second row (except the last row) 
    # Must be one of the predefined symbols
    csv.drop(2).each do |row|
      cells_of_interest = row.first(row.size-1).drop(@@min_header_cols)
      boolmap = cells_of_interest.map { |e| !@@possible_symbols.include? e }
      if boolmap.any?
        return false
      end
    end
    
    return true
  end

  # Loads a csv file and returns an object that will get passed to the import method
  # Returns a hash with 2 keys:
  # :performance_names => list of names
  # :dancer_hashes => list of hashes for dancers with the following keys:
  #                   :name => name of dancer
  #                   :dances => list of performances dancer appears in
  def self.read_csv(file)
    csv = CSV.read(file.path, headers: true)
    
    # Performance names are in row 1, all columns except the first 2 and last
    cells_of_interest = csv[0].first(csv[0].size-1).drop(@@min_header_cols)
    # Since csv[0] includes the first two rows, isolate the name:
    performance_names = cells_of_interest.map {|e| e[0]}

    # Drop the second header row and choose all the dances the dances has an "x" under
    dancer_hashes = csv.drop(1).map do |row|
      clean_row = row.to_h.select do |key|
        key != "TOTAL" && 
        key != nil && 
        row.to_h[key] != nil
      end
      clean_row unless clean_row.empty?
    end.compact
    
    # Now, dancer_hashes is a list of hashes like:
    # {"Active Members"=>"Joe Smith", "Lost Without You"=>"x",...}
    
    # Convert the format of the hash to something more readable:
    # {"name": "Joe Smith", "dances": ["Lost Without You",...] }
    # With just these two predictable keys
    dancer_hashes = dancer_hashes.map do |dancer_hash|
      new_dancer_hash = {}
      new_dancer_hash[:name] = dancer_hash[@@dancer_name_col_header]
      new_dancer_hash[:dances] = dancer_hash.select do |entry|
        performance_names.include? entry
      end.keys
      
      new_dancer_hash
    end

    return { performance_names: performance_names, dancer_hashes: dancer_hashes }
  end
  
  def generate_performances(performance_names, act1_id, act2_id)
    total_performances = performance_names.length()
    should_split = total_performances > 7
    performance_names.each_with_index do |name, index|
      if should_split
        act_id = (index + 1) <= (total_performances / 2) ? act1_id : act2_id
      else
        act_id = act1_id
      end
      Performance.create!(name: name.lstrip.rstrip, act_id: act_id,
                          scheduled: true, position: index+1,
                          locked: false)
    end
  end
  
  def get_performance(dance_name, act1_id, act2_id)
    performance = Performance.find_by(name: dance_name.lstrip.rstrip, act_id: act1_id)
    if performance == nil
      performance = Performance.find_by(name: dance_name.lstrip.rstrip, act_id: act2_id)
    end
    return performance
  end
  
  def generate_dances_and_dancers(dancer_hashes, act1_id, act2_id)
    # Create each dancer by name and insert each of their dances by name
    dancer_hashes.each do |dancer_hash|
      dancer = Dancer.create!(name: dancer_hash[:name])
      dancer_hash[:dances].each do |dance_name|
        performance = get_performance(dance_name, act1_id, act2_id)
        Dance.create!(performance_id: performance.id, dancer_id: dancer.id)
      end
    end
  end

  # Imports schedule parameters in bulk from schedule object returned by read_csv
  # by default, entire schedule is put into act 1
  def import(schedule_params)
    act1_id = Act.find_by(number: 1, schedule_id: self.id).id
    act2_id = Act.find_by(number: 2, schedule_id: self.id).id
    generate_performances(schedule_params[:performance_names], act1_id, act2_id)
    generate_dances_and_dancers(schedule_params[:dancer_hashes], act1_id, act2_id)
  end
  
  def self.remove_acts(schedule_id)
    schedule = Schedule.find(schedule_id)
    schedule.acts.each do |act|
      Act.delete_performances(act)
    end
  end

end
