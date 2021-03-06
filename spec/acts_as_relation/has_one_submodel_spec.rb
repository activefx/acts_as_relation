require "spec_helper"

RSpec.describe "has one submodel" do

  let(:store) { Store.create name: 'Big Store' }
  let(:pen) { Pen.create name: 'RedPen', price: 0.8, color: 'red' }
  let(:invalid_pen) { Pen.new }

  context "options" do

    let(:klass) { GenericModel }

    context ":as" do

      context "when nil" do

        let(:association) { klass.reflect_on_association(:as_product) }

        it "sets up the association" do
          expect(association).not_to be_nil
        end

        it "the association name is inferred from the acts_as name" do
          expect(association.options[:as])
            .to eq GenericModel.acts_as_association_name(:product.to_s.underscore.singularize)
        end

      end

      context "when specifying a name" do

        let(:association) { klass.reflect_on_association(:storeable) }

        it "sets up the association" do
          expect(association).not_to be_nil
        end

        it "the association name is inferred from the acts_as name" do
          expect(association.options[:as]).to eq :storeable
        end

      end

    end

    context ":dependent" do

      context "when nil" do

        let(:association) { klass.reflect_on_association(:as_product) }

        it "it is set to :destroy" do
          expect(association.options[:dependent]).to eq :destroy
        end

      end

      context "when configured" do

        let(:association) { klass.reflect_on_association(:storeable) }

        it "is set to the specified option" do
          expect(association.options[:dependent]).to eq :nullify
        end

      end

    end

    context ":validate" do

      context "when nil" do

        let(:association) { klass.reflect_on_association(:as_product) }

        it "it is set to false" do
          expect(association.options[:validate]).to be_falsey
        end

      end

      context "when set to true" do

        let(:association) { klass.reflect_on_association(:storeable) }

        it "is set to the specified option" do
          expect(association.options[:validate]).to be_truthy
        end

      end

    end

    context ":foreign_key" do

      context "when nil" do

        let(:association) { klass.reflect_on_association(:as_product) }

        it "it is set to the name of the association" do
          expect(association.options[:foreign_key]).to eq 'as_product_id'
        end

      end

      context "when configured" do

        let(:association) { klass.reflect_on_association(:storeable) }

        it "is set to the specified option" do
          expect(association.options[:foreign_key]).to eq 'other_id'
        end

      end

    end

    context ":auto_join" do

      context "when nil" do

        before { pen }

        it "is enabled by default" do
          expect(Pen.where('name = ?', 'RedPen')).to include pen
        end

      end

      context "when false" do

        it "is set to the specified option" do
          expect{ Pencil.where('name = 1').first }
            .to raise_error ActiveRecord::StatementInvalid
        end

      end

    end

  end

  context "::acts_as_other_model?" do

    it "returns true when an acts_as relationship is defined" do
      expect(Pen.acts_as_other_model?).to be_truthy
    end

    it "returns false when an acts_as relationship is not defined" do
      expect(Store.acts_as_other_model?).to be_falsey
    end

  end

  context "::acts_as_model_name" do

    it "returns the supermodel name" do
      expect(Pen.acts_as_model_name).to eq :product
    end

  end

  context "::is_a?" do

    let(:ballpoint) { BallpointPen.new }

    it "returns true when it is an instance of the same class" do
      expect(pen.is_a? Pen).to be_truthy
    end

    it "returns true when it is an instance of the supermodel" do
      expect(pen.is_a? Product).to be_truthy
    end

    it "returns true when it is an inherited instance of the same class" do
      expect(ballpoint.is_a? Pen).to be_truthy
    end

    it "returns true when it is an inherited instance of the supermodel" do
      expect(ballpoint.is_a? Product).to be_truthy
    end

    it "returns false for unrelated classes" do
      expect(pen.is_a? String).to be_falsey
    end

    it "is aliased to kind_of?" do
      expect(ballpoint.kind_of? Product).to be_truthy
    end

    it "is aliased to instance_of?" do
      expect(ballpoint.instance_of? Product).to be_truthy
    end

  end

  context "::where" do

    before { pen }

    it "allows searching by supermodel attributes" do
      expect(Pen.where(products: { name: 'RedPen' }).first).not_to be_nil
    end

  end

  it "can be persisted" do
    expect(pen.persisted?).to be_truthy
  end

  it "reads its attributes" do
    expect(pen.color).to eq 'red'
  end

  it "writes its attributes" do
    pen.color = 'blue'
    expect(pen.color).to eq 'blue'
  end

  it "can track its attributes change states" do
    pen.color = 'orange'
    expect(pen.color_changed?).to be_truthy
  end

  it "can track its attributes change history" do
    pen.color = 'white'
    expect(pen.color_was).to eq 'red'
  end

  it "validates its attributes" do
    invalid_pen.valid?
    expect(invalid_pen.errors[:color]).not_to be_empty
  end

  it "raises NoMethodError for methods that do not exist on itself or the supermodel" do
    expect{ pen.non_existent_method }.to raise_error NoMethodError
  end

  it "raises NoMethodError correctly for supermodel methods" do
    expect{ pen.dummy_raise_method(nil) }
      .to raise_error NoMethodError, /undefined method `dummy' for nil:NilClass/
  end

  it "destroys the supermodel on destruction" do
    product_id = pen.as_product.id
    pen.destroy
    expect{ Product.find product_id }.to raise_error ActiveRecord::RecordNotFound
  end

  context "from the supermodel" do

    it "inherits attribute readers" do
      expect(pen.name).to eq 'RedPen'
    end

    it "inherits attribute writers" do
      pen.name = 'BluePen'
      expect(pen.name).to eq 'BluePen'
    end

    it "inherits attribute dirty tracking change state" do
      pen.name = 'GreenPen'
      expect(pen.name_changed?).to be_truthy
    end

    it "inherits attribute dirty tracking history" do
      pen.name = 'BlackPen'
      expect(pen.name_was).to eq 'RedPen'
    end

    it "inherits attribute typecasting" do
      pen.update_attribute(:price, '42')
      expect(pen.price).to eq 42
    end

    it "inherits methods" do
      expect(pen.respond_to? :parent_method).to be_truthy
    end

    it "inherits validations" do
      invalid_pen.valid?
      expect(invalid_pen.errors.keys).to include :name, :price
    end

    it "inherits associations" do
      pen.update_attribute(:store, store)
      expect(Pen.find(pen.id).store).to eq store
    end

    it "inherits accessible attributes" do
      expect(Pen.attr_accessible[:default].to_a)
        .to include *Product.attr_accessible[:default].to_a
    end

  end

end
