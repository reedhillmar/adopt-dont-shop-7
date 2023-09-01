class Application < ApplicationRecord
  validates :name, presence: true
  validates :street_address, presence: true
  validates :city, presence: true
  validates :state, presence: true
  validates :zip_code, presence: true
  validates :reason_for_adoption, presence: true
  validates :status, presence: true

  has_many :pets
end