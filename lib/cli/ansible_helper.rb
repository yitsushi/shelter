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

      def optional_params(tags: [], skip: [], limit: nil)
        command = []
        command << "--tags '#{tags.join(',')}'" unless tags.empty?
        command << "--skip-tags '#{skip.join(',')}'" unless skip.empty?
        command << "--limit '#{limit}'" unless limit.nil?
        command
      end

      def ansible_execute(
        playbook,
        server_user: nil, inventory: nil,
        tags: [], skip: [], limit: nil
      )
        command = [command_bin, inventory_file(inventory), vault_password_file]
        command += new_server_params(server_user)
        command += optional_params(tags: tags, skip: skip, limit: limit)
        command << "#{App.config.ansible_directory}/#{playbook}.yaml"

        full_command = command.join(' ')
        system full_command
      end
    end
  end
end
