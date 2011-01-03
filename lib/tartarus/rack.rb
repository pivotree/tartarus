class Tartarus::Rack
  def initialize(app, configuration = {})
    @app = app 
    @configuration = configuration
  end

  def call(env)
    begin
      response = @app.call(env)
    rescue Exception => exception
      Tartarus.log(env, exception)
      raise
    end

    if env['rack.exception']
      Tartarus.log(env, exception) 
    end

    response
  end

end

