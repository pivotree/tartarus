class Tartarus::Railtie < Rails::Railtie
  config.after_initialize do
    ::ActionController::Base.send(:include, Tartarus::Rescue) if defined?(::ActionController::Base)
  end

  config.generators do |g|
    g.orm             :activerecord, :migration => true
    g.template_engine :erb
    g.test_framework  :rspec
  end

end

