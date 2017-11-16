require 'thor'

module Shelter
  module CLI
    module Command
      # Ansible subcommand for Shelter
      class Ansible < Thor
        desc 'update', 'update existing infrastructure'
        method_option :only,
                      default: [], type: :array,
                      desc: 'Execute only these tags'
        method_option :skip,
                      default: [], type: :array,
                      desc: 'Skip these tags'
        method_option :limit,
                      type: :string,
                      desc: 'Limit to a specific group or host'
        method_option :inventory,
                      type: :string,
                      default: nil,
                      desc: 'Specify inventory file/script'
        def update
          ansible_execute(
            'configuration',
            tags: options[:only],
            skip: options[:skip],
            limit: options[:limit],
            inventory: options[:inventory]
          )
        end

        no_commands do
          include Shelter::CLI::AnsibleHelpers
        end
      end
    end
  end
end

