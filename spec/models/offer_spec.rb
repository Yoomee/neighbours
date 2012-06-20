require 'spec_helper'

describe Offer do
  it {should belong_to(:need)}
  it {should belong_to(:user)}
  it {should validate_presence_of(:text)}
  
  describe do
    
    let(:offer) {FactoryGirl.create(:offer)}
    
    it "should be valid" do
      offer.should be_valid
    end
    
  end    
  
end
