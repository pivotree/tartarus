class Tartarus::Railtie < Rails::Railtie
  config.after_initialize do
    ::ActionController::Base.send(:include, Tartarus::Rescue) if defined?(::ActionController::Base)
  end

end

