# frozen_string_literal: true

# rubocop:disable Metrics/LineLength
# rubocop:disable Metrics/BlockLength
# rubocop:disable Style/HashSyntax
# rubocop:disable Lint/UselessAssignment

require 'nokogiri'
require 'pathname'

project_root = __dir__
metadata_location = ::File.join(project_root, 'test', 'metadata')
report_location = ::File.join(project_root, 'test', 'report')
suites_location = ::File.join(project_root, 'test', 'suites')

namespace :test do
  %i[unit functional].each do |type|
    task type do
      sh "bundle exec rspec --default-path test/suites/#{type} --require _config --pattern **/*.spec.rb"
    end
    namespace type do
      task :'with-report' do |task|
        clean_task = Rake::Task[:'test:clean']
        clean_task.invoke(task)
        clean_task.reenable
        begin
          target_task = Rake::Task[:"test:#{type}"]
          target_task.invoke(task)
        ensure
          target_task.reenable
          report_task = Rake::Task[:'test:report']
          report_task.invoke(task)
          report_task.reenable
        end
      end
    end
  end

  task :acceptance, [:platform] do |_, args|
    begin
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
    ensure
      Rake::Task[:'test:acceptance:allurize'].invoke
    end
  end

  namespace :acceptance do
    task :allurize do
      pattern = ::File.join(metadata_location, 'junit', '**', '*.xml')
      ::Dir.glob(pattern).each do |raw_path|
        path = ::Pathname.new(raw_path)
        name = path.basename('.xml').to_s.sub(/^TEST-/, '')
        suite, platform = name.split('-on-', 2).map do |chunk|
          chunk.tr('-', ' ').capitalize
        end
        document = ::Nokogiri::XML(File.read(path.to_s))
        document.root = document.at_xpath('//testsuite')
        document.xpath('//testcase').each do |element|
          next if element['classname']
          element['classname'] = "Acceptance :: #{platform} :: #{suite}"
        end
        target = path.dirname.join("TEST-#{name}.xml")
        ::IO.write(target.to_s, document.to_xml)
      end
    end
  end

  task :clean do
    %w[metadata report].each do |folder|
      FileUtils.rm_rf(::File.join(__dir__, 'test', folder))
    end
  end

  task :report do
    sh 'allure generate --clean -o test/report/allure test/metadata/allure/** test/metadata/junit/**'
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

  namespace :rubocop do
    task :html do
      sh 'bundle exec rubocop -f html -o test/report/rubocop/rubocop.html'
    end
  end

  task all: %i[foodcritic rubocop]
  task html: %i[foodcritic rubocop:html]
end

task :lint => %i[lint:all]

task :verify, [:pattern] => %i[lint test]

task :default do
  sh 'bundle exec rake -AT'
end
