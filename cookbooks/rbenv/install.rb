include_receipe './dependency.rb'

rbenv_user = node[:rbenv][:rbenv_user]
if rbenv_user == 'root'
  rbenv_path = '/rbenv_user/local/rbenv'
  profile_path= '/etc/profile.d/rbenv.sh'
else
  rbenv_path = "/home/#{rbenv_user}/.rbenv"
  profile_path = "/home/#{rbenv_user}/.bashrc"
end

git rbenv_path do
  repository 'git://github.com/rbenv/rbenv.git'
  user rbenv_user
  not_if "test -e #{rbenv_path}"
end

git "#{rbenv_path}/plugins" do
  repository 'git@github.com:rbenv/ruby-build.git'
  user rbenv_user
  not_if "test -e #{rbenv_path}/plugins/ruby-build"
end

execute "add settings to #{rbenv_profile}" do
  settings = <<-EOS
export PATH="#{rbenv_path}/bin:$PATH"
eval "$(rbenv init -)"
  EOS
  command "echo '#{settings}' >> #{profile_path}"
  user rbenv_user
  not_if "test `cat #{profile_path} | grep 'rbenv' -c` != 0"
end

execute "initialize rbenv" do
  command "source #{profile_path}"
  user rbenv_user
end

version = node[:rbenv][:version]
execute "rbenv install #{version}" do
  command "rbenv install #{version}"
  not_if "rbenv versions | grep #{version}"
end

execute "rbenv global #{version}" do
  command "rbenv global #{version}"
  not_if "rbenv version | grep #{version}"
end
