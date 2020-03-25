require "rails_helper"

describe ScheduleHelper do
  describe "#intersect_by_dancer_id" do # Troy
  end

  describe "#count_conflicts" do # Kyle
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

  describe "#form_graph" do # Troy
  end

  describe "#score_perm" do # Kyle
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
  describe "#permute" do # Troy
  end
  describe "#get_perms" do # Kyle
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

      #
  end
  describe "#find_min_perm" do # Troy
  end
  describe "#reorder_performances" do # Kyle
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
  describe "#minimize_conflicts" do # Troy
  end
end
