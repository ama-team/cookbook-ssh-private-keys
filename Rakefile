# frozen_string_literal: true

# rubocop:disable Metrics/LineLength
# rubocop:disable Metrics/BlockLength
# rubocop:disable Style/HashSyntax

namespace :test do
  %i[unit functional].each do |type|
    task type do
      sh "bundle exec rspec --default-path test/suites/#{type} --require _config --pattern **/*.spec.rb"
    end
    namespace type do
      task :report do
        sh "allure generate -o test/report/allure/#{type} test/metadata/allure/#{type}"
      end
      task :clean do
        %w[metadata report].each do |folder|
          FileUtils.rm_rf(::File.join(__dir__, 'test', folder, type.to_s))
        end
      end
      task :'with-report' do |task|
        clean_task = Rake::Task[:"test:#{type}:clean"]
        clean_task.invoke(task)
        clean_task.reenable
        begin
          target_task = Rake::Task[:"test:#{type}"]
          target_task.invoke(task)
        ensure
          target_task.reenable
          report_task = Rake::Task[:"test:#{type}:report"]
          report_task.invoke(task)
          report_task.reenable
        end
      end
    end
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
    sh 'allure generate -o test/report/allure/combined test/metadata/allure'
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

task :verify, [:pattern] => %i[lint test]

task :default do
  sh 'bundle exec rake -AT'
end
