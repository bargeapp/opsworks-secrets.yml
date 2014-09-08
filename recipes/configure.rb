node[:deploy].each do |application, deploy|
  deploy = node[:deploy][application]

  template "#{deploy[:deploy_to]}/shared/config/secrets.yml" do
    source "secrets.yml.erb"
    mode 0660
    group deploy[:group]
    owner deploy[:user]
    
    variables(:environment_variables => deploy[:environment], :rails_env => deploy[:rails_env])

    notifies :run, "execute[restart Rails app #{application}]"

    only_if do
      File.directory?("#{deploy[:deploy_to]}/shared/config/")
    end
  end
end