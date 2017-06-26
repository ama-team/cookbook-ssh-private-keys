# frozen_string_literal: true

resource_name :key_from_attributes
default_action :create

property :source, String, name_property: true
property :expects_failure, [TrueClass, FalseClass], default: false

action :create do
  data = node['ama-ssh-private-keys'][source]
  expects_failure = new_resource.expects_failure
  ssh_private_key name do
    user 'root'
    self.class.properties.keys.each do |property|
      send(property, data[property]) if data.key?(property)
    end
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
