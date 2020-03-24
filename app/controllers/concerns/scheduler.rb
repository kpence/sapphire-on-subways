module Scheduler
  extend ActiveSupport::Concern
  
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
      this_performance_dances = Dance.where(performance_id: perf.id)
      @performances.each do |other_perf|
        if perf.id < other_perf.id
          other_performance_dances = Dance.where(performance_id: other_perf.id)
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
    (1..num_perms).to_a.each do
      # Find a new ordering
      new_order = original_order.shuffle
      while perms.include? new_order
        new_order = original_order.shuffle
      end
      perms.append(new_order)
    end
    return perms
  end
  
  def minimize_conflicts(schedule)
    @schedule = schedule
    @performances = @schedule.acts[0].performances
    form_graph
    puts "Graph: " + @graph.to_s
    original_order = (0..@performances.length() - 1).to_a
    puts "Original order: " + original_order.to_s
    
    puts "Generating permutations..."
    num_perms = 9999
    perms = permute(original_order, num_perms)
    puts "Number of Permutations: " + perms.length().to_s + "..."
    
    min_score = score_perm(perms[0])
    min_idx = 0
    perms.each_with_index do |perm, i|
      score = score_perm(perm)
      if score < min_score
        min_score = score
        min_idx = i
      #else
        #puts "Score " + score.to_s + " for order " + perm.to_s
      end
    end
    winner_permutation = perms[min_idx]
    puts "Winner order: " + winner_permutation.to_s + " with score " + min_score.to_s
    curr_pos = 1
    winner_permutation.each do |winner_index|
      @performances[winner_index].position = curr_pos
      curr_pos += 1
    end
    @performances.each_with_index do |perf, i|
      perf.position = winner_permutation[i]
    end
    return @schedule
  end
  
end