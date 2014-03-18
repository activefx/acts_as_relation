require "spec_helper"

describe "supermodel with many submodels" do

  let(:organization) { Organization.create(name: 'Some Co') }

  context "#specific" do

    let!(:org_id) { organization.id }

    before do
      Function.create(name: 'Some Co', category: 'manufacturer', as_organization_id: org_id)
      Function.create(name: 'Some Co', category: 'retailer', as_organization_id: org_id)
    end

    it "returns the submodels" do
      expect(Organization.first.specific.count).to eq 2
    end

  end

  context "#is_a?" do

    it "returns true when it is an instance of the same class" do
      expect(organization.is_a? Organization).to be_true
    end

  end

end
