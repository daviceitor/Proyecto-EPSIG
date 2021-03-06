require 'spec_helper'

describe OfferTypesController do
  describe "routing" do
    it "recognizes and generates #index" do
      { :get => "/offer_types" }.should route_to(:controller => "offer_types", :action => "index")
    end

    it "recognizes and generates #new" do
      { :get => "/offer_types/new" }.should route_to(:controller => "offer_types", :action => "new")
    end

    it "recognizes and generates #show" do
      { :get => "/offer_types/1" }.should route_to(:controller => "offer_types", :action => "show", :id => "1")
    end

    it "recognizes and generates #edit" do
      { :get => "/offer_types/1/edit" }.should route_to(:controller => "offer_types", :action => "edit", :id => "1")
    end

    it "recognizes and generates #create" do
      { :post => "/offer_types" }.should route_to(:controller => "offer_types", :action => "create") 
    end

    it "recognizes and generates #update" do
      { :put => "/offer_types/1" }.should route_to(:controller => "offer_types", :action => "update", :id => "1") 
    end

    it "recognizes and generates #destroy" do
      { :delete => "/offer_types/1" }.should route_to(:controller => "offer_types", :action => "destroy", :id => "1") 
    end
  end
end
