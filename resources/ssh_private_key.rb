resource_name :ssh_private_key
default_action :create

types = %w[
  ssh-rsa
  ssh-dss
  ssh-ed25519
  ecdsa-sha2-nistp256
  ecdsa-sha2-nistp384
  ecdsa-sha2-nistp521
].reduce([]) do |carrier, item|
  carrier.push(item, item.to_sym)
end

property :id, String, name_property: true
property :user, String, required: true
property :type, String, equal_to: types, default: 'ssh-rsa'
property :private_key, String, required: true, sensitive: true
property :public_key, [String, NilClass], default: nil, sensitive: true
property :passphrase, String, required: false, sensitive: true
property :parent_directory, String, required: false
property :private_key_mode, String, default: '0600'
property :public_key_mode, String, default: '0644'
property :public_key_suffix, String, default: '.pub'
property :comment, String, required: false
property :perform_validation, [TrueClass, FalseClass], default: true

action_class do
  include AMA::Chef::SSHPrivateKeys::ResourceHelpers

  def delete
    data = new_resource
    directory = key_directory
    private_key_path = "#{directory}/#{data.id}"
    public_key_path = "#{private_key_path}#{data.public_key_suffix}"
    file private_key_path do
      action :delete
    end
    file public_key_path do
      action :delete
    end
  end
end

action :create do
  data = new_resource
  directory = key_directory
  private_key_path = "#{directory}/#{data.id}"
  public_key_path = "#{private_key_path}#{data.public_key_suffix}"

  create_key_directory(directory)

  validate_key_pair!(compute_pair) if data.perform_validation
  file private_key_path do
    content data.private_key
    owner data.user
    mode data.private_key_mode
    sensitive true
  end

  file public_key_path do
    content data.public_key if data.public_key
    owner data.user
    mode data.public_key_mode
    sensitive true
    action(data.public_key ? :create : :delete)
  end
end

action :remove do
  delete
end

action :delete do
  delete
end
