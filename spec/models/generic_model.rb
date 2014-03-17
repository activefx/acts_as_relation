class GenericModel < ActiveRecord::Base
  acts_as :product
  acts_as :store, as: :storeable, dependent: :nullify, validate: true, foreign_key: 'other_id'

  attr_protected nil
end
