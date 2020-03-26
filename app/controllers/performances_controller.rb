class PerformancesController < ApplicationController
  def sort
    params[:performance].each_with_index do |id, index|
      Performance.where(id: id).update(position: index + 1)
    end
    
    head :ok
  end
  
  def remove (cancelled_performance)
    #Unschedules a performance
    cancelled_performance.update_attribute(:scheduled, false)
    
    #Updates schedule view for user
    redirect_to edit_schedule_path(id: params[:schedule_id].to_i)
  end
end
