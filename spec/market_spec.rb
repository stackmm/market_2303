require 'rspec'
require './lib/item'
require './lib/vendor'
require './lib/market'

RSpec.describe Market do
  before(:each) do
    @market = Market.new("South Pearl Street Farmers Market")  
    @vendor1 = Vendor.new("Rocky Mountain Fresh")
    @vendor2 = Vendor.new("Ba-Nom-a-Nom")
    @vendor3 = Vendor.new("Palisade Peach Shack")   
    @item1 = Item.new({name: 'Peach', price: "$0.75"})
    @item2 = Item.new({name: 'Tomato', price: "$0.50"})
    @item3 = Item.new({name: "Peach-Raspberry Nice Cream", price: "$5.30"})
    @item4 = Item.new({name: "Banana Nice Cream", price: "$4.25"})
  end
  describe "#initialize" do
    it "can initialize" do
      expect(@market).to be_an_instance_of(Market)
    end

    it "has attributes" do
      expect(@market.name).to eq("South Pearl Street Farmers Market")
      expect(@market.vendors).to eq([])
    end
  end

  describe "#add_vendor" do
    it "can add a vendor" do
      expect(@market.vendors).to eq([])
      @market.add_vendor(@vendor1)
      expect(@market.vendors).to eq([@vendor1])
      @market.add_vendor(@vendor2)
      expect(@market.vendors).to eq([@vendor1, @vendor2])
      @market.add_vendor(@vendor3)
      expect(@market.vendors).to eq([@vendor1, @vendor2, @vendor3])
    end
  end

  describe "#vendor_names" do
    it "can list the names of all vendors in the market" do
      expect(@market.vendor_names).to eq([])
      @market.add_vendor(@vendor1)
      @market.add_vendor(@vendor2)
      @market.add_vendor(@vendor3)
      expect(@market.vendor_names).to eq(["Rocky Mountain Fresh", "Ba-Nom-a-Nom", "Palisade Peach Shack"])
    end
  end

  describe "#vendors_that_sell" do
    it "can list the vendors that have an item in stock" do
      @market.add_vendor(@vendor1)
      @market.add_vendor(@vendor2)
      @market.add_vendor(@vendor3)
      expect(@market.vendors_that_sell(@item1)).to eq([])
      expect(@market.vendors_that_sell(@item2)).to eq([])
      expect(@market.vendors_that_sell(@item3)).to eq([])
      expect(@market.vendors_that_sell(@item4)).to eq([])
      @vendor1.stock(@item1, 35)
      @vendor1.stock(@item2, 7)
      @vendor2.stock(@item4, 50)
      @vendor2.stock(@item3, 25)
      @vendor3.stock(@item1, 65)
      expect(@market.vendors_that_sell(@item1)).to eq([@vendor1, @vendor3])
      expect(@market.vendors_that_sell(@item2)).to eq([@vendor1])
      expect(@market.vendors_that_sell(@item3)).to eq([@vendor2])
      expect(@market.vendors_that_sell(@item4)).to eq([@vendor2])
    end
  end

  describe "#total_inventory" do
    it "can report the quantities of all items sold at that market" do
      @market.add_vendor(@vendor1)
      @market.add_vendor(@vendor2)
      @market.add_vendor(@vendor3)
      expect(@market.total_inventory).to eq({})
      @vendor1.stock(@item1, 5)
      expect(@market.total_inventory).to eq({@item1 => {:quantity => 5, :vendors => [@vendor1]}})
      @vendor1.stock(@item4, 50)
      expect(@market.total_inventory).to eq({@item1 => {:quantity => 5, :vendors => [@vendor1]}, 
                                            @item4 => {:quantity => 50, :vendors => [@vendor1]}})
      @vendor2.stock(@item2, 10)
      expect(@market.total_inventory).to eq({@item1 => {:quantity => 5, :vendors => [@vendor1]}, 
                                            @item4 => {:quantity => 50, :vendors => [@vendor1]}, 
                                            @item2 => {:quantity => 10, :vendors => [@vendor2]}})
      @vendor3.stock(@item3, 15)
      expect(@market.total_inventory).to eq({@item1 => {:quantity => 5, :vendors => [@vendor1]}, 
                                            @item4 => {:quantity => 50, :vendors => [@vendor1]}, 
                                            @item2 => {:quantity => 10, :vendors => [@vendor2]},
                                            @item3 => {:quantity => 15, :vendors => [@vendor3]}})
      @vendor3.stock(@item4, 25)
      expect(@market.total_inventory).to eq({@item1 => {:quantity => 5, :vendors => [@vendor1]}, 
                                            @item4 => {:quantity => 75, :vendors => [@vendor1, @vendor3]}, 
                                            @item2 => {:quantity => 10, :vendors => [@vendor2]},
                                            @item3 => {:quantity => 15, :vendors => [@vendor3]}})
    end
  end

  describe "#sorted_item_list" do
    it "can report an alphabetically sorted list of the names of all in-stock items (duplicates removed)" do
      @market.add_vendor(@vendor1)
      @market.add_vendor(@vendor2)
      @market.add_vendor(@vendor3)
      expect(@market.sorted_item_list).to eq([])
      @vendor1.stock(@item1, 35)
      expect(@market.sorted_item_list).to eq(["Peach"])
      @vendor1.stock(@item2, 7)
      expect(@market.sorted_item_list).to eq(["Peach", "Tomato"])
      @vendor2.stock(@item4, 50)
      expect(@market.sorted_item_list).to eq(["Banana Nice Cream", "Peach", "Tomato"])
      @vendor3.stock(@item4, 50)
      expect(@market.sorted_item_list).to eq(["Banana Nice Cream", "Peach", "Tomato"])
      @vendor2.stock(@item3, 25)
      expect(@market.sorted_item_list).to eq(["Banana Nice Cream", "Peach", "Peach-Raspberry Nice Cream", "Tomato"])
      @vendor3.stock(@item1, 65)
      expect(@market.sorted_item_list).to eq(["Banana Nice Cream", "Peach", "Peach-Raspberry Nice Cream", "Tomato"])
    end
  end

  describe "#overstocked_items" do
    it "can list items that are overstocked (sold by > 1 vendor and has a total quantity > 50)" do 
      @market.add_vendor(@vendor1)
      @market.add_vendor(@vendor2)
      @market.add_vendor(@vendor3)
      @vendor1.stock(@item1, 35)
      expect(@market.overstocked_items).to eq([])
      @vendor3.stock(@item1, 10)
      expect(@market.overstocked_items).to eq([])
      @vendor3.stock(@item1, 10)
      expect(@market.overstocked_items).to eq([@item1])
      @vendor2.stock(@item4, 50)
      @vendor2.stock(@item3, 25)
      expect(@market.overstocked_items).to eq([@item1])
      @vendor3.stock(@item4, 65)
      expect(@market.overstocked_items).to eq([@item1, @item4])
      @vendor3.stock(@item3, 65)
      expect(@market.overstocked_items).to eq([@item1, @item4, @item3])
    end
  end

end