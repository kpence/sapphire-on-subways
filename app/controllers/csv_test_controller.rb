require 'CSV'

class CsvTestController < ApplicationController
  def index
		items = []
		rows = CSV.read('app/assets/test.csv', headers: true)
		@items2 = rows[0].drop(2).select {|e| e[0] != "TOTAL" }.map {|e| e[0]}
		rows.drop(1).each do |row|
			items << row.to_h.select {|entry| entry != "TOTAL" && entry != nil}
		end
    @items = items
  end
end
