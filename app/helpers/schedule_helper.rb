module ScheduleHelper  
  @@MAX_PERMS = 1000
  
  # Thank you https://medium.com/@daweiner16/factorial-using-ruby-app-academy-practice-problem-c1a179ac445f
  def factorial(n)
    if n == 0
      return 1
    else
      return n * factorial(n-1)
    end
  end
  
  def intersect_by_dancer_id(dances_a, dances_b)
    if dances_a.length() > dances_b.length()
      return intersect_by_dancer_id(dances_b, dances_a)
    end
    
    intersection = []
    dances_a.each do |a|
      dances_b.each do |b|
        if a.dancer_id == b.dancer_id
          intersection.append(Dancer.find(a.dancer_id).name)
        end
      end
    end
    
    return intersection
  end
  
  # Put all the performances in a schedule in one list
  def concatenate(act1_perfs, act2_perfs)
    all_perfs = []
    act1_perfs.each do |perf|
      all_perfs.append(perf)
    end
    num_act1_perfs = act1_perfs.length()
    act2_perfs.each do |perf|
      perf.position = perf.position + num_act1_perfs
      all_perfs.append(perf)
    end
    return all_perfs
  end
  
  # Adjust all the positions of dances after act 1 back to their
  # positions relative to only their act(s)
  def divide(first_act2)
    num_act1_perfs = @performances.select {|perf| perf.position < first_act2}.length
    
    @performances.each do |perf|
      if perf.position < first_act2
        perf.act = @schedule.acts[0]
        perf.save
      else
        perf.act = @schedule.acts[1]
        perf.position = perf.position - num_act1_perfs
        perf.save
      end
    end
    
    # Have to reload the schedule and fix up @ordered_performances
    [1,2].each do |idx|
      @ordered_performances[idx] = @performances.select {|p| p.act.number == idx }
                                          .sort_by {|p| p.position }
    end
    @schedule.reload
  end
  
  def form_graph
    @graph = {}
    @performances.each do |perf|
      this_performance_dances = perf.dances
      @performances.each do |other_perf|
        if perf.id < other_perf.id
          other_performance_dances = other_perf.dances
          intersection = intersect_by_dancer_id(this_performance_dances, 
                                                  other_performance_dances)
          if !@graph.keys.include? perf.id
            @graph[perf.id] = {}
          end
          
          @graph[perf.id][other_perf.id] = intersection
        end
      end
    end
  end
  
  # Returns the total cost (related to number of conflicts) in given schedule
  # order permutation)
  def score_perm(permutation)
    # First form the schedule
    temp_schedule = []
    permutation.each do |index|
      temp_schedule.append(@performances[index])
    end
    
    # Then score it
    first_index = 0
    second_index = 1
    curr_score = 0
    last_conflicts = []
    while second_index < temp_schedule.length()
      first_id = temp_schedule[first_index].id
      second_id = temp_schedule[second_index].id
      min_id = [first_id, second_id].min
      max_id = [first_id, second_id].max
      
      #if @performances[first_index].act_id == @performances[second_index].act_id
        curr_conflicts = @graph[min_id][max_id]
        curr_conflicts.each do |curr_conflict|
          if last_conflicts != nil and last_conflicts.include? curr_conflict
            curr_score += 2
          else
            curr_score += 1
          end
        end
      #else
      #  curr_conflicts = nil
      #end
      
      first_index += 1
      second_index += 1
      last_conflicts = curr_conflicts
    end
    return curr_score
  end
  
  # To avoid adding the same order twice
  def add_order(perms, original_order, new_order)
    while perms.include? new_order
      new_order = original_order.shuffle
    end
    perms.append(new_order)
    return perms
  end
  
  def permute(original_order, num_perms, excluded)
    perms = [original_order]
    if num_perms <= @@MAX_PERMS - 1 && 
          factorial(original_order.length()) <= @@MAX_PERMS - 1
      perms = original_order.permutation.to_a
    else
      (1..@@MAX_PERMS-1).to_a.each do
        # Find a new ordering
        new_order = original_order.shuffle
        perms = add_order(perms, original_order, new_order)
      end
    end
    
    if excluded.length > 0
      perms.each do |perm|
        #puts "perm before: " + perm.to_s + " Excludeds: " + excluded.to_s
        excluded.each do |excluded_index|
          perm.insert(excluded_index, excluded_index)
        end
        #puts "perm after: " + perm.to_s
      end
    end
    
    # Also need to check if the factorial exceeds the num_perms asked for
    
    return perms
  end
  
  def get_perms(performances)
    original_order = (0..performances.length() - 1).to_a
    
    excluded = []
    original_order.each do |index|
      if performances[index].locked
        excluded.append(index)
      end
    end
    
    factorial_value = factorial(performances.length())

    if factorial_value > @@MAX_PERMS
      num_perms = @@MAX_PERMS - 1
    else
      num_perms = factorial_value
    end
    
    return permute(original_order - excluded, num_perms, excluded)
  end
  
  def find_min_perm(perms)
    min_score = score_perm(perms[0])
    min_idx = 0
    perms.each_with_index do |perm, i|
      score = score_perm(perm)
      #puts "score " + score.to_s
      if score < min_score
        min_score = score
        min_idx = i
      end
    end
    
    puts "Min score is " + min_score.to_s + " to perm " + perms[min_idx].to_s
    
    return perms[min_idx]
  end
  
  def reorder_performances(winner_permutation)
    curr_pos = 1
    winner_permutation.each do |winner_index|
      perf = @performances[winner_index]
      perf.update(position: curr_pos)
      curr_pos += 1
    end
    @performances.sort_by! {|p| p.position }
  end
  
  # Takes a list of performances (AR object references) and attempts
  # to minimize the conflicts between them (changes the position field
  # of each performance- no need to return)
  def minimize_conflicts(schedule, ordered_performances)
    @schedule = schedule
    @ordered_performances = ordered_performances
    @performances = concatenate(@ordered_performances[1], 
                                @ordered_performances[2])
                                
    original_act2_start = @ordered_performances[1].length
    
    form_graph
    perms = get_perms(@performances)
    winner_permutation = find_min_perm(perms)
    reorder_performances(winner_permutation)
    
    divide(original_act2_start + 1) # The performance positions back into 2 acts
    
    return @ordered_performances
  end
end
