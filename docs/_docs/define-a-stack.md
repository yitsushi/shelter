---
title: Define a Stack
permalink: /docs/define-a-stack/
---

Create a directory under your `stack` directory (eg: `random_stack`)
and create your template there. `cli.rb` will be loaded.

```ruby
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
    set_attr :capabilities, ['CAPABILITY_IAM']
    set_attr :tags, {
      my_extra: 'my extra tag'
    }
    set_attr :parameters, {
      SSHKeyName: 'random-one'
    }
    set_attr :deletable, true
  end
end
```

Define your CloudFormation template in the `template.yaml` file
under the same directory.

**[Soon, I will update this as well]**

If you want to collaborate on documentation, you can find
the [relevant ticket here](https://github.com/Yitsushi/shelter/issues/4).
