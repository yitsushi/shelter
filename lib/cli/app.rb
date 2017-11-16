require 'thor'

require_all(File.join(File.dirname(__FILE__), 'command'))
require_all(File.join(File.dirname(__FILE__), 'stack'))

module Harbor
  module CLI
    # Main Harbor app
    class App < Thor
      class << self
        attr_writer :config
      end

      def self.config
        @config ||= Harbor::Configuration.new
        @config.load_harborfile
        block_given? ? yield(@config) : @config
      end

      register(
        Harbor::CLI::Command::Ansible,
        'ansible',
        'ansible [COMMAND]',
        'Ansible related commands'
      )

      # Register server managers
      path = File.join(App.config.stack_directory, '*')
      Dir.glob(path).each do |path|
        next unless File.exists? "#{path}/cli.rb"
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
      path = File.join(App.config.plugin_directory, '*')
      Dir.glob(path).each do |path|
        next unless File.exists? "#{path}/main.rb"
        require File.join(App.config.project_root, path, 'main.rb')
      end
    end
  end
end

