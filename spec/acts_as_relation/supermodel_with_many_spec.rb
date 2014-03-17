require "spec_helper"

describe "supermodel with many submodels" do

  context "#specific" do

    let!(:organization) { Organization.create(name: 'Some Co') }
    let(:org_id) { organization.id }

    before do
      Function.create(name: 'Some Co', category: 'manufacturer', as_organization_id: org_id)
      Function.create(name: 'Some Co', category: 'retailer', as_organization_id: org_id)
    end

    it "returns the submodels" do
      expect(Organization.first.specific.count).to eq 2
    end

  end

end
