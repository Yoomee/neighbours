require 'spec_helper'

describe Need do
  it {should belong_to(:user)}
  it {should have_many(:offers)}
  it {should have_one(:accepted_offer)}
  it {should validate_presence_of(:user)}
  it {should validate_presence_of(:title)}
  it {should validate_presence_of(:description)}    
  
  describe do
    
    let(:need) {FactoryGirl.create(:need)}
    
    it "should be valid" do
      need.should be_valid
    end
    
  end    
  
end
