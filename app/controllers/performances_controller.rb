class PerformancesController < ApplicationController
  def sort
    schedule_id = nil

    params[:performance].each_with_index do |id, index|
      Performance.where(id: id.to_i).update(position: index + 1)
      if schedule_id == nil
        p = Performance.find(id.to_i)
        act = Act.find(p.act_id)
        schedule_id = act.schedule_id
      end
    end
    Performance.where(id: params[:move_perf].to_i).update(act_id: params[:act_id].to_i)

    redirect_to edit_schedule_path(id: schedule_id, post_id: "performance_"+params[:move_perf])
  end
  
  def create
    @new_performance = Performance.create!(name: params[:new_performance_name], act_id: params[:act_id].to_i,
                        scheduled: true, position: params[:position].to_i,
                        locked: false)
    
    notice_msg = "#{params[:new_performance_name]} inserted into Act #{Act.find(params[:act_id]).number}"
    redirect_to edit_schedule_path(id: params[:schedule_id].to_i), notice: notice_msg
  end
  def remove
    cancelled_performance = Performance.find(params[:performance_id].to_i)
    
    #Unschedules a performance
    cancelled_performance.update_attribute(:scheduled, false)
    Performance.where(id: params[:performance_id].to_i).update(scheduled: false)
    
    flash[:notice] = "#{Performance.find(params[:performance_id]).name} Removed"
    
    #Updates schedule view for user
    redirect_to edit_schedule_path(id: params[:schedule_id].to_i)
  end
end
