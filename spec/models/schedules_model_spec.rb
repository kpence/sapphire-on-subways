require 'rails_helper'
require 'database_cleaner/active_record'


describe Schedule do
  it 'should have many acts' do
    should have_many(:acts)
  end
    
  describe "#check_csv" do
    it 'should check if there is no file' do
      res = Schedule.check_csv(nil)
      expect(res).to eq(:no_file)
    end
        
    it 'should check if the CSV file is the right size (big enough)' do
      res = Schedule.check_csv(fixture_file_upload("random_test.csv", 'text/csv'))
      expect(res).to eq(:failed)
    end
    it 'should check if the CSV file is the correct format' do
      res = Schedule.check_csv(fixture_file_upload("1_col_data_test.csv", 'text/csv'))
      expect(res).to eq(:failed)
    end
    it 'should give "success" on a correct file' do
      res = Schedule.check_csv(fixture_file_upload("good_data_test.csv", 'text/csv'))
      expect(res).to eq(:success)
    end
  end
  
  describe "#min_csv_size?" do
    context "csv size is not right" do
      after :each do
        csv = CSV.read(@file.path, headers: false)
        res = Schedule.min_csv_size?(csv)
        expect(res).to eq(false)
      end
      
      it 'should return false when there are not enough rows' do
        @file = fixture_file_upload("1_row_data_test.csv", 'text/csv')
      end
      it 'should return false when there are not enough columns' do
        @file = fixture_file_upload("1_col_data_test.csv", 'text/csv')
      end
    end
    it 'should return true when the dimensions are correct' do
      file = fixture_file_upload("good_data_test.csv", 'text/csv')
      csv = CSV.read(file.path, headers: false)
      res = Schedule.min_csv_size?(csv)
      expect(res).to eq(true)
    end
    it 'should return false if given a nil argument' do
      res = Schedule.min_csv_size?(nil)
      expect(res).to eq(false)
    end
  end
  
  describe "#correct_csv_format?" do
    context "not correct format" do
      after :each do
        csv = CSV.read(@file.path, headers: false)
        res = Schedule.correct_csv_format?(csv)
        expect(res).to eq(false)
      end
      
      it 'should return false when the csv row sizes do not match the header' do
        @file = fixture_file_upload("bad_data_test.csv", 'text/csv')
      end
      it 'should return false when the csv does not have the correct format' do
        @file = fixture_file_upload("bad_symbols_test.csv", 'text/csv')
      end
    end
    it 'should return true when the csv has the right format' do
      file = fixture_file_upload("good_data_test.csv", 'text/csv')
      csv = CSV.read(file.path, headers: false)
      res = Schedule.correct_csv_format?(csv)
      expect(res).to eq(true)
    end
  end
  
  describe "#read_csv" do
    before :each do
      @file = fixture_file_upload("good_data_test.csv", 'text/csv')
      @fake_csv_data = CSV.read(@file, headers: true)
    end
  
    it 'should read the file into a csv' do
      expect(CSV).to receive(:read).and_return(@fake_csv_data)
      Schedule.read_csv(@file)
    end
    it 'should put the csv data into the expected format' do
      res = Schedule.read_csv(@file)
      expect(res.keys).to eq([:performance_names, :dancer_hashes])
    end
  end
  
  describe "#generate_performances" do
    fixtures :dancers, :acts, :performances, :schedules, :dances
    before :each do
      # Mock data complex enough to really test the function
      # This data is all found in the fixtures
      @fake_schedule = schedules(:MySchedule)
      @act1_id = acts(:MyAct1).id
      @act2_id = acts(:MyAct2).id
      
      @perfs = []
      @fake_schedule.acts.each do |act|
        @perfs += act.performances
      end
      
      @fake_performances = @perfs.map {|p| p.name}
    end
    after :each do
      @fake_schedule.generate_performances(@fake_performances, @act1_id, @act2_id)
    end
    
    it 'should use the length of the list to decide whether or not to split' do
      allow(Performance).to receive(:create!).exactly(@fake_performances.length()).times
      expect(@fake_performances).to receive(:length).and_call_original
    end
    
    context "There are enough data to put into 2 acts" do
      it 'should insert half of the performances in each act' do
        num_half_performances = @fake_performances.length/2
        expect(Performance).to receive(:create!).with(hash_including :act_id => @act1_id)
            .exactly(num_half_performances).times
        expect(Performance).to receive(:create!).with(hash_including :act_id => @act2_id)
            .exactly(num_half_performances).times
      end
    end
    
    context "Small Enough Data not to put all in act 1" do
      # Take out performances 7 and 8 (no one performs in them anyways)
      before :each do
        @fake_performances.each_with_index do |perf, i|
          if perf == "MyPerf7" || perf == "MyPerf8"
            @fake_performances -= [perf]
          end
        end
      end
      
      it 'should insert all of the performances in act 1' do
        expect(Performance).to receive(:create!).with(hash_including :act_id => @act1_id)
            .exactly(@fake_performances.length).times
      end
    end
  end
  
  describe "#get_performance" do
    fixtures :schedules, :acts, :performances, :dances
    before :each do
      @fake_schedule = schedules(:MySchedule)
      @act1_id = acts(:MyAct1).id
      @act2_id = acts(:MyAct2).id
      @fake_perf1 = performances(:MyPerf1)
      @fake_perf4 = performances(:MyPerf4)
      
      @fake_dance_name = "" # Changed for each test
    end
    
    context "Assuming the performance is in act 1" do
      before :each do
        allow(Performance).to receive(:find_by).and_return(@fake_perf1)
      end
      
      it 'should not return nil' do
        ret = @fake_schedule.get_performance(@fake_dance_name, @act1_id, @act2_id)
        expect(ret).not_to eq nil
      end
      
      it 'should clear the whitespace on the name' do
        # lstrip is good enough
        expect(@fake_dance_name).to receive(:lstrip).and_call_original
        @fake_schedule.get_performance(@fake_dance_name, @act1_id, @act2_id)
      end
    end
    
    context "Performance exists with the given name" do
      after :each do
        @fake_schedule.get_performance(@fake_dance_name, @act1_id, @act2_id)
      end
      
      it 'should find act 1 performances in act 1' do
        @fake_dance_name = @fake_perf1.name
        expect(Performance).to receive(:find_by).with(hash_including act_id: @act1_id)
                              .and_return(@fake_perf1)
        expect(Performance).not_to receive(:find_by).with(hash_including act_id: @act2_id)
      end
      
      it 'should find act 2 performances in act 2 after checking act 1' do
        @fake_dance_name = @fake_perf4.name
        expect(Performance).to receive(:find_by).with(hash_including act_id: @act1_id)
        expect(Performance).to receive(:find_by).with(hash_including act_id: @act2_id)
      end
    end
  end
  
  describe "#generate_dances_and_dancers" do
    fixtures :dances, :dancers, :acts, :performances, :schedules
    before :each do
      # Mock data complex enough to really test the function
      # This data is all found in the fixtures
      @fake_schedule = schedules(:MySchedule)
      @act1_id = acts(:MyAct1).id
      @act2_id = acts(:MyAct2).id
      
      # There are 6 dancers to accound for here. Since they do not belong to
      # a performance, we have to instantiate them here
      @fake_dancers = []
      (1..6).each do |num|
        dancer_string = "MyDancer" + num.to_s
        dancer = dancers(dancer_string.to_sym)
        @fake_dancers.append(dancer)
      end
      
      @perfs = []
      @fake_schedule.acts.each do |act|
        temp_perfs = []
        act.performances.each { |p|
          if p.name != "InsertPerformance1"
            temp_perfs.append(p)
          end
        }
        @perfs += temp_perfs
      end
      
      @fake_dancer_hashes = []
      @fake_dances = []
      @fake_performances = []
      
      @fake_dancers.each do |dancer|
        perf_names = []
        dancer.dances.each do |dance|
          @fake_dances.append(dance)
          perf_id = dance.performance_id
          # Find that performance in our convenient list
          @perfs.each do |perf|
            if perf.id == perf_id
              perf_names.append(perf.name)
              @fake_performances.append(perf)
              break
            end
          end
        end
        @fake_dancer_hashes.append({:name => dancer.name, :dances => perf_names})
      end
      
      @fake_performances.each do |perf|
        allow(@fake_schedule).to receive(:get_performance)
                          .with(perf.name, @act1_id, @act2_id).and_return(perf)
      end
    end
    after :each do
      @fake_schedule.generate_dances_and_dancers(@fake_dancer_hashes, @act1_id, @act2_id)
    end
    
    it 'creates all the dancers by name only' do
      allow(Dance).to receive(:create!).exactly(@fake_dances.length).times
      
      @fake_dancers.each do |dancer|
        expect(Dancer).to receive(:create!).with(name: dancer.name).and_return(dancer)
      end
    end
    
    it 'creates all the dances by dancer and performance ids' do
      @fake_dancers.each do |dancer|
        allow(Dancer).to receive(:create!).with(name: dancer.name).and_return(dancer)
      end
      
      @fake_dances.each do |dance|
        expect(Dance).to receive(:create!).with(
            performance_id: dance.performance_id, dancer_id: dance.dancer_id)
      end
    end
  end
  
  describe "#import" do
    fixtures :acts, :performances, :schedules
    before :each do
      # No need for this to be real data:
      @fake_schedule = schedules(:MySchedule)
      @act1_id = acts(:MyAct1).id
      @act2_id = acts(:MyAct2).id
      
      @fake_schedule_params = {
        :performance_names => ["one"],
        :dancer_hashes => ["one", "two"]
      }
      @act1 = acts(:MyAct1)
      @act2 = acts(:MyAct2)
    end
    after :each do
      @fake_schedule.import(@fake_schedule_params)
    end
    
    it 'should find acts 1 and 2' do
      allow(@fake_schedule).to receive(:generate_performances)
      allow(@fake_schedule).to receive(:generate_dances_and_dancers)
      
      expect(Act).to receive(:find_by).with(hash_including number: 1).and_return(@act1)
      expect(Act).to receive(:find_by).with(hash_including number: 2).and_return(@act2)
    end
    
    it 'should generate new performances, dances, and dancers based on the hash' do
      allow(Act).to receive(:find_by).with(hash_including number: 1).and_return(@act1)
      allow(Act).to receive(:find_by).with(hash_including number: 2).and_return(@act2)
      
      expect(@fake_schedule).to receive(:generate_performances)
          .with(@fake_schedule_params[:performance_names], @act1_id, @act2_id)
      expect(@fake_schedule).to receive(:generate_dances_and_dancers)
          .with(@fake_schedule_params[:dancer_hashes], @act1_id, @act2_id)
    end
  end

  describe "#to_csv" do
    fixtures :acts, :schedules, :performances
    before :each do
      @fake_schedule = schedules(:MySchedule)
      @fake_perf1 = performances(:MyPerf1)
      @fake_perf2 = performances(:MyPerf2)
      @fake_perf3 = performances(:MyPerf3)
      @fake_perf4 = performances(:MyPerf4)
      @fake_perf5 = performances(:MyPerf5)
      @performances = { "1" => [@fake_perf1.id.to_s, @fake_perf2.id.to_s, @fake_perf3.id.to_s], "2" => [@fake_perf4.id.to_s, @fake_perf5.id.to_s] }
      @conflicting_performances = [ @fake_perf1.id.to_s, @fake_perf2.id.to_s ]

      @conflicts_hash = {
        "1" => [
          {:first_performance => @fake_perf1.name, :second_performance => @fake_perf2.name, :dancers => ["Troy", "Jeevika"]},
          {:first_performance => @fake_perf2.name, :second_performance => @fake_perf3.name, :dancers => ["Divia"]},
        ],
        "2" => [
          {:first_performance => @fake_perf4.name, :second_performance => @fake_perf5.name, :dancers => []}
        ]
      }
      @correct_csv = %{Act 1,Act 1 conflicts,Act 2,Act 2 conflicts\n#{@fake_perf1.name},"Troy, Jeevika",#{@fake_perf4.name},\n#{@fake_perf2.name},Divia,#{@fake_perf5.name},\n#{@fake_perf3.name},,,\n}
    end

    it 'should put the performances list with the conflict list in the correct CSV format' do
      expect(Schedule.to_csv(@performances, @conflicts_hash, @conflicting_performances)).to eq(@correct_csv)
    end
  end
end
