class Product < ActiveRecord::Base
  acts_as_superclass

  belongs_to :store
  belongs_to :organization

  validates_presence_of :name, :price

  attr_accessible :name, :price

  def parent_method
    "#{name} - #{price}"
  end

  def dummy_raise_method(obj)
    obj.dummy
  end

end
