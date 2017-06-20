resource_name :key_from_attributes
default_action :create

property :source, String, name_property: true
property :expects_failure, [TrueClass, FalseClass], default: false
property :perform_validation, [TrueClass, FalseClass, NilClass], default: nil

action :create do
  data = node['ama-ssh-private-keys'][source]
  expects_failure = new_resource.expects_failure
  perform_validation = new_resource.perform_validation
  perform_validation = data['perform_validation'] if perform_validation.nil?
  ssh_private_key name do
    user 'root'
    %w[private_key].each do |attribute|
      send(attribute, data[attribute])
    end
    %w[
      type public_key parent_directory private_key_mode public_key_mode
      public_key_suffix comment passphrase
    ].each do |attribute|
      send(attribute, data[attribute]) if data.key?(attribute)
    end
    perform_validation perform_validation unless perform_validation.nil?
    if expects_failure
      assertion_error name do
        message "Key `#{name}` should had not been installed"
        action :nothing
      end
      ignore_failure true
      notifies :raise, "assertion_error[#{name}]", :immediately
    end
  end
end
