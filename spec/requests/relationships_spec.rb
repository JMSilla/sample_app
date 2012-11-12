require 'spec_helper'

describe "Relationships" do
  before(:each) do
    @user = Factory(:user)
    @user2 = Factory(:user, :email => Factory.next(:email))
    visit signin_path
    fill_in :email, :with => @user.email
    fill_in :password, :with => @user.password
    click_button
  end

  describe "following" do
    it "should follow another user" do
      lambda do
        visit user_path(@user2)
        click_button 'Follow'
        response.should have_selector("span#followers", 
                                      :content => '1 follower')
        visit user_path(@user)
        response.should have_selector("span#following", 
                                      :content => '1 following')
      end.should change(Relationship, :count).by(1) 
    end
  end

  describe "unfollowing" do
    before(:each) do
      @user.follow!(@user2)
    end

    it "should unfollow another user" do
      lambda do
        visit user_path(@user2)
        click_button 'Unfollow'
        response.should have_selector("span#followers", 
                                      :content => '0 followers')
        visit user_path(@user)
        response.should have_selector("span#following", 
                                      :content => '0 following')
      end.should change(Relationship, :count).by(-1)
    end
  end
end
