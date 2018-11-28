task :start do
  on roles(:app) do
    # The server needs to be set up such that the deployment user can execute
    # the following sudo command without a password.
    execute "sudo systemctl start #{fetch :application}"
  end
end
namespace :deploy do
  after :published, :start
end
