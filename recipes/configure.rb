include_recipe "deploy::rails-restart"

node[:deploy].each do |application, deploy|
  deploy = node[:deploy][application]

  execute "restart Rails app #{application}" do
    cwd deploy[:current_path]
    command node[:opsworks][:rails_stack][:restart_command]
    action :nothing
  end

  template "#{deploy[:deploy_to]}/shared/config/secrets.yml" do
    source "secrets.yml.erb"
    mode 0660
    group deploy[:group]
    owner deploy[:user]
    cookbook "secrets_yml"
    variables(:environment_variables => deploy[:environment], :rails_env => deploy[:rails_env])

    notifies :run, "execute[restart Rails app #{application}]"
    
    only_if do
      File.directory?("#{deploy[:deploy_to]}/shared/config/")
    end
  end
end