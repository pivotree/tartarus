class Tartarus::Railtie < Rails::Railtie
  generators = Proc.new do |g|
    g.orm             :activerecord, :migration => true
    g.template_engine :erb
    g.test_framework  :rspec
  end

  if ::Rails.version.to_f >= 3.1
    config.app_generators &generators
  else
    config.generators &generators
  end
end

