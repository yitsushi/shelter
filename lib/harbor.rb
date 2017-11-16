require 'version'
require 'configuration'

directories = %w(
  ansible
  cli
)

class String
  def camelize(uppercase_first_letter = true)
    string = self
    if uppercase_first_letter
      string = string.sub(/^[a-z\d]*/) { $&.capitalize }
    else
      string = string.sub(/^(?:(?=\b|[A-Z_])|\w)/) { $&.downcase }
    end
    string.gsub(/(?:_|(\/))([a-z\d]*)/) { "#{$1}#{$2.capitalize}" }.gsub('/', '::')
  end
end

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

