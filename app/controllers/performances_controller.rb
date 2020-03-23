class PerformancesController < ApplicationController
  def sort
    params[:performance].each_with_index do |id, index|
      Performance.where(id: id).update_all(position: index + 1)
    end
    
    head :ok
  end
end
