Gem::Specification.new do |s|
  s.name        = 'ruby-cleverdome'
  s.version     = '0.0.1'
  s.date        = '2014-04-09'
  s.summary     = "RubyCleverdome"
  s.description = "Ruby client to access CleverDome."
  s.authors     = ["Alex Gorbunov"]
  s.email       = 'sanyo.gorbunov@gmail.com'
  s.files       = ["lib/ruby-cleverdome.rb"]
  s.homepage    =
    'https://github.com/SanyoGorbunov/ruby-cleverdome/'

  s.add_dependency 'savon', ['~> 2.0']
  s.add_dependency 'signed_xml'
  s.add_dependency 'nokogiri'
  s.add_dependency 'uuid'
end