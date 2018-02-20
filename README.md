Manage your infrastructure in one place Edit

# Getting Started

1. Create a directory for your project:

```
$ mkdir myinfra && cd myinfra
```

2. Create your `Shelterfile.rb` and define your environment:

```ruby
Shelter::CLI::App.config do |c|
  # All of them are optional
  c.ansible_directory = 'ansible'
  c.stack_directory = 'stack'
  c.plugin_directory = 'plugin'
  c.inventory_directory = 'inventory'
  c.resource_directory = 'resources'
  c.secure_root = ENV.fetch('CHEPPERS_SECURE')
end
```

3. Create the directory structure

```
$ mkdir -p ansible stack plugin inventory resources/templates
```

4. Create your first Ansible playbook: `ansible/configuration.yaml`

```yaml
---
- name: Ping all hosts
  hosts: all
  tasks:
    - ping:
```

# Secrets

**TODO: make its own page**

```
# List all existing secret files
bundle exec shelter vault list

# Example how to read aws creds from secure
bundle exec shelter vault view /staging/aws_creds

# Example how to create a new secret file/scope (for format, you can view an existing one)
bundle exec create vault view /staging/something

# Example how to edit a secret file
bundle exec create vault update /staging/nginx_creds
```


# Documentation

- [Resource management](https://yitsushi.github.io/shelter/docs/resource-management/)
- [Inventory scripts](https://yitsushi.github.io/shelter/docs/inventory-scripts/)
- [Define a Stack](https://yitsushi.github.io/shelter/docs/define-a-stack/)
- [Write Your Own Plugin](https://yitsushi.github.io/shelter/docs/write-your-own-plugin/)

## Code Status

[![Gem Version](https://badge.fury.io/rb/shelter.svg)](https://badge.fury.io/rb/shelter)
[![Build Status](https://travis-ci.org/Yitsushi/shelter.svg?branch=master)](https://travis-ci.org/Yitsushi/shelter)

## License

Shelter is released under the [MIT License](http://www.opensource.org/licenses/MIT).
