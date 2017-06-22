namespace :test do
  task :unit do
    sh 'bundle exec rspec --default-path test/suites/unit --require _config'
  end

  task :functional do
    sh 'bundle exec rspec --default-path test/suites/functional --require _config'
  end

  task :acceptance, [:platform] do |_, args|
    command = 'bundle exec kitchen test'
    platform = args[:platform]
    if platform
      puts "Using platform `#{platform}`"
      command += " #{platform}"
    else
      puts 'Testing all available variants'
    end
    command += ' --concurrency'
    sh command
  end

  task :report do
    sh 'allure generate -o test/report/allure test/metadata/allure'
  end

  task :all, [:platform] => %i[unit functional acceptance]
  task :'with-report', [:platform] => %i[unit functional acceptance report]
end

task :test, [:platform] => %i[test:all]

namespace :lint do
  task :foodcritic do
    sh 'bundle exec foodcritic .'
  end

  task :rubocop do
    sh 'bundle exec rubocop'
  end

  task all: %i[foodcritic rubocop]
end

task :lint => %i[lint:all]

task :default do
  sh 'bundle exec rake -AT'
end
