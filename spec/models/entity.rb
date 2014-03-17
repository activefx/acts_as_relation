class Entity < ActiveRecord::Base
  acts_as :organization

  attr_protected nil

  validates :structure, presence: true
end
