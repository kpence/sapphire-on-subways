class PerformancesController < ApplicationController
  def sort
    params[:performance].each_with_index do |id, index|
      Performance.where(id: id).update(position: index + 1)
    end
    
    head :ok
  end
  
  def create
    @new_performance = Performance.create!(name: params[:new_performance_name], act_id: params[:act_id].to_i,
                        scheduled: false, position: params[:position].to_i,
                        locked: false)
                        
    redirect_to edit_schedule_path(id: params[:schedule_id].to_i), notice: "#{params[:new_performance_name]} inserted into Act #{params[:act_id]}"

  end
end
