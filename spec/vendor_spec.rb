require 'rspec'
require './lib/item'
require './lib/vendor'

RSpec.describe Vendor do
  before(:each) do
    @vendor = Vendor.new("Rocky Mountain Fresh")
    @item1 = Item.new({name: 'Peach', price: "$0.75"})
    @item2 = Item.new({name: 'Tomato', price: '$0.50'})
  end
  describe "#initialize" do
    it "can initialize" do
      expect(@vendor).to be_an_instance_of(Vendor)
    end

    it "has attributes" do
      expect(@vendor.name).to eq("Rocky Mountain Fresh")
      expect(@vendor.inventory).to eq({})
    end
  end

  describe "#check_stock" do
    it "can check the stock of an item" do 
      expect(@vendor.check_stock(@item1)).to eq(0)
    end
  end

end