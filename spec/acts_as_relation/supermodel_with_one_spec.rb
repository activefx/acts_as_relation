require "spec_helper"

describe "supermodel with one submodel" do

  let(:pen) { Pen.create name: 'RedPen', price: 0.8, color: 'red' }

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

end
