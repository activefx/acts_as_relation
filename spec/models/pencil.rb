class Pencil < ActiveRecord::Base
  acts_as :pen, auto_join: false

  attr_protected nil
end
