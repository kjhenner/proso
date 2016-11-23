lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

Gem::Specification.new do |spec|
  spec.name          = 'proso'
  spec.version       = '0.0.0'
  spec.authors       = ['Kevin Henner']
  spec.email         = ['kjhenner@gmail.com']
  spec.summary       = "A tool for parsing prosody"
  spec.files         = [ 'README.md' ]
  spec.files        += Dir['{bin,lib,data}/**/*']
  spec.executables   = ['proso']
  spec.require_paths = ['lib']
end
