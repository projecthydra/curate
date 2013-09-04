require 'rspec/core'
require 'rspec/core/rake_task'
DUMMY_APP = 'spec/internal'
APP_ROOT = '.'
require 'jettywrapper'
JETTY_ZIP_BASENAME = 'master'
Jettywrapper.url = "https://github.com/projecthydra/hydra-jetty/archive/#{JETTY_ZIP_BASENAME}.zip"

def system_with_command_output(command)
  puts("\n$\t#{command}")
  system(command)
end

def within_test_app
  FileUtils.cd(DUMMY_APP)
  yield
  FileUtils.cd('../..')
end

desc "Clean out the test rails app"
task :clean do
  puts "Removing sample rails app"
  `rm -rf #{DUMMY_APP}`
end


desc "Create the test rails app"
task :generate do
  unless File.exists?(DUMMY_APP + '/Rakefile')
    puts "Generating rails app"
    system_with_command_output 'rails new ' + DUMMY_APP
    puts "Updating gemfile"

    `echo "gem 'curate', :path=>'../../../curate'
gem 'capybara'
gem 'selenium-webdriver'
gem 'factory_girl_rails'
gem 'timecop'
gem 'rspec-html-matchers'
gem 'test_after_commit', :group => :test
gem 'kaminari', github: 'harai/kaminari', branch: 'route_prefix_prototype'" >> #{DUMMY_APP}/Gemfile`

    puts "Copying generator"
    `cp -r spec/skeleton/* #{DUMMY_APP}`
    Bundler.with_clean_env do
      within_test_app do
        puts "Bundle install"
        `bundle install`
        puts "running test_app_generator"
        system "rails generate test_app"

        # These factories are autogenerated and conflict with our factories
        system 'rm test/factories/users.rb'
        puts "running migrations"
        puts `rake db:migrate db:test:prepare`
      end
    end
  end
  puts "Done generating test app"
end

task :spec => :generate do
  Bundler.with_clean_env do
    within_test_app do
      Rake::Task['rspec'].invoke
    end
  end
end

desc "Run specs"
RSpec::Core::RakeTask.new(:rspec) do |t|
  t.pattern = '../**/*_spec.rb'
  t.rspec_opts = ["--colour -I ../", '--tag ~js:true']
end


desc 'Run specs on travis'
task :ci => [:clean, :generate] do
  ENV['RAILS_ENV'] = 'test'
  ENV['TRAVIS'] = '1'
  Jettywrapper.unzip
  jetty_params = Jettywrapper.load_config
  error = Jettywrapper.wrap(jetty_params) do
    Rake::Task['spec'].invoke
  end
  raise "test failures: #{error}" if error
end
