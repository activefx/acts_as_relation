require "spec_helper"

RSpec.describe "has many submodels" do

  let(:product) { Product.create name: 'money', price: 100.00 }
  let(:pen) { Pen.create name: 'RedPen', price: 0.8, color: 'red' }

  context "with a has_one definition" do

    let(:entity) { Entity.create(name: 'Other Co', structure: 'C Corp') }
    let(:invalid_entity) { Entity.new }

    context "::acts_as_other_model?" do

      it "returns true when the relationship is defined" do
        expect(Entity.acts_as_other_model?).to be_truthy
      end

    end

    context "::acts_as_model_name" do

      it "returns the supermodel name for has_one submodel definitions" do
        expect(Entity.acts_as_model_name).to eq :organization
      end

    end

    context "::is_a?" do

      it "returns true when it is an instance of the same class" do
        expect(entity.is_a? Entity).to be_truthy
      end

      it "returns true when it is an instance of the supermodel" do
        expect(entity.is_a? Organization).to be_truthy
      end

      it "returns false for unrelated classes" do
        expect(entity.is_a? String).to be_falsey
      end

    end

    context "::where" do

      before { entity }

      it "allows searching by supermodel attributes" do
        expect(Entity.where(organizations: { name: 'Other Co' }).first).not_to be_nil
      end

    end

    it "can be persisted" do
      expect(entity.persisted?).to be_truthy
    end

    it "reads its attributes" do
      expect(entity.structure).to eq 'C Corp'
    end

    it "writes its attributes" do
      entity.structure = 'S Corp'
      expect(entity.structure).to eq 'S Corp'
    end

    it "can track its attributes change states" do
      entity.structure = 'LLC'
      expect(entity.structure_changed?).to be_truthy
    end

    it "can track its attributes change history" do
      entity.structure = 'LTD'
      expect(entity.structure_was).to eq 'C Corp'
    end

    it "validates its attributes" do
      invalid_entity.valid?
      expect(invalid_entity.errors[:structure]).not_to be_empty
    end

    it "raises NoMethodError for methods the do not exist on itself or the supermodel" do
      expect{ entity.non_existent_method }.to raise_error NoMethodError
    end

    it "raises NoMethodError correctly for supermodel methods" do
      expect{ entity.dummy_raise_method(nil) }
        .to raise_error NoMethodError, /undefined method `dummy' for nil:NilClass/
    end

    it "does not destroy the supermodel on destruction" do
      organization_id = entity.as_organization.id
      entity.destroy
      expect{ Organization.find organization_id }.not_to raise_error
    end

    context "from the supermodel" do

      it "inherits attribute readers" do
        expect(entity.name).to eq 'Other Co'
      end

      it "inherits attribute writers" do
        entity.name = 'New Co'
        expect(entity.name).to eq 'New Co'
      end

      it "inherits attribute dirty tracking change state" do
        entity.name = 'Dead Co'
        expect(entity.name_changed?).to be_truthy
      end

      it "inherits attribute dirty tracking history" do
        entity.name = 'Change Co'
        expect(entity.name_was).to eq 'Other Co'
      end

      it "inherits attribute typecasting" do
        entity.update_attribute(:sales, '42')
        expect(entity.sales).to eq 42
      end

      it "inherits methods" do
        expect(entity.respond_to? :parent_method).to be_truthy
      end

      it "inherits validations" do
        invalid_entity.valid?
        expect(invalid_entity.errors.keys).to include :name
      end

      it "inherits associations" do
        entity.products << product
        expect(entity.products).to include product
      end

      it "inherits associations that work with submodel instances" do
        entity.products << pen
        expect(entity.products).to include pen
      end

    end

  end

  context "with a has_many definition" do

    let(:function) { Function.create(name: 'Big Co', category: 'retailer') }
    let(:invalid_function) { Function.new }

    context "::acts_as_other_model?" do

      it "returns true when the relationship is defined" do
        expect(Function.acts_as_other_model?).to be_truthy
      end

    end

    context "::acts_as_model_name" do

      it "returns the supermodel name for has_many submodel definitions" do
        expect(Function.acts_as_model_name).to eq :organization
      end

    end

    context "::is_a?" do

      it "returns true when it is an instance of the same class" do
        expect(function.is_a? Function).to be_truthy
      end

      it "returns true when it is an instance of the supermodel" do
        expect(function.is_a? Organization).to be_truthy
      end

      it "returns false for unrelated classes" do
        expect(function.is_a? String).to be_falsey
      end

    end

    context "::where" do

      before { function }

      it "allows searching by supermodel attributes" do
        expect(Function.where(organizations: { name: 'Big Co' }).first).not_to be_nil
      end

    end

    it "can be persisted" do
      expect(function.persisted?).to be_truthy
    end

    it "reads its attributes" do
      expect(function.category).to eq 'retailer'
    end

    it "writes its attributes" do
      function.category = 'marketer'
      expect(function.category).to eq 'marketer'
    end

    it "can track its attributes change states" do
      function.category = 'seo'
      expect(function.category_changed?).to be_truthy
    end

    it "can track its attributes change history" do
      function.category = 'development'
      expect(function.category_was).to eq 'retailer'
    end

    it "validates its attributes" do
      invalid_function.valid?
      expect(invalid_function.errors[:category]).not_to be_empty
    end

    it "raises NoMethodError for methods the do not exist on itself or the supermodel" do
      expect{ function.non_existent_method }.to raise_error NoMethodError
    end

    it "does not destroy the supermodel on destruction" do
      organization_id = function.as_organization.id
      function.destroy
      expect{ Organization.find organization_id }.not_to raise_error
    end

    context "from the supermodel" do

      it "inherits attribute readers" do
        expect(function.name).to eq 'Big Co'
      end

      it "inherits attribute writers" do
        function.name = 'New Co'
        expect(function.name).to eq 'New Co'
      end

      it "inherits attribute dirty tracking change state" do
        function.name = 'Dead Co'
        expect(function.name_changed?).to be_truthy
      end

      it "inherits attribute dirty tracking history" do
        function.name = 'Change Co'
        expect(function.name_was).to eq 'Big Co'
      end

      it "inherits attribute typecasting" do
        function.update_attribute(:sales, '42')
        expect(function.sales).to eq 42
      end

      it "inherits methods" do
        expect(function.respond_to? :parent_method).to be_truthy
      end

      it "inherits validations" do
        invalid_function.valid?
        expect(invalid_function.errors.keys).to include :name
      end

      it "inherits associations" do
        function.products << product
        expect(function.products).to include product
      end

    end

  end

end
