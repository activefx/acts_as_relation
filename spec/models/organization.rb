class Organization < ActiveRecord::Base
  acts_as_superclass of: {
    functions: { type: :many },
    entity: { type: :one }
  }

  attr_protected nil

  has_many :products

  validates :name, presence: true

  def parent_method
    true
  end
end
