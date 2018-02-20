# frozen_string_literal: true

require 'thor'

require_all(File.join(File.dirname(__FILE__), 'helpers'))
require_all(File.join(File.dirname(__FILE__), 'command'))
require_all(File.join(File.dirname(__FILE__), 'stack'))

module Shelter
  module CLI
    # Main Shelter app
    class App < Thor
      class << self
        attr_writer :config
      end

      def self.config
        @config ||= Shelter::Configuration.new
        @config.load_shelterfile
        block_given? ? yield(@config) : @config
      end

      if File.directory?(App.config.ansible_directory)
        register(
          Shelter::CLI::Command::Ansible,
          'ansible',
          'ansible [COMMAND]',
          'Ansible related commands'
        )

        register(
          Shelter::CLI::Command::Vault,
          'vault',
          'vault [COMMAND]',
          'Ansible Vault related commands'
        )
      end

      if File.directory?(App.config.resource_directory)
        register(
          Shelter::CLI::Command::Resource,
          'resource',
          'resource [COMMAND]',
          'Resource management'
        )
      end

      # Register server managers
      base_path = File.join(App.config.stack_directory, '*')
      Dir.glob(base_path).each do |path|
        next unless File.exist? "#{path}/cli.rb"
        require File.join(App.config.project_root, path, 'cli.rb')

        stack_name = File.basename(path)
        register(
          Object.const_get("Stack::#{stack_name.camelize}"),
          stack_name,
          "#{stack_name} [COMMAND]",
          "Manage #{stack_name.camelize} stack"
        )
      end

      # Register server managers
      base_path = File.join(App.config.plugin_directory, '*')
      Dir.glob(base_path).each do |path|
        next unless File.exist? "#{path}/main.rb"
        require File.join(App.config.project_root, path, 'main.rb')
      end
    end
  end
end
