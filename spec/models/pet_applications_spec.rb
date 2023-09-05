require 'rails_helper'

RSpec.describe PetApplication do
    describe "relationships" do
        it {should belong_to(:application)}
        it {should belong_to(:pet)}
    end

    describe "validations" do
        it {should validate_presence_of :pet_id}
        it {should validate_presence_of :application_id}
    end
end