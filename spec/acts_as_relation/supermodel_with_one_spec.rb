require "spec_helper"

RSpec.describe "supermodel with one submodel" do

  let(:pen) { Pen.create name: 'RedPen', price: 0.8, color: 'red' }
  let(:product) { Product.new }

  context "options" do

    context ":as" do

      it "specifies the association name" do
        expect(Pen.reflect_on_association(:writable)).not_to be_nil
      end

    end

  end

  context "#specific" do

    let(:supermodel) { pen.as_product }

    it "returns the submodel" do
      expect(supermodel.specific).to eq pen
    end

  end

  context "#is_a?" do

    it "returns true when it is an instance of the same class" do
      expect(product.is_a? Product).to be_truthy
    end

  end

end
