# 0.0.5 (2010-06-13)
* Implemented smart associations, e.g.
    category_by_name: Sport                          # => @car.category = Category.find_by_name("Sport")
    sellers_by_name_and_active: [Hugo, true]         # @car.sellers = Seller.find_all_by_name_and_active("Hugo", true)
    sellers_by_name_and_active: [[Hugo, Egon], true] # @car.sellers = Seller.find_all_by_name_and_active(["Hugo", "Egon"], true)
* mark objects as modified when saved with save!

# 0.0.4 (2010-06-11)
* fix some bugs esp. wrt associations
* added a on_seed hook which allows for custom login on seed

# 0.0.3 (2010-06-10)
* Add a rake task for dumping the current database objects into an alter_egos YAML file
* Do not bring back destroyed objects

# 0.0.2 (2010-06-09)
* Added Rails3 support

# 0.0.1 (2010-06-09)
* Initial release with basic functionality
