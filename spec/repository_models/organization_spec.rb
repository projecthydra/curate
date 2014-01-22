require 'spec_helper'

describe Organization do
  let(:organization) { Organization.new}
  let(:person) { FactoryGirl.create(:person)}


  it 'should do something' do
    expect( organization.members ).to eq([])
    organization.add_member(person)
    expect( organization.members ).to include(person)
  end
end