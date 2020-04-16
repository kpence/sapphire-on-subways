class SchedulesController < ApplicationController
  helper ScheduleHelper
  
  def generate_conflict(perf1, perf2, intersect)
    if intersect.length() == 0
      return nil
    end
    
    return {:first_performance => perf1.name,
            :second_performance => perf2.name,
            :dancers => intersect
    }
  end

  def conflicts(act_number)
    # Go linearly through the schedule and mark conflicts
    conflict_list = []
    performances = @ordered_performances[act_number]
    
    performances.each_with_index do |perf, i|
      if i + 1 < performances.length()
        first_dance_list = perf.dances
        next_dance_list = performances[i + 1].dances
        intersect = helpers.intersect_by_dancer_id(first_dance_list, next_dance_list)
        conflict = generate_conflict(perf, performances[i+1], intersect)
        
        if conflict
          conflict_list.append(conflict)
          # Mark the first one to be the "conflicting" on for the view to catch
          @conflicting_performances.append(perf.id)
        end
      end
    end
    
    return conflict_list
  end
  
  def index
    @schedules = Schedule.all
  end

  # For importing a schedule from a CSV file in params
  def import
    case Schedule.check_csv(params[:file])
    when :no_file
      notice_msg = "No file selected"
    when :failed
      notice_msg = "Failed to Import Data!!!"

    when :success
      # On success, materialize the schedule with 2 acts, and send the data read
      # from the CSV file (by default, all performances in act 1)
      csv_data = Schedule.read_csv(params[:file])
      schedule = Schedule.create!(filename: params[:file].path, name: params[:schedule_name])
      Act.create!(number: 1, schedule_id: schedule.id)
      Act.create!(number: 2, schedule_id: schedule.id)
      schedule.import(csv_data)
      notice_msg = "Successfully Imported Data!!!"
      flash[:minimize] = true
      redirect_to edit_schedule_path(id: schedule.id), flash: {success: notice_msg}
      return
    end
    redirect_to schedules_path, flash: {notice: notice_msg}
  end
  
  def remove_unscheduled(performances)
    perfs = []
    performances.each do |perf|
      if perf.scheduled
        perfs.append(perf)
      end
    end
    return perfs
  end
  
  def edit
    @schedule = Schedule.find(params[:id])
    if @schedule == nil
      redirect_to schedules_path, notice: "Schedule with id #{params[:id]} could not be found."
      return
    end
    
    if flash[:minimize]
      @schedule.acts.each do |act|
        helpers.minimize_conflicts(remove_unscheduled(act.performances))
      end
    end
    
    @ordered_performances = {}
    @conflicts = {}
    @conflicting_performances = []
    @schedule.acts.each do |act|
      @ordered_performances[act.number] = remove_unscheduled(act.performances)
          .sort_by { |perf| perf.position }
      @conflicts[act.number] = self.conflicts(act.number)
    end
    @act_classes = {}
    @act_classes[1] = "floatLeftA"
    @act_classes[2] = "floatRightA"
  end
end
