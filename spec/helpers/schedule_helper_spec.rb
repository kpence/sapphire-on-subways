require "rails_helper"

describe ScheduleHelper do
  describe "#factorial" do
    it 'should work' do
      expect(helper.factorial(1)).to eq(1)
      expect(helper.factorial(5)).to eq(120)
      expect(helper.factorial(6)).to eq(720)
      expect(helper.factorial(7)).to eq(5040)
    end
  end
  
  describe "#intersect_by_dancer_id" do
    fixtures :dances, :dancers
    it 'should take the length of each list to see which one to use first' do
      @fake_list_a = [dances(:MyDance2), dances(:MyDance5), dances(:MyDance15)] # MyPerf2
      @fake_list_b = [dances(:MyDance1), dances(:MyDance13)] # MyPerf1
      expect(@fake_list_a).to receive(:length).and_call_original.exactly(2).times
      expect(@fake_list_b).to receive(:length).and_call_original.exactly(2).times
      expect(helper).to receive(:intersect_by_dancer_id)
            .and_call_original.exactly(2).times # with order flipped the second time
      helper.intersect_by_dancer_id(@fake_list_a, @fake_list_b)
    end
    
    context "It should find the intersection of the lists" do
      it 'should find the intersection when the intersection is nonempty' do
        @fake_list_a = [dances(:MyDance1), dances(:MyDance13)] # MyPerf1
        @fake_list_b = [dances(:MyDance2), dances(:MyDance5), dances(:MyDance15)] # MyPerf2
        res = helper.intersect_by_dancer_id(@fake_list_a, @fake_list_b)
        
        # Dance 1 and 2 are both dancer 1 (that is the only intersection)
        expect(res.length()).to eq(1)
        expect(res).to eq([dancers(:MyDancer1).name])
      end
      
      it 'should find the intersection when the intersection is empty' do
        @fake_list_a = [dances(:MyDance1), dances(:MyDance13)] # MyPerf1
        @fake_list_b = [dances(:MyDance9), dances(:MyDance11)] # MyPerf5
        res = helper.intersect_by_dancer_id(@fake_list_a, @fake_list_b)
        
        # Dance 1 and 2 are both dancer 1 (that is the only intersection)
        expect(res.length()).to eq(0)
        expect(res).to eq([])
      end
    end
  end
  
  describe "#count_conflicts" do
    fixtures :dances, :dancers
    before :each do
      @double1 = double('dance1')
      @double2 = double('dance2')
      @dance_1 = dances(:MyDance1)
      @dance_2 = dances(:MyDance2)
      @dance_3 = dances(:MyDance3)
      @dance_4 = dances(:MyDance4)
      @dance_5 = dances(:MyDance5)
    end
    it 'calls the intersect by dancer id method with two arguments' do
      expect(helper).to receive(:intersect_by_dancer_id).with(@double1, @double2).and_return(@double1)
      expect(@double1).to receive(:length)
      helper.count_conflicts(@double1, @double2)
    end
    it 'should count the nubmer of dancers in the intersection' do
      expect(helper).to receive(:intersect_by_dancer_id).with([@dance_1,@dance_2,@dance_3,@dance_4], [@dance_5]).and_return([])
      expect(helper).to receive(:intersect_by_dancer_id).with([@dance_1,@dance_2], [@dance_3,@dance_4]).and_return([@dance_1.id])
      expect(helper).to receive(:intersect_by_dancer_id).with([@dance_1,@dance_2], [@dance_3,@dance_4,@dance_5]).and_return([@dance_1.id, @dance_5.id])
      expect(helper.count_conflicts([@dance_1,@dance_2,@dance_3,@dance_4], [@dance_5])).to eq(0)
      expect(helper.count_conflicts([@dance_1,@dance_2], [@dance_3,@dance_4])).to eq(1)
      expect(helper.count_conflicts([@dance_1,@dance_2], [@dance_3,@dance_4,@dance_5])).to eq(2)
    end
  end
  
  describe "#form_graph" do
    fixtures :schedules, :performances, :dancers, :dances, :acts
    before :each do
      @fake_schedule = schedules(:MySchedule)
      
      @fake_perfs = []
      @fake_schedule.acts.each do |act|
        act.performances.each do |perf|
          @fake_perfs.append(perf)
        end
      end
      
      @fake_names = ["MyDancer1", "MyDancer2", "MyDancer3",
                     "MyDancer4", "MyDancer5", "MyDancer6"]
      
      values = [["MyDancer1"], ["MyDancer1"], ["MyDancer1"], [], ["MyDancer5"],
                ["MyDancer1","MyDancer6"], ["MyDancer1","MyDancer2","MyDancer6"], [], ["MyDancer2"],
                ["MyDancer1","MyDancer6"], ["MyDancer3"], [],
                ["MyDancer4"], ["MyDancer2","MyDancer4"],
                ["MyDancer4"]]
      @sample_graph = {
        @fake_perfs[0].id => {
          @fake_perfs[1].id => values[0], @fake_perfs[2].id => values[1], 
          @fake_perfs[3].id => values[2], @fake_perfs[3].id => values[3], 
          @fake_perfs[4].id => values[4]
        },
        @fake_perfs[1].id => {
          @fake_perfs[2].id => values[5], @fake_perfs[3].id => values[6], 
          @fake_perfs[4].id => values[7], @fake_perfs[5].id => values[8]
        },
        @fake_perfs[2].id => {
          @fake_perfs[4].id => values[9], @fake_perfs[5].id => values[10], 
          @fake_perfs[6].id => values[11]
        },
        @fake_perfs[3].id => {
          @fake_perfs[4].id => values[12], @fake_perfs[5].id => values[13]
        },
        @fake_perfs[4].id => {
          @fake_perfs[5].id => values[14]
        }
      }
      
      values.each do |val|
        allow(helper).to receive(:count_conflicts).and_return(val)
      end
      
      helper.instance_variable_set(:@performances, @fake_perfs)
      helper.form_graph
      @graph_result = helper.instance_variable_get(:@graph)
    end
    
    it 'should form a graph with as many keys as performances (except the last)' do
      expect(@graph_result.length()).to eq(@fake_perfs.length() - 1)
    end
    it 'should form a graph with a key for each performance' do
      fake_perf_ids = @fake_perfs.map { |fake_perf| fake_perf.id }.sort
      max_id = fake_perf_ids.max
      fake_perf_ids.delete(max_id)
      expect(@graph_result.keys.sort).to eq(fake_perf_ids)
    end
    
    context "Graph is of the right format" do
      it 'should have a key in each value hash for each id greater than the given id' do
        @graph_result.each do |id, matching_hash|
          matching_hash.keys.each do |paired_id|
            expect(paired_id).to be > id
          end
        end
      end
      it 'should have only nonnegative values for number of conflicts' do
        @graph_result.each do |id, matching_hash|
          matching_hash.each do |paired_id, conflicts|
            expect(conflicts.length()).to be >= 0
          end
        end
      end
      it 'should give names in conflicts for dancers in the list' do
        @graph_result.each do |id, matching_hash|
          matching_hash.each do |paired_id, conflicts|
            conflicts.each do |conflict|
              expect(@fake_names.include? conflict)
            end
          end
        end
      end
    end
  end
  
  describe "#score_perm" do
    fixtures :performances
    before :each do
      @perf1 = performances(:MyPerf1)
      @perf2 = performances(:MyPerf2)
      @perf3 = performances(:MyPerf3)
      @perf4 = performances(:MyPerf4)
      @performances = [@perf1, @perf2, @perf3, @perf4]
      
      # Test where dancer with id 1 is in all performances so their 
      # Contributions to the score all (except the first) count double
      @simple_graph = {1=>{2=>[1], 3=>[1,2], 4=>[1]},2=>{3=>[1], 4=>[1]}, 3=>{4=>[1]}}
      @perm_5_conflicts = (0..@performances.length() - 1).to_a
    end
    it 'should correctly score a permutation for a simple graph' do
      helper.instance_variable_set(:@graph, @simple_graph)
      expect(helper.score_perm(@perm_5_conflicts)).to eq(5)
    end
  end
  
  describe "#add_order(perms, original_order, new_order)" do
    it 'should add a new permutation to the collection' do
      perms = (1..3).to_a.permutation.to_a
      original_order = [1,2,3]
      new_order = [3,1,2]
      expect(original_order).to receive(:shuffle)
      helper.add_order(perms, original_order, new_order)
    end
    
    it 'should retry until it gets a new permutation if that order already exists' do
      original_order = [1,2,3]
      new_order = [3,1,2]
      perms = [[1,2,3],[3,2,1]]
      expect(original_order).not_to receive(:shuffle)
      helper.add_order(perms, original_order, new_order)
    end
  end
  
  describe "#permute" do
    context "When there is nothing to exclude from locks" do
      context "When the number of permutations is small enough" do
        it 'should return all permutations of that order' do
          original_order = [0, 1, 2]
          correct_perms = original_order.permutation.to_a
          res = helper.permute(original_order, correct_perms.length(), [])
          expect(res).to eq(correct_perms)
        end
      end
      context "When the number of permutations is too large" do
        it 'should only yield 10000 random ones (including the given order)' do
          original_order = (1..100).to_a
          max_perms = ScheduleHelper.class_variable_get(:@@MAX_PERMS)
          res = helper.permute(original_order, max_perms, [])
          expect(res.length()).to eq(max_perms)
          expect(res.include? original_order)
        end
      end
    end
    
    context "When locks exclude certain dances" do
      context "When the number of permutations is small enough" do
        before :each do
          @original_order = [0, 1, 3, 5]
          @excluded = [2, 4]
          @correct_perms = @original_order.permutation.to_a
          @correct_perms.each do |perm|
            @excluded.each do |excluded_index|
              perm.insert(excluded_index, excluded_index)
            end
          end
        end
        it 'should return all permutations of that order' do
          res = helper.permute(@original_order, @correct_perms.length(), @excluded)
          expect(res).to eq(@correct_perms)
        end
      end
      context "When the number of permutations is too large" do
        before :each do
          @original_order = (0..100).to_a
          @excluded = [1, 3, 4, 5, 23, 88, 99]
          @original_order -= @excluded
        end
        it 'should return all permutations of that order' do
          max_perms = ScheduleHelper.class_variable_get(:@@MAX_PERMS)
          res = helper.permute(@original_order, max_perms * 2, @excluded)
          # both included and excluded should be in there
          (@original_order + @excluded).each do |index|
            res.each do |ordering|
              expect(ordering).to include(index)
            end
          end
          expect(res.length).to eq max_perms
        end
      end
    end
  end
  
  describe "#get_perms" do
    fixtures :performances, :acts
    before :each do
      @fake_act1 = acts(:MyAct1)
      @fake_act2 = acts(:MyAct2)
      @perf7 = performances(:MyPerf7)
      @perf8 = performances(:MyPerf8)
      @perf13 = performances(:InsertPerformance1)
      
      @perfs = @fake_act1.performances + @fake_act2.performances
      expect(helper).to receive(:factorial).and_call_original.at_least(:once)
    end
    after :each do
      helper.get_perms(@perfs)
    end
    
    context "Enough dances to exceed max" do
      before :each do
        @original_order = (0..@perfs.length - 1).to_a
        @max_perms = ScheduleHelper.class_variable_get(:@@MAX_PERMS)
      end
      
      context "WITH exclusions" do
        before :each do
          @locked_indices = [0,2]
          @locked_indices.each do |index|
            @perfs[index].locked = true
          end
          # The rest are false
        end
      
        it 'should separate these indices out when permuting' do
          expect(helper).to receive(:permute)
              .with(@original_order - @locked_indices, 
                    @max_perms - 1,
                    @locked_indices)
        end
      end
      
      context "WITHOUT exclusions" do
        it 'should separate these indices out when permuting' do
          expect(helper).to receive(:permute)
              .with(@original_order, 
                    @max_perms - 1,
                    [])
        end
      end
    end
      
    context "NOT enough dances to exceed max" do
      before :each do
        @perfs -= [@perf7, @perf8, @perf13]
        @original_order = (0..@perfs.length - 1).to_a
      end
      
      context "WITH exclusions" do
        before :each do
          @locked_indices = [0,2]
          @locked_indices.each do |index|
            @perfs[index].locked = true
          end
          # The rest are false
        end
      
        it 'should separate these indices out when permuting' do
          expect(helper).to receive(:permute)
              .with(@original_order - @locked_indices, 
                    helper.factorial(@original_order.length),
                    @locked_indices)
        end
      end
      
      context "WITHOUT exclusions" do
        it 'should separate these indices out when permuting' do
          expect(helper).to receive(:permute)
              .with(@original_order, 
                    helper.factorial(@original_order.length),
                    [])
        end
      end
    end
  end
  
  describe "#find_min_perm" do
    fixtures :performances
    it 'should find the minimum score no matter what' do
      perms = [1, 2, 3].permutation.to_a
      # A bunch of fake scores (0th one  repeats, so 2nd is minimum)
      expect(helper).to receive(:score_perm).and_return(12, 12, 22, 0, 1, 3, 900)
      res = helper.find_min_perm(perms)
      expect(res).to eq(perms[2])
    end
  end
  
  describe "#reorder_performances" do
    fixtures :performances
    before :each do
      @perf1 = performances(:MyPerf1)
      @perf2 = performances(:MyPerf2)
      @perf3 = performances(:MyPerf3)
      @perf4 = performances(:MyPerf4)
      @performances = [@perf1, @perf2, @perf3, @perf4]
      @winner_perm = [0, 1, 3, 2]
    end
    it 'should reorder the performances by the given permutation' do
      helper.instance_variable_set(:@performances,@performances)
      helper.reorder_performances(@winner_perm)
      @result = helper.instance_variable_get(:@performances)
      expect(@result.map { |p| p.position }).to eq([1, 2, 4, 3])
    end
  end
  
  describe "#minimize_conflicts" do
    fixtures :performances
    it 'should simply call all these functions' do
      expect(helper).to receive(:form_graph)
      expect(helper).to receive(:get_perms)
      expect(helper).to receive(:find_min_perm)
      expect(helper).to receive(:reorder_performances)
      helper.minimize_conflicts([performances(:MyPerf1)])
    end
  end
end
