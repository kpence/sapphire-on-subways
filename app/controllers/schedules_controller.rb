class SchedulesController < ApplicationController


    def index
      @schedules = Schedule.all #Schedule.select(:filename)
    end

    def import
        if params[:file] == nil
          redirect_to root_url, notice: "No file selected"
        elsif Schedule.check_csv(params[:file])
          Schedule.upload_csv(params[:file])
          redirect_to root_url, notice: "Successfully Imported Data!!!"
        else
          redirect_to root_url, notice: "Failed to Import Data!!!"
        end
    end


end
