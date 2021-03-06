require 'spec_helper'

describe User do
  before do
    @user = User.create(
                        :email => "testuser@example.com", 
                        :password => "password", 
                        :password_confirmation => "password")
  end
  after do
    @user.delete
  end
  it "should have an email" do
    @user.email.should == "testuser@example.com"
  end
  it "should have zero batches by default" do
    Batch.find(:all, :query => {:creator => @user.email}).count.should == 0
  end
  it "should now have one batch" do
    f = Batch.create(:batch_creator => @user.email)
    Batch.find(:all, :query => {:creator => @user.email}).count.should == 1
    f.delete
  end
end
