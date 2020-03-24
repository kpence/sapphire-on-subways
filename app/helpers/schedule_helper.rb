module ScheduleHelper
  
  @@MAX_PERMS = 10000
  
  # Thank you https://medium.com/@daweiner16/factorial-using-ruby-app-academy-practice-problem-c1a179ac445f
  def factorial(n)
    if n == 0
      return 1
    else
      return n * factorial(n-1)
    end
  end
  
  def intersect_by_dancer_id(list_a, list_b)
    if list_a.length() > list_b.length()
      return intersect_by_dancer_id(list_b, list_a)
    end
    
    intersection = []
    list_a.each do |a|
      list_b.each do |b|
        if a.dancer_id == b.dancer_id
          intersection.append(a)
        end
      end
    end
    
    return intersection
  end
  
  def count_conflicts(dances_a, dances_b)
    return intersect_by_dancer_id(dances_a, dances_b).length()
  end
  
  def form_graph
    @graph = {}
    @performances.each do |perf|
      this_performance_dances = perf.dances
      @performances.each do |other_perf|
        if perf.id < other_perf.id
          other_performance_dances = other_perf.dances
          num_conflicting_dances = count_conflicts(this_performance_dances, 
                                                  other_performance_dances)
          if !@graph.keys.include? perf.id
            @graph[perf.id] = {}
          end
          
          @graph[perf.id][other_perf.id] = num_conflicting_dances
        end
      end
    end
  end
  
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
    while second_index < temp_schedule.length()
      first_id = temp_schedule[first_index].id
      second_id = temp_schedule[second_index].id
      min_id = [first_id, second_id].min
      max_id = [first_id, second_id].max
      curr_score += @graph[min_id][max_id]
      first_index += 1
      second_index += 1
    end
    return curr_score
  end
  
  def permute(original_order, num_perms)
    perms = [original_order]
    if num_perms == factorial(original_order.length())
      perms = original_order.permutation.to_a
    else
      (1..num_perms).to_a.each do
        # Find a new ordering
        new_order = original_order.shuffle
        while perms.include? new_order
          new_order = original_order.shuffle
        end
        perms.append(new_order)
      end
    end
    return perms
  end
  
  def get_perms(performances)
    original_order = (0..performances.length() - 1).to_a
    
    if factorial(performances.length()) > @@MAX_PERMS
      num_perms = @@MAX_PERMS - 1
    else
      num_perms = factorial(performances.length())
    end
    
    return permute(original_order, num_perms)
  end
  
  def find_min_perm(perms)
    min_score = score_perm(perms[0])
    min_idx = 0
    perms.each_with_index do |perm, i|
      score = score_perm(perm)
      if score < min_score
        min_score = score
        min_idx = i
      end
    end
    
    return perms[min_idx]
  end
  
  def reorder_performances(winner_permutation)
    curr_pos = 1
    winner_permutation.each do |winner_index|
      @performances[winner_index].position = curr_pos
      curr_pos += 1
    end
    @performances.each_with_index do |perf, i|
      perf.position = winner_permutation[i]
    end
  end
  
  # Takes a list of performances (AR object references) and attempts
  # to minimize the conflicts between them (changes the position field
  # of each performance- no need to return)
  def minimize_conflicts(performances)
    @performances = performances
    
    form_graph
    perms = get_perms(@performances)
    winner_permutation = find_min_perm(perms)
    
    reorder_performances(winner_permutation)
  end
  
end