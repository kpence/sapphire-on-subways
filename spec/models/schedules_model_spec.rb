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
  
  describe "#import" do
    fixtures :dancers, :acts, :performances, :schedules
    before :each do
      # Mock data complex enough to really test the function
      @fake_act_1 = acts(:MyAct1)
      @fake_performance_1 = performances(:MyPerf1)
      @fake_performance_2 = performances(:MyPerf2)
      @fake_performance_3 = performances(:MyPerf3)
      @fake_dancer_1 = dancers(:MyDancer1)
      @fake_dancer_2 = dancers(:MyDancer2)
      @fake_schedule = schedules(:MySchedule)
      
      @fake_schedule_params =
      {:performance_names => [@fake_performance_1.name,
                              @fake_performance_2.name,
                              @fake_performance_3.name],
       :dancer_hashes => [
          {"name" => @fake_dancer_1.name,
           "dances" => [@fake_performance_1.name,
                        @fake_performance_2.name]
          },
          {"name" => @fake_dancer_2.name,
           "dances" => [@fake_performance_1.name,
                        @fake_performance_3.name]
          }
        ]
      }
    end
    after :each do
      @fake_schedule.import(@fake_schedule_params)
    end
    
    it 'should look for act 1 and put all the performances in act 1' do
      # First, stub out all the uninteresting functions for this test:
      allow(Dance).to receive(:create!)
      allow(Dancer).to receive(:create!).and_return(@fake_dancer_1, @fake_dancer_2)
      allow(Performance).to receive(:find_by_name).and_return(@fake_performance_1, 
                                                              @fake_performance_2,
                                                              @fake_performance_1,
                                                              @fake_performance_3)
      
      # Then, actually test this part:
      expect(Act).to receive(:find_by_number).and_return(@fake_act_1)
      num_perfs_act_1 = @fake_schedule_params[:performance_names].length()
      expect(Performance).to receive(:create!).with(hash_including :act_id => @fake_act_1.id)
                         .exactly(num_perfs_act_1).times
    end
    
    context "Act 1 is found and Performances are created" do
      before :each do
        allow(Act).to receive(:find_by_number).and_return(@fake_act_1)
        allow(Performance).to receive(:create!)
        allow(Dancer).to receive(:create!).and_return(@fake_dancer_1, @fake_dancer_2)
        allow(Performance).to receive(:find_by_name).and_return(@fake_performance_1, 
                                                                @fake_performance_2,
                                                                @fake_performance_1,
                                                                @fake_performance_3)
      end
      it 'should create each dancer associated with some dances' do
        num_dancer_1_dances = @fake_schedule_params[:dancer_hashes][0]["dances"].length()
        num_dancer_2_dances = @fake_schedule_params[:dancer_hashes][1]["dances"].length()
        
        # Dancer 1's fake dances:
        expect(Dance).to receive(:create!).with(hash_including :dancer_id => @fake_dancer_1.id)
                                          .exactly(num_dancer_1_dances).times
        # Dancer 2's fake dances:
        expect(Dance).to receive(:create!).with(hash_including :dancer_id => @fake_dancer_2.id)
                                          .exactly(num_dancer_2_dances).times
      end
      
      it 'should associate dances with the appropriate performance/dancer pair' do
        # Dancer 1's fake dances:
        expect(Dance).to receive(:create!).with(:performance_id => @fake_performance_1.id,
                                                :dancer_id => @fake_dancer_1.id)
        expect(Dance).to receive(:create!).with(:performance_id => @fake_performance_2.id,
                                                :dancer_id => @fake_dancer_1.id)
                                               
        # Dancer 2's fake dances:
        expect(Dance).to receive(:create!).with(:performance_id => @fake_performance_1.id,
                                               :dancer_id => @fake_dancer_2.id)
        expect(Dance).to receive(:create!).with(:performance_id => @fake_performance_3.id,
                                               :dancer_id => @fake_dancer_2.id)
      end
    end
  end
end
