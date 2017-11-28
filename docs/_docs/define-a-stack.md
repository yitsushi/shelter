---
title: Define a Stack
permalink: /docs/define-a-stack/
---

Create a directory under your `stack` directory (eg: `random`)
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
  end
end
```
