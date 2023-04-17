class Market 
  attr_reader :name, :vendors

  def initialize(name)
    @name = name
    @vendors = []
  end

  def add_vendor(vendor)
    @vendors << vendor
  end

  def vendor_names
    @vendors.map do |vendor|
      vendor.name
    end
  end

  def vendors_that_sell(item)
    @vendors.find_all do |vendor|
      vendor.check_stock(item) > 0
    end
  end

  def total_inventory 
    total_inventory = Hash.new { |hash, key| hash[key] = { quantity: 0, vendors: []}}

    @vendors.each do |vendor|
      vendor.inventory.each do |item, quantity|
        total_inventory[item][:quantity] += quantity
        total_inventory[item][:vendors] << vendor 
      end
    end

    total_inventory
  end

  def sorted_item_list 
    list = []

    @vendors.each do |vendor|
      vendor.inventory.each do |item, quantity|
        list << item.name
      end
    end
    
    list.uniq.sort
  end

  def overstocked_items 
    total_inventory.select do |item, hash|
      hash[:quantity] > 50 && hash[:vendors].length > 1
    end.keys
  end

end