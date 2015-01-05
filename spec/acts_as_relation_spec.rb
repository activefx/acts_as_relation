require 'spec_helper'

RSpec.describe ActiveRecord::ActsAsRelation do

  it "adds the acts_as class method to ActiveRecord models" do
    expect(GenericModel).to respond_to :acts_as
  end

  it "adds the acts_as_superclass class method to ActiveRecord models" do
    expect(GenericModel).to respond_to :acts_as_superclass
  end

  context "::acts_as_association_name" do

    it "is inferred by the model name by default" do
      expect(Product.acts_as_association_name).to eq 'as_product'
    end

    it "can be called with a custom class name" do
      expect(Product.acts_as_association_name('NotAProduct'))
        .to eq 'as_not_a_product'
    end

    it "can be called with a namespaced class name" do
      expect(Product.acts_as_association_name('Product::LightBulb'))
        .to eq 'as_light_bulb'
    end

  end

end
