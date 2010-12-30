class TartarusGenerator < Rails::Generators::NamedBase
  include Rails::Generators::Migration

  source_root File.expand_path('../templates', __FILE__)  
  argument :name, :type => 'string', :default => 'LoggedException'

  def generate_tartarus 
    template 'config/exceptions.yml', 'config/exceptions.yml'
    template 'app/controllers/exceptions_controller.rb', "app/controllers/exceptions_controller.rb"
    template 'app/models/logged_exception.rb', "app/models/#{file_name}.rb"
    template 'spec/models/logged_exception_spec.rb', "spec/models/#{file_name}_spec.rb"
    template 'spec/controllers/exceptions_controller_spec.rb', 'spec/controllers/exceptions_controller_spec.rb'

    migration_template "db/migrate/add_logged_exceptions.rb", "db/migrate/add_#{singular_name}_table"
    
    Dir.glob('views/exceptions/*.html.erb').each do |path| 
      view = File.basename(path)
      copy_file "app/views/exceptions/#{view}", "app/views/exceptions/#{view}"
    end

    copy_file 'public/javascripts/tartarus.jquery.js', 'public/javascripts/tartarus.jquery.js'
    copy_file 'public/stylesheets/tartarus.css', 'public/stylesheets/tartarus.css'
  end

  def after_generate
    puts "\nIn order for exceptional to function properly, you'll need to complete the following steps to complete the installation process: \n\n"
    puts "  1) Run 'rake db:migrate' to generate the logging table for your model.\n"
    puts "  2) Add '/javascripts/tartarus.jquery.js', and 'stylesheets/tartarus.css' to your applications layout.\n"
  end

  def self.next_migration_number(path)
    Time.now.utc.strftime("%Y%m%d%H%M%S")
  end

end
