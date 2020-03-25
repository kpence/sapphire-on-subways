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
        expect(res).to eq([dancers(:MyDancer1).id])
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
      
      values = [1, 1, 1, 0, 1, 1, 1, 0, 0, 2, 1, 0, 1, 2, 1]
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
      it 'should have only nonnegative values for conflicts' do
        @graph_result.each do |id, matching_hash|
          matching_hash.each do |paired_id, conflicts|
            expect(conflicts).to be > 0
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
      @simple_graph = {1=>{2=>0, 3=>1, 4=>0},2=>{3=>1, 4=>0}, 3=>{4=>0}}
      @perm_1_conflict = (0..@performances.length() - 1).to_a
      @perm_0_conflict = [0, 1, 3, 2]
    end
    it 'should correctly score a permutation for a simple graph' do
      helper.instance_variable_set(:@graph, @simple_graph)
      expect(helper.score_perm(@perm_1_conflict)).to eq(1)
      expect(helper.score_perm(@perm_0_conflict)).to eq(0)
    end

  end
  
  describe "#permute" do
    context "When the number of permutations is small enough" do
      it 'should return all permutations of that order' do
        original_order = [1, 2, 3]
        correct_perms = original_order.permutation.to_a
        res = helper.permute(original_order, correct_perms.length())
        expect(res).to eq(correct_perms)
      end
    end
    context "When the number of permutations is too large" do
      it 'should only yield 10000 random ones (including the given order)' do
        original_order = (1..100).to_a
        max_perms = ScheduleHelper.class_variable_get(:@@MAX_PERMS)
        res = helper.permute(original_order, max_perms)
        expect(res.length()).to eq(max_perms)
        expect(res.include? original_order)
      end
    end
  end
  
  describe "#get_perms" do
    fixtures :performances
    before :each do
      @perf1 = performances(:MyPerf1)
      @perf2 = performances(:MyPerf2)
      @perf3 = performances(:MyPerf3)
      @perf4 = performances(:MyPerf4)
      @perf5 = performances(:MyPerf5)
      @perf6 = performances(:MyPerf6)
      @perf7 = performances(:MyOtherPerf1)
      @perf8 = performances(:MyOtherPerf2)
      @perf_under_10k = [@perf1, @perf2, @perf3, @perf4]
      @perf_exceed_10k = [@perf1, @perf2, @perf3, @perf4, @perf5, @perf6, @perf7, @perf8]
      #helper.instance_variable_set(:@@MAX_PERMS, 10000)
    end
    it 'should should not exceed 10k permutations' do
      original_order = (0..7).to_a
      expect(helper).to receive(:factorial).with(8).and_return(40320)
      expect(helper).to receive(:permute).with(original_order, 9999)
      helper.get_perms(@perf_exceed_10k)
    end
    it 'should should return the correct factorial number' do
      original_order = (0..3).to_a
      expect(helper).to receive(:factorial).with(4).and_return(24)
      expect(helper).to receive(:permute).with(original_order, 24)
      helper.get_perms(@perf_under_10k)
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
