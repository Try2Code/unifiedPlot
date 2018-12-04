require 'rubygems'

spec = Gem::Specification.new do |s|
  s.name              = "unifiedPlot"
  s.version           = '0.0.6'
  s.date              = Time.new.strftime("%Y-%m-%d")

  s.description       = 'single interface to line-plotting data in [] or NArray'
  s.summary           = 'simple line plot for array-based inputs'

  s.platform          = Gem::Platform::RUBY
  s.files             = ["lib/unifiedPlot.rb"] + ["gemspec"]
  s.require_path      = 'lib'

  s.author            = "Ralf Mueller"
  s.email             = "stark.dreamdetective@gmail.com"
  s.homepage          = "https://github.com/Try2Code/unifiedPlot"
  s.licenses          = '0BSD'

  s.has_rdoc          = false
  s.required_ruby_version = ">= 1.9"
  s.add_development_dependency 'gnuplot', '~> 0'
  s.add_development_dependency 'narray', '~> 0'
end

# vim:ft=ruby
