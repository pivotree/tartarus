class TartarusGenerator < Rails::Generators::NamedBase
  include Rails::Generators::Migration

  source_root File.expand_path('../templates', __FILE__)  
  argument :name, :type => 'string', :default => 'LoggedException'

  def generate_tartarus 
    template 'config/exceptions.yml', 'config/exceptions.yml'
    template 'app/models/logged_exception.rb', "app/models/#{file_name}.rb"
    template 'spec/models/logged_exception_spec.rb', "spec/models/#{file_name}_spec.rb"
   
    template 'app/controllers/exceptions_controller.rb', "app/controllers/#{plural_name}_controller.rb"
    template 'spec/controllers/exceptions_controller_spec.rb', "spec/controllers/#{plural_name}_controller_spec.rb"

    copy_file 'app/views/exceptions/index.html.erb', "app/views/#{plural_name}/index.html.erb"
    copy_file 'app/views/exceptions/details.html.erb', "app/views/#{plural_name}/details.html.erb"
    copy_file 'app/views/exceptions/_exception.html.erb', "app/views/#{plural_name}/_exception.html.erb"
    
    copy_file 'public/javascripts/tartarus.jquery.js', 'public/javascripts/tartarus.jquery.js'
    copy_file 'public/stylesheets/tartarus.css', 'public/stylesheets/tartarus.css'

    migration_template "db/migrate/add_logged_exceptions.rb", "db/migrate/add_#{singular_name}_table"
  end

  def after_generate
    puts "\nIn order for exceptional to function properly, you'll need to complete the following steps to complete the installation process: \n\n"
    puts "  1) Run 'rake db:migrate' to generate the logging table for your model.\n"
    puts "  2) Add \"config.middleware.use 'Tartarus::Rack'\" to the enviroments that you'd like logging."
    puts "  3) Add '/javascripts/tartarus.jquery.js', and 'stylesheets/tartarus.css' to your applications layout.\n"
  end

  def self.next_migration_number(path)
    Time.now.utc.strftime("%Y%m%d%H%M%S")
  end

end
