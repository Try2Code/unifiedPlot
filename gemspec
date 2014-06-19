require 'rubygems'

GEM_SPEC = Gem::Specification.new do |s|
  s.name              = "unifiedPlot"
  s.version           = '0.0.4'
  s.date              = Time.new.strftime("%Y-%m-%d")

  s.description       = 'single interface to line-plotting data in [],NArray and GSL::Vector format'
  s.summary           = 'simple line plot for array-based inputs'

  s.platform          = Gem::Platform::RUBY
  s.files             = ["lib/unifiedPlot.rb"] + ["gemspec"]
  s.require_path      = 'lib'

  s.author            = "Ralf Mueller"
  s.email             = "stark.dreamdetective@gmail.com"
  s.homepage          = "https://github.com/Try2Code/unifiedPlot"
  s.licenses          = ['BSD']

  s.has_rdoc          = false
end

# vim:ft=ruby
