resource_name :ssh_private_key
default_action :create

property :id, String, name_property: true
property :user, String, required: true
property :type, String, default: 'ssh-rsa'
property :private_key, String, required: true
property :public_key, [String, NilClass], default: nil
property :parent_directory, String, required: false
property :private_key_mode, String, default: '0600'
property :public_key_mode, String, default: '0644'
property :public_key_suffix, String, default: '.pub'
property :comment, String, required: false
property :passphrase, String, required: false
property :verify, [TrueClass, FalseClass], default: true

action_class do
  include AMA::Chef::SSHPrivateKeys::ResourceHelpers

  def delete
    directory = get_key_directory
    file "#{directory}/#{new_resource.id}" do
      action :delete
    end
    file "#{directory}/#{new_resource.id}#{new_resource.public_key_suffix}" do
      action :delete
    end
  end
end

action :create do
  user = new_resource.user
  directory = get_key_directory
  pair = compute_pair
  new_resource = new_resource
  begin
    resources(directory: directory)
  rescue Chef::Exceptions::ResourceNotFound
    self.directory directory do
      owner user
      mode '0700'
      recursive true
    end
  end
  validate! if new_resource.verify
  file "#{directory}/#{new_resource.id}" do
    content pair.private_key
    owner new_resource.user
    mode new_resource.private_key_mode
  end
  if pair.public_key
    file "#{directory}/#{new_resource.id}#{new_resource.public_key_suffix}" do
      content pair.private_key
      owner new_resource.user
      mode new_resource.private_key_mode
    end
  end
end

action :remove do
  delete
end

action :delete do
  delete
end
