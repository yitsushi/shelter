# frozen_string_literal: true

module Shelter
  module CLI
    # Mixin module for Ansible
    module AnsibleHelpers
      def vault_password_file
        [
          '--vault-password-file',
          "#{App.config.secure_root}/ansible_vault_password"
        ].join(' ')
      end

      def inventory_file(inventory)
        inventory ||= App.config.inventory_script
        "--inventory #{inventory}"
      end

      def command_bin
        'ansible-playbook'
      end

      def new_server_params(server_user)
        command = []
        command << "--user #{server_user} --ask-pass" unless server_user.nil?
        command
      end

      def optional_params(opts)
        command = []
        command << "--tags '#{opts[:tags].join(',')}'" unless opts[:tags].empty?
        command << "--skip-tags '#{opts[:skip].join(',')}'" unless
          opts[:skip].empty?
        command << "--limit '#{opts[:limit]}'" unless opts[:limit].nil?
        command
      end

      # server_user: nil, inventory: nil,
      # tags: [], skip: [], limit: nil
      def ansible_execute(playbook, options = {})
        params = {
          inventory: nil, server_user: nil, tags: [], skip: [], limit: nil
        }.merge(options)
        command = [command_bin, inventory_file(params[:inventory]),
                   vault_password_file]
        command += new_server_params(params[:server_user])
        command += optional_params(params)
        command << "#{App.config.ansible_directory}/#{playbook}.yaml"

        full_command = command.join(' ')
        system full_command
      end
    end
  end
end
