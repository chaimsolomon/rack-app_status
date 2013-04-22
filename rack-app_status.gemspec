Gem::Specification.new do |s|
  s.name = 'rack-app_status'
  s.version = '0.1.1'

  s.summary = "Rack middleware to check status of an app"
  s.description = "A server health check for active_record."

  s.authors  = ["Chaim Solomon", "Aaron Suggs"]
  s.email    = 'csolomon@mdsol.com'
  s.homepage = 'https://github.com/mdsol/rack-app_status'

  s.rdoc_options = ["--charset=UTF-8"]
  s.extra_rdoc_files = %w[README.rdoc]

  s.add_dependency 'rack'
  s.add_dependency 'activesupport'

  s.add_development_dependency 'rake'
  s.add_development_dependency 'shoulda'
  s.add_development_dependency 'rack-test'
  s.add_development_dependency 'activerecord', '~> 3.2.0'
  s.add_development_dependency  'cequel', '~> 0.5.3'

  s.files = `git ls-files`.split("\n")
  s.test_files = `git ls-files -- {spec,test}/*`.split("\n")
end
