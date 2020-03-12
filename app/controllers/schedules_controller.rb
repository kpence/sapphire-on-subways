class SchedulesController < ApplicationController
  def index
    @schedules = Schedule.all #Schedule.select(:filename)
  end

  # For importing a schedule from a CSV file in params
  def import
    case Schedule.check_csv(params[:file])
    when :no_file
      redirect_to root_url, notice: "No file selected"
    when :failed
      redirect_to root_url, notice: "Failed to Import Data!!!"

    when :success
      # On success, materialize the schedule with 2 acts, and send the data read
      # from the CSV file (by default, all performances in act 1)
      csv_data = Schedule.read_csv(params[:file])
      schedule = Schedule.create!(filename: params[:file].path)
      Act.create!(number: 1, schedule_id: schedule.id)
      Act.create!(number: 2, schedule_id: schedule.id)
      schedule.import(csv_data)
      redirect_to root_url, notice: "Successfully Imported Data!!!"
    end
  end
end
