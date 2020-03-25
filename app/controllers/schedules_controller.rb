class SchedulesController < ApplicationController
  helper ScheduleHelper
  
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
      schedule = Schedule.create!(filename: params[:file].path)
      Act.create!(number: 1, schedule_id: schedule.id)
      Act.create!(number: 2, schedule_id: schedule.id)
      schedule.import(csv_data)
      notice_msg = "Successfully Imported Data!!!"
      redirect_to edit_schedule_path(id: schedule.id), notice: notice_msg
      return
    end
    redirect_to schedules_path, notice: notice_msg
  end
  
  def edit
    @schedule = Schedule.find(params[:id])
    if @schedule == nil
      redirect_to schedules_path, notice: "Schedule with id #{params[:id]} could not be found."
      return
    end
    
    helpers.minimize_conflicts(@schedule.acts[0].performances)
    
    @ordered_performances = {}
    @schedule.acts.each do |act|
      @ordered_performances[act.number] = act.performances.sort_by do |perf|
        perf.position
      end
    end
  end
  
  def insert
    #Create new performance
    @new_performance = Performance.create!(name: params[:new_performance_name], act_id: params[:act_id].to_i,
                        scheduled: false, position: params[:position].to_i,
                        locked: false)
                        
    #Insert the new performance into the correct act, updating the index of all the other performances
    Schedule.insert_performance_into_act(@new_performance)
    
    #Redirect back to the edit_schedule_path so the user see the updated schedule
    redirect_to edit_schedule_path(id: params[:schedule_id].to_i), notice: "#{params[:new_performance_name]} inserted into Act #{params[:act_id]}"
  end
end
