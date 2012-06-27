require 'spec_helper'

describe Offer do
  it {should belong_to(:need)}
  it {should belong_to(:user)}
  it {should validate_presence_of(:text)}
  it {should validate_presence_of(:user)}
  it {should validate_presence_of(:need)}
  
  describe do
    
    let(:offer) {FactoryGirl.build(:offer, :user => FactoryGirl.build_stubbed(:user))}
    
    it "should be valid" do
      offer.should be_valid
    end
    
    it "should be valid if it is the only accepted offer" do
      offer.accepted = true
      offer.should be_valid
    end
    
    it "should be invalid if there is already an accepted offer" do
      # This is working in console, need to fix test
      need = FactoryGirl.create(:need)
      offer1 = FactoryGirl.create(:offer, :user => FactoryGirl.build_stubbed(:user), :need => need, :accepted => true)
      offer2 = FactoryGirl.create(:offer, :user => FactoryGirl.build_stubbed(:user), :need => need, :accepted => true)
      offer2.valid?
      puts offer2.errors.inspect
      offer2.should be_invalid
    end
    
  end    
  
end
