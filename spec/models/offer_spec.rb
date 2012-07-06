require 'spec_helper'

describe Offer do
  it {should belong_to(:need)}
  it {should belong_to(:user)}
  it {should validate_presence_of(:user)}
  it {should validate_presence_of(:need)}
  
  describe do
    
    let(:offer) {FactoryGirl.create(:offer)}
    
    it "should be valid" do
      offer.should be_valid
    end
    
    it "should be valid if it is the only accepted offer" do
      offer.accepted = true
      offer.should be_valid
    end
    
    it "should be invalid if there is already an accepted offer" do
      # This is working in console, need to fix test
      offer.update_attribute(:accepted, true)
      offer2 = FactoryGirl.build(:offer, :need => offer.need, :accepted => true)
      offer2.should_not be_valid
    end
    
  end    
  
end
