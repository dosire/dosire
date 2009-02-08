set :application, "dosire"

set :scm, "git"
set :scm_user, "dosire"
set :repository,  "git@github.com:dosire/dosire.git"
set :branch, "master"
set :git_enable_submodules, 1

set :user, "sytse"
# Set to false to prevent a password prompt on the cleanup task
set :use_sudo, false

# SSH options, 
ssh_options[:port] = 2525
ssh_options[:auth_methods] = %w(publickey hostbased) 
# Skip the known_hosts verification since known_keys is in a non-standard location
ssh_options[:paranoid] = false
# To troubleshoot a connection you could use: ssh_options[:verbose] = :debug

# Remote caching will keep a local git repo on the server you’re deploying to and simply run a fetch from that rather than an entire clone.
set :deploy_via, :remote_cache

# If you aren't deploying to /u/apps/#{application} on the target
# servers (which is the default), you can specify the actual location
set :deploy_to, "/home/#{user}/#{application}"

set :domain, "173.45.238.152"
role :app, "#{domain}"
role :web, "#{domain}"
role :db,  "#{domain}", :primary => true

#Custom restart task, using god monitoring software and
namespace :deploy do
  desc "Restart the web server and reload monitoring configuration"
  task :restart, :roles => :app do
    #Restart mongrel (stop, start)
    sudo "god restart mongrels"
    # Restart god
    sudo "/etc/init.d/god restart"
    # Cleanup all but the latest 5 releases
    cleanup 
  end
  
  #Copy in the database codes
  task :copy_database_configuration do
    production_db_config = "/home/#{user}/services/dosire_production_database.yml"
    run "cp #{production_db_config} #{release_path}/config/database.yml"
  end
  
  after "deploy:update_code", "deploy:copy_database_configurations"
end

