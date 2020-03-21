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
        after :each do
           @fake_schedule.import(@fake_schedule_params)
        end
        before :each do
           # Fake act
           @fake_act_1 = acts(:MyAct1)
           @fake_performance_1 = performances(:MyPerf1)
           @fake_performance_2 = performances(:MyPerf2)
           @fake_dancer = dancers(:MyDancer1)
           @fake_schedule = schedules(:MySchedule)
        
           
           # Fake dancer
           allow(Dancer).to receive(:create!).and_return(@fake_dancer)
           
           # Fake performance
           allow(Performance).to receive(:find_by_name).and_return(@fake_performance_1)
           
           allow(Dance).to receive(:create!).with(:performance_id => @fake_performance_1.id,
                                                  :dancer_id => @fake_dancer.id)
                                                   
           @fake_schedule_params = {:performance_names => ["MyPerf1", "MyPerf2"],
                                    :dancer_hashes => [{"name" => @fake_dancer.name, "dances" => ["MyPerf1", "MyPerf2"] }]
           }
        end

        it 'should look for act 1 and put all the performances in act 1' do
           expect(Act).to receive(:find_by_number).and_return(@fake_act_1)
           expect(Performance).to receive(:create!).with(hash_including :act_id => @fake_act_1.id).exactly(2).times
        end
        it 'should create each dancer and associate dancers with their dances' do
           expect(Dancer).to receive(:create!).with(hash_including :name => @fake_dancer.name)
                                               .exactly(1).times.and_return(@fake_dancer)
           expect(Dance).to receive(:create!).with(hash_including :dancer_id=> @fake_dancer.id).exactly(2).times

        end
        it 'should associate dances with the appropriate performance' do
           expect(Performance).to receive(:find_by_name).and_return(@fake_performance_1)
           expect(Performance).to receive(:find_by_name).and_return(@fake_performance_2)
           expect(Dance).to receive(:create!).with(hash_including :performance_id=>@fake_performance_1.id,
                                                :dancer_id=> @fake_dancer.id)
           expect(Dance).to receive(:create!).with(hash_including :performance_id=>@fake_performance_2.id,
                                                :dancer_id=> @fake_dancer.id)
        end
      end

end
