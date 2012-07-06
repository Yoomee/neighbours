require 'spec_helper'

describe Flag do
  it {should belong_to(:user)}
  it {should belong_to(:resource)}
  
  describe do
    
    let(:flag) {FactoryGirl.create(:flag)}
    
    it "should be valid" do
      flag.should be_valid
    end
    
  end    
  
end
