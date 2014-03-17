class Function < ActiveRecord::Base
  acts_as :organization

  attr_protected nil

  validates :category, presence: true
end
