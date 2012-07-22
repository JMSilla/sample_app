# -*- coding: utf-8 -*-
require 'spec_helper'

describe MicropostsController do
  render_views

  describe "access control" do
    it "should deny access to 'create'" do
      post :create
      response.should redirect_to(signin_path)
    end

    it "should deny access to 'destroy'" do
      delete :destroy, :id => 1
      response.should redirect_to(signin_path)
    end
  end

  describe "POST 'create'" do
    before(:each) do
      @user = test_sign_in(Factory(:user))
    end

    describe "failure" do
      before(:each) do
        @attr = { :content => "" }
      end

      it "should not create a micropost" do
        lambda do
          post :create, :micropost => @attr
        end.should_not change(Micropost, :count)
      end

      it "should render the home page" do
        post :create, :micropost => @attr
        response.should render_template('pages/home')
      end
    end
    
    describe "success" do
      before(:each) do
        @attr = { :content => "Lorem ipsum" }
      end

      it "should create a micropost" do
        lambda do
          post :create, :micropost => @attr
        end.should change(Micropost, :count).by(1)
      end

      it "should redirect to the home page" do
        post :create, :micropost => @attr
        response.should redirect_to(root_path)
      end

      it "should have a flash message" do
        post :create, :micropost => @attr
        flash[:success].should =~ /micropost created/i
      end
    end
  end

  describe "DELETE 'destroy'" do
    describe "for an unauthorized user" do
      before(:each) do
        @user = Factory(:user)
        wrong_user = Factory(:user, :email => Factory.next(:email))
        test_sign_in(wrong_user)
        @micropost = Factory(:micropost, :user => @user)
      end

      it "should deny access" do
        delete :destroy, :id => @micropost
        response.should redirect_to(root_path)
      end
    end

    describe "for an authorized user" do
      before(:each) do
        @user = test_sign_in(Factory(:user))
        @micropost = Factory(:micropost, :user => @user)
      end

      it "should destroy the micropost" do
        lambda do
          delete :destroy, :id => @micropost
        end.should change(Micropost, :count).by(-1)
      end
    end
  end

  describe "GET 'users/index'" do
    before(:each) do
      @user = Factory(:user)
      @mp1 = Factory(:micropost, :user => @user)
      @mp2 = Factory(:micropost, :user => @user, :content => 'Prueba aaa')
    end

    it "should be valid" do
      get :index, :user_id => @user
      response.should be_success
    end
    
    it "should render the microposts index page" do
      get :index, :user_id => @user
      response.should render_template('microposts/index')
    end

    it "should show the user's microposts" do
      get :index, :user_id => @user
      response.should have_selector("div.micropost",
                                    :content => @mp1.content)
      response.should have_selector("div.micropost",
                                    :content => @mp2.content)
    end
    
    describe "microposts pagination" do
      before(:each) do
        30.times do
          Factory(:micropost, :user => @user)
        end
      end
      
      it "should paginate the user's microposts" do
        get :index, :user_id => @user
        response.should have_selector("div.pagination")
        response.should have_selector("span.disabled", :content => "Previous")
        response.should have_selector("a",
                                      :content => '2',
                                      :href => "#{user_microposts_path(@user)}?page=2")
        response.should have_selector("a",
                                      :content => 'Next',
                                      :href => "#{user_microposts_path(@user)}?page=2")
      end
    end
  end
end
