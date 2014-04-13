require "spec_helper"

describe "supermodel with many submodels" do

  let(:organization) do
    Organization.create do |o|
      o.name = 'Some Co'
    end
  end

  context "#specific" do

    let!(:org_id) { organization.id }

    before do
      Function.create(name: 'Some Co', category: 'manufacturer', as_organization_id: org_id)
      Function.create(name: 'Some Co', category: 'retailer', as_organization_id: org_id)
    end

    it "returns the submodels" do
      org = Organization.find(org_id)
      expect(org.specific.count).to eq 2
    end

  end

  context "#is_a?" do

    it "returns true when it is an instance of the same class" do
      expect(organization.is_a? Organization).to be_true
    end

  end

end
