require 'rails_helper'

describe Dance do
    it 'has a performance it belongs to' do
        should belong_to(:performance)
    end
    it 'has a dancer it belongs to' do
        should belong_to(:dancer)
    end
end