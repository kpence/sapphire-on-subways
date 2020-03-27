class PerformancesController < ApplicationController
  def sort
    schedule_id = nil
    
    params[:performance].each_with_index do |id, index|
      puts id.to_i.to_s
      Performance.where(id: id.to_i).update(position: index + 1)
      if schedule_id == nil
        p = Performance.find(id.to_i)
        act = Act.find(p.act_id)
        schedule_id = act.schedule_id
      end
    end
    
    redirect_to edit_schedule_path(id: schedule_id)
  end
  
  def create
    @new_performance = Performance.create!(name: params[:new_performance_name], act_id: params[:act_id].to_i,
                        scheduled: true, position: params[:position].to_i,
                        locked: false)
    
    notice_msg = "#{params[:new_performance_name]} inserted into Act #{Act.find(params[:act_id]).number}"
    redirect_to edit_schedule_path(id: params[:schedule_id].to_i), notice: notice_msg
  end
end
