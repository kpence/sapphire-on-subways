require 'CSV'

class SchedulesController < ApplicationController

    def index
        rows = CSV.read('app/assets/test.csv', headers: true)
        @items2 = rows[0].drop(2).select {|e| e[0] != "TOTAL" }.map {|e| e[0]}
        items = []
        rows.drop(1).each do |row|
          items << row.to_h.select {|entry| entry != "TOTAL" && entry != nil}
        end
        @items = items
        @schedules = []#Schedule.all
    end

end
