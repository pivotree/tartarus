class Tartarus::Railtie < Rails::Railtie
  config.app_generators do |g|
    g.orm             :activerecord, :migration => true
    g.template_engine :erb
    g.test_framework  :rspec
  end

end

