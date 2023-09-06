require "rails_helper"

RSpec.describe Shelter, type: :model do
  describe "relationships" do
    it { should have_many(:pets) }
  end

  describe "validations" do
    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:city) }
    it { should validate_presence_of(:rank) }
    it { should validate_numericality_of(:rank) }
  end

  before(:each) do
    @shelter_1 = Shelter.create(name: "Aurora shelter", city: "Aurora, CO", foster_program: false, rank: 9)
    @shelter_2 = Shelter.create(name: "RGV animal shelter", city: "Harlingen, TX", foster_program: false, rank: 5)
    @shelter_3 = Shelter.create(name: "Fancy pets of Colorado", city: "Denver, CO", foster_program: true, rank: 10)

    @pet_1 = @shelter_1.pets.create(name: "Mr. Pirate", breed: "tuxedo shorthair", age: 5, adoptable: false)
    @pet_2 = @shelter_1.pets.create(name: "Clawdia", breed: "shorthair", age: 3, adoptable: true)
    @pet_3 = @shelter_3.pets.create(name: "Lucille Bald", breed: "sphynx", age: 8, adoptable: true)
    @pet_4 = @shelter_1.pets.create(name: "Ann", breed: "ragdoll", age: 5, adoptable: true)
  end

  describe "class methods" do
    describe "#search" do
      it "returns partial matches" do
        expect(Shelter.search("Fancy")).to eq([@shelter_3])
      end
    end

    describe "#order_by_recently_created" do
      it "returns shelters with the most recently created first" do
        expect(Shelter.order_by_recently_created).to eq([@shelter_3, @shelter_2, @shelter_1])
      end
    end

    describe "#order_by_number_of_pets" do
      it "orders the shelters by number of pets they have, descending" do
        expect(Shelter.order_by_number_of_pets).to eq([@shelter_1, @shelter_3, @shelter_2])
      end
    end
  end

  describe "instance methods" do
    describe ".adoptable_pets" do
      it "only returns pets that are adoptable" do
        expect(@shelter_1.adoptable_pets).to eq([@pet_2, @pet_4])
      end
    end

    describe ".alphabetical_pets" do
      it "returns pets associated with the given shelter in alphabetical name order" do
        expect(@shelter_1.alphabetical_pets).to eq([@pet_4, @pet_2])
      end
    end

    describe ".shelter_pets_filtered_by_age" do
      it "filters the shelter pets based on given params" do
        expect(@shelter_1.shelter_pets_filtered_by_age(5)).to eq([@pet_4])
      end
    end

    describe ".pet_count" do
      it "returns the number of pets at the given shelter" do
        expect(@shelter_1.pet_count).to eq(3)
      end
    end

    describe "self.reverse_alphabetical" do
      it "returns shelters in reverse alphabetical order" do
        result = Shelter.order_by_reverse_alphabetical
        expect(result).to eq([@shelter_2, @shelter_3, @shelter_1])
      end
    end

    describe "#pending_apps" do
      it "returns shelters with pets having pending applications" do
        shelter_1 = Shelter.create(name: "Boulder Vally", city: "Boulder", foster_program: false, rank: 9)
        shelter_2 = Shelter.create(name: "Run Away Haven", city: "New York", foster_program: false, rank: 5)

        pet_1 = shelter_1.pets.create(name: "Bill", breed: "Boxer", age: 5, adoptable: false)
        pet_2 = shelter_2.pets.create(name: "Marko", breed: "Hound", age: 3, adoptable: true)
        pet_3 = shelter_2.pets.create(name: "Tiny", breed: "Pit", age: 2, adoptable: true)

        johnny = Application.create!(name: 'Johnny', street_address: '111 rainbow rd', city: 'Iceblock', state: 'CO', zip_code: '80020',  reason_for_adoption: "I want dog", status: "Pending" )
        kim = Application.create!(name: "Kim", street_address: "123 riverdale rd", city: "Thornton", state: "CO", zip_code: "80241", reason_for_adoption: "I want hound", status: "Approved")
        susan = Application.create!(name: "Susan", street_address: "333 nighthawk ln", city: "Erie", state: "CO", zip_code: "45673", reason_for_adoption: "I am alone", status: "Rejected")

        PetApplication.create!(pet: pet_1, application: johnny)
        PetApplication.create!(pet: pet_2, application: kim)
        PetApplication.create!(pet: pet_3, application: susan)

        result = Shelter.pending_apps

        expect(result).to include(shelter_1)
        expect(result).not_to include(shelter_2)
      end
    end

    it "orders shelters by name" do

      ordered_shelters = Shelter.alphabetical_order.to_a

      expected_order = [@shelter_1, @shelter_3, @shelter_2]

      expect(ordered_shelters).to eq(expected_order)
    end

  end

  it 'returns shelters with pending applications' do
    shelter_1 = Shelter.create(name: "Boulder Vally", city: "Boulder", foster_program: false, rank: 9)
    shelter_2 = Shelter.create(name: "Run Away Haven", city: "New York", foster_program: false, rank: 5)
  
    pet_1 = shelter_1.pets.create(name: "Bill", breed: "Boxer", age: 5, adoptable: false)
    pet_2 = shelter_2.pets.create(name: "Marko", breed: "Hound", age: 3, adoptable: true)
    pet_3 = shelter_2.pets.create(name: "Tiny", breed: "Pit", age: 2, adoptable: true)
  
    johnny = Application.create!(name: 'Johnny', street_address: '111 rainbow rd', city: 'Iceblock', state: 'CO', zip_code: '80020',  reason_for_adoption: "I want dog", status: "Pending" )
    kim = Application.create!(name: "Kim", street_address: "123 riverdale rd", city: "Thornton", state: "CO", zip_code: "80241", reason_for_adoption: "I want hound", status: "Approved")
    susan = Application.create!(name: "Susan", street_address: "333 nighthawk ln", city: "Erie", state: "CO", zip_code: "45673", reason_for_adoption: "I am alone", status: "Rejected")
  
    PetApplication.create!(pet: pet_1, application: johnny, application_status: 'Pending')
    PetApplication.create!(pet: pet_2, application: kim, application_status: 'Approved')
    PetApplication.create!(pet: pet_3, application: susan, application_status: 'Rejected')

    shelters_with_pending_apps = Shelter.shelters_with_pending_apps

    expect(shelters_with_pending_apps).to include(shelter_1)
  end
end
