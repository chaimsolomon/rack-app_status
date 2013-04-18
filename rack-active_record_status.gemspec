Gem::Specification.new do |s|
  s.name = 'rack-active_record_status'
  s.version = '1.0.0'

  s.summary = "Rack middleware to check status of an app"
  s.description = "A server health check for active_record."

  s.authors  = ["Aaron Suggs"]
  s.email    = 'aaron@ktheory.com'
  s.homepage = 'https://github.com/mdsol/rack-active_record_status'

  s.rdoc_options = ["--charset=UTF-8"]
  s.extra_rdoc_files = %w[README.rdoc]

  s.add_dependency 'rack'
  s.add_dependency 'activerecord'
  s.add_dependency 'activesupport'

  s.add_development_dependency 'rake'
  s.add_development_dependency 'shoulda'
  s.add_development_dependency 'rack-test'

  s.files = `git ls-files`.split("\n")
  s.test_files = `git ls-files -- {spec,test}/*`.split("\n")
end
