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
    
    # TODO:NOTICE -- I'm commenting this out TEMPORARILY for the sake of the demo because it's not working in an elegant way right now
    # redirect_to edit_schedule_path(id: schedule_id) + "#performance_"+params[:move_perf]
    redirect_to edit_schedule_path(id: schedule_id)
  end
  
  def create
    if params[:new_performance_name] == ""
      redirect_to edit_schedule_path(id: params[:schedule_id].to_i)
      return
    end
    
    @new_performance = Performance.create!(name: params[:new_performance_name], act_id: params[:act_id].to_i,
                        scheduled: true, position: params[:position].to_i,
                        locked: false)
    
    notice_msg = "#{params[:new_performance_name]} inserted into Act #{Act.find(params[:act_id]).number}"
    redirect_to edit_schedule_path(id: params[:schedule_id].to_i), notice: notice_msg
  end

  def remove
    
    #Unschedules a performance
    performance_to_remove = Performance.where(id: params[:performance_id].to_i)
    performance_to_remove.update(scheduled: false)
    performance_to_remove.update(position: -1)
    
    #Display to User Which Dance Was Removed
    flash[:notice] = "#{Performance.find(params[:performance_id]).name} Removed"
    
    redirect_to edit_schedule_path(id: params[:schedule_id].to_i)
  end
  
  def lock
    performance_to_change = Performance.find(params[:performance_id].to_i)
    performance_to_change.update!(locked: !performance_to_change.locked)
    
    redirect_to edit_schedule_path(id: params[:schedule_id].to_i)
    
  end
  
  def revive
    
    #Schedules a performance
    performance_to_revive = Performance.where(id: params[:performance_id].to_i)
    performance_to_revive.update(scheduled: true)
    performance_to_revive.update(position: params[:position].to_i)
    
    #Display to User Which Dance Was Removed
    flash[:notice] = "#{Performance.find(params[:performance_id]).name} Added Back"
    
    redirect_to edit_schedule_path(id: params[:schedule_id].to_i)
  end
end
