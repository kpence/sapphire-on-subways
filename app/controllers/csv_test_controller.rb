require 'CSV'

class CsvTestController < ApplicationController
  def index
    items = []
    CSV.foreach('app/assets/test.csv', headers: true) do |row|
      items << row.to_h
    end
    @items = items
  end
end
