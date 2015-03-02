require 'capistrano_colors'
require 'bundler/deployment'
require 'capistrano/ext/multistage'
require "config/whenever_capistrano"

set :whenever_command, "bundle exec whenever"

set :stages, %w(preproduction production)
set :default_stage, "preproduction"

set :application, "intranet"
set :repository,  "http://amazon:B0n1t0@repos.mvconsultoria.com/hg/Intranet"

set :keep_releases, 5

set :scm, :mercurial

# Or: `accurev`, `bzr`, `cvs`, `darcs`, `git`, `mercurial`, `perforce`, `subversion` or `none`

namespace :passenger do
  desc "Restart Application"
  task :restart do
    run "touch #{current_path}/tmp/restart.txt"
  end
end

namespace :ts do
  desc "Thinking Sphinx"
  task :rebuild do
    run "cd #{release_path} && rake ts:stop"
    run "cd #{release_path} && rake ts:config RAILS_ENV=#{stage}"
    run "cd #{release_path} && rake ts:rebuild RAILS_ENV=#{stage}"
  end
end

namespace :bundler do
  task :create_symlink, :roles => :app do
    shared_dir = File.join(shared_path, 'bundle')
    release_dir = File.join(current_release, '.bundle')
    run("mkdir -p #{shared_dir} && ln -s #{shared_dir} #{release_dir}")
  end

  task :bundle_new_release, :roles => :app do
    bundler.create_symlink
    run "cd #{release_path} && bundle install --deployment --without test development"
  end
end

namespace :db do
  task :migrate do
    run "cd #{release_path} && rake db:migrate RAILS_ENV=#{stage}"
  end
end

after 'deploy:finalize_update', 'bundler:bundle_new_release'
after 'deploy:update', 'db:migrate'
after 'deploy:update', "passenger:restart"
# Disable cron jobs at the begining of a deploy.
after "bundler:bundle_new_release", "whenever:clear_crontab"
# Stop daemon, rebuild thinking sphinx files and start daemon
after "db:migrate", "ts:rebuild"
# Write the new cron jobs near the end.
after "deploy:symlink", "whenever:update_crontab"
# If anything goes wrong, undo.
after "deploy:rollback", "whenever:update_crontab"
