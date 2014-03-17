class Pen < ActiveRecord::Base
  acts_as_superclass as: :writable
  acts_as :product

  attr_accessible :color

  validates_presence_of :color
end
