module Harbor
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
      @inventory_script = File.join(File.dirname($PROGRAM_NAME), 'harbor-inventory')
      @inventory_directory = 'inventory'
      @plugin_directory = 'plugin'
    end

    def load_harborfile
      load harborfile if @harborfile.nil?
    end

    def inventory
      path = File.join(@inventory_directory, '*')
      Dir.glob(path)
    end

    private
    def harborfile
      @harborfile ||= File.join(find_project_root, 'Harborfile.rb')
    end

    def find_project_root
      @project_root unless @project_root.nil?

      dir = Dir.pwd
      loop do
        break if File.exist?('Harborfile.rb')
        fail 'No Harborfile.rb found' if Dir.pwd == '/'
        Dir.chdir('..')
      end
      @project_root = Dir.pwd
      Dir.chdir dir
      @project_root
    end
  end
end

