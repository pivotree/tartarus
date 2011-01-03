class Tartarus::Railtie < Rails::Railtie
  config.generators do |g|
    g.orm             :activerecord, :migration => true
    g.template_engine :erb
    g.test_framework  :rspec
  end

end

