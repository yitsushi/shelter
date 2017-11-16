# Configuration

Create `Shelterfile.rb`:

```
Shelter::CLI::App.config do |c|
  c.ansible_directory = 'ansible'
  c.stack_directory = 'stack'
  c.plugin_directory = 'plugin'
  c.inventory_directory = 'inventory'
  c.secure_root = ENV.fetch('CHEPPERS_SECURE')
end
```

# Inventory script

Create a ruby file under your inventory directory:

```
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

# Define a stack

Create a directory under your `stack` directory (eg: `random`)
and create your template there. `cli.rb` will be loaded.

```
# stack/random_stack/cli.rb:
module Stack
  class RandomStack < Shelter::CLI::Stack::CloudFormation
    set_attr :stack_name, 'random'
    set_attr :template_file, File.expand_path('template.yaml', File.dirname(__FILE__))
    set_attr :meta, {
      type: 'development',
      client: 'cheppers',
      application: 'random'
    }
  end
end
```

# Create plugin

Create a directory under your `plugin` directory and place your code there.
`main.rb` will be loaded.

### Example #1: extra command

```
# plugin/check/main.rb
require 'thor'

module Plugin
  class Check < Thor
    desc 'environment', 'Check environment'
    def environment
      puts "check"
    end
  end
end

Shelter::CLI::App.register(Plugin::Check, 'check', 'check [COMMAND]', 'check plugin')
```

### Example #2: extra command under a specific namespace

```
# plugin/ansible_scanner/main.rb
require 'thor'

module Plugin
  class Ansible < Thor
    desc 'scanner', 'scanner'
    def scanner
      puts "scan"
    end

    default_task :scanner
  end
end

Shelter::CLI::Command::Ansible.register(Plugin::Ansible, 'scanner', 'scanner', 'Scan')
```
