class SchedulesController < ApplicationController

    def index
        @schedules = []#Schedule.all
    end

    def import
        Schedule.upload_a_csv(params[:file])
        redirect_to root_url, notice: "Successfully Imported Data!!!"
    end


end
