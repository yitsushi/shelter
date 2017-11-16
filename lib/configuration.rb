# frozen_string_literal: true

module Shelter
  # Read and manage configuration
  class Configuration
    attr_accessor :ansible_directory,
                  :stack_directory,
                  :secure_root,
                  :inventory_script,
                  :inventory_directory,
                  :plugin_directory

    attr_reader   :project_root

    def initialize
      @ansible_directory = 'ansible'
      @stack_directory = 'stacks'
      @secure_root = ENV.fetch('SECURE', 'secure')
      @inventory_script = File.join(
        File.dirname($PROGRAM_NAME),
        'shelter-inventory'
      )
      @inventory_directory = 'inventory'
      @plugin_directory = 'plugin'
    end

    def load_shelterfile
      load shelterfile if @shelterfile.nil?
    end

    def inventory
      path = File.join(@inventory_directory, '*')
      Dir.glob(path)
    end

    private

    def shelterfile
      @shelterfile ||= File.join(find_project_root, 'Shelterfile.rb')
    end

    def find_project_root
      @project_root unless @project_root.nil?

      dir = Dir.pwd
      loop do
        break if File.exist?('Shelterfile.rb')
        raise 'No Shelterfile.rb found' if Dir.pwd == '/'
        Dir.chdir('..')
      end
      @project_root = Dir.pwd
      Dir.chdir dir
      @project_root
    end
  end
end
