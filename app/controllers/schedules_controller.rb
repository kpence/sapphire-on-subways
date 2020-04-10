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
      schedule = Schedule.create!(filename: params[:file].path, name: params[:schedule_name])
      Act.create!(number: 1, schedule_id: schedule.id)
      Act.create!(number: 2, schedule_id: schedule.id)
      schedule.import(csv_data)
      notice_msg = "Successfully Imported Data!!!"
      flash[:minimize] = true
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
    
    if flash[:minimize]
      @schedule.acts.each do |act|
        helpers.minimize_conflicts(act.performances)
      end
    end
    
    @ordered_performances = {}
    @schedule.acts.each do |act|
      @ordered_performances[act.number] = act.performances.sort_by do |perf|
        perf.position
      end
    end
  end
  
  def delete
    schedule_id = params[:id]
    if schedule_id == nil
      redirect_to root, notice: "Schedule could not be deleted!"
    end
    
    schedule = Schedule.find(schedule_id)
    if schedule == nil
      redirect_to root, notice: "Schedule could not be found!"
    end
    
    # Each act is responsible for deleting data under it
    Schedule.remove_acts(schedule_id)
    Schedule.delete!(schedule_id)
    
    redirect_to root, flash: {success: "Successfully deleted schedule "+schedule_name}
  end
end
