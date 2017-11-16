require 'version'
require 'configuration'

directories = %w(
  ansible
  cli
)

LIB_ROOT = File.expand_path('../', __FILE__)

def require_all(dir)
  path = File.join(dir, '*')
  Dir.glob(path).each do |file|
    require file if File.file?(file)
    require_all(file) if File.directory?(file)
  end
end

directories.each do |dir|
  require_all(File.join(File.dirname(__FILE__), dir))
end
