class PerformancesController < ApplicationController
  def sort
    params[:performance].each_with_index do |id, index|
      Performance.where(id: id).update(position: index + 1)
    end
    
    head :ok
  end
  
  def create
    @new_performance = Performance.create!(name: params[:new_performance_name], act_id: params[:act_id].to_i,
                        scheduled: true, position: params[:position].to_i,
                        locked: false)
    
    notice_msg = "#{params[:new_performance_name]} inserted into Act #{Act.find(params[:act_id]).number}"
    redirect_to edit_schedule_path(id: params[:schedule_id].to_i), notice: notice_msg
  end
end
