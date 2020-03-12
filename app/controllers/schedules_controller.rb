class SchedulesController < ApplicationController


    def index
      @schedules = Schedule.all #Schedule.select(:filename)
    end

    def import
        case Schedule.check_csv(params[:file])
        when :no_file
          redirect_to root_url, notice: "No file selected"
        when :success
          Schedule.upload_csv(params[:file])
          redirect_to root_url, notice: "Successfully Imported Data!!!"
        when :failed
          redirect_to root_url, notice: "Failed to Import Data!!!"
        end
    end


end
