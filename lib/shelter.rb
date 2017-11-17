# frozen_string_literal: true

require 'version'
require 'configuration'

directories = %w[
  ansible
  cli
]

# Extend String class with camelize
class String
  def camelize(uppercase_first_letter = true)
    string = self
    string = if uppercase_first_letter
               string.sub(/^[a-z\d]*/) { $&.capitalize }
             else
               string.sub(/^(?:(?=\b|[A-Z_])|\w)/) { $&.downcase }
             end
    string.gsub(%r{(?:_|(/))([a-z\d]*)}) do
      "#{Regexp.last_match(1)}#{Regexp.last_match(2).capitalize}"
    end.gsub('/', '::')
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
