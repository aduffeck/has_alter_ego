spec = Gem::Specification.new do |s|
  s.name              = "has_alter_ego"
  s.version           = "0.0.2"
  s.authors           = ["André Duffeck"]
  s.email             = ["aduffeck@suse.de"]
  s.homepage          = "http://github.com/aduffeck/has_alter_ego"
  s.summary           = "A Rails plugin which makes it possible to keep seed and live data in parallel"
  s.description       = <<-EOM
    has_alter_ego makes it possible to keep seed and live data transparently in parallel. In contrast to other seed
    data approaches has_alter_ego synchronizes the seed definitions with your database objects automagically unless you've
    overridden it in the database.
  EOM

  s.has_rdoc         = false
  s.test_files       = Dir.glob "test/**/*_test.rb"
  s.files            = Dir["lib/**/*.rb", "lib/**/*.rake", "*.md", "LICENSE",
    "Rakefile", "rails/init.rb", "generators/**/*.*", "test/**/*.*"]
end
