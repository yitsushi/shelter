Create a ruby file under your inventory directory:

```ruby
# inventory/my_inventory.rb
module Inventory
  class MyInventory
    def load(inventory)
      inventory.add_group_vars 'groupname', ch_env: 'value'
      inventory.add_server 'groupname', 'ip-address'
    end
  end
end
```