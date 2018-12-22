# frozen_string_literal: true

namespace :test do
  Rake::TaskManager.record_task_metadata = true

  desc 'Runs the test suite'
  task :suite do |task|
    puts "########### #{task.full_comment} ###########"
    sh 'bundle exec rake test', verbose: false
  end

  desc 'Runs the system tests'
  task :selenium do |_task|
    sh 'bundle exec rake test:system'
  end

  desc 'Runs all tests'
  task all: %w[suite selenium]
end
