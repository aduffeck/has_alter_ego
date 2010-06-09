spec = Gem::Specification.new do |s|
  s.name              = "schizophrenia"
  s.version           = "0.0.1"
  s.authors           = ["André Duffeck"]
  s.email             = ["aduffeck@suse.de"]
  s.homepage          = "http://github.com/aduffeck/schizophrenia"
  s.summary           = "A Rails plugin which makes it possible to keep seed and live data in parallel"
  s.description       = <<-EOM
    schizophrenia makes it possible to keep seed and live data transparently in parallel. In contrast to other seed
    data approaches schizophrenia synchronizes the seed definitions with your database objects automagically unless you've
    overridden it in the database.
  EOM

  s.has_rdoc         = false
  s.test_files       = Dir.glob "test/**/*_test.rb"
  s.files            = Dir["lib/**/*.rb", "lib/**/*.rake", "*.md", "LICENSE",
    "Rakefile", "rails/init.rb", "generators/**/*.*", "test/**/*.*"]
end