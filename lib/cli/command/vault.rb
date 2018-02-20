# frozen_string_literal: true

require 'thor'

module Shelter
  module CLI
    module Command
      # Ansible vault subcommand for Shelter
      class Vault < Thor
        desc 'create NAME', 'create a secret file; Name without extension'
        def create(file)
          vault_execute('create', file)
        end

        desc 'update NAME', 'update a secret file; Name without extension'
        def update(file)
          vault_execute('edit', file)
        end

        desc 'view NAME', 'view a secret file; Name without extension'
        def view(file)
          vault_execute('view', file)
        end

        desc 'list', 'list existsing secret files'
        def list
          file_list = Dir["#{App.config.secure_root}/**/*_secret.yaml"]
          puts file_list.map do |f|
            "  #{f.sub(App.config.secure_root, '').sub('_secret.yaml', '')}"
          end.join("\n")
        end

        no_commands do
          include Shelter::CLI::Helpers::Ansible
        end
      end
    end
  end
end
