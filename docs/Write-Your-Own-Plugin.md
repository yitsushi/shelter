Create a directory under your `plugin` directory and place your code there.
`main.rb` will be loaded.

### Example #1: extra command

```ruby
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

```ruby
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