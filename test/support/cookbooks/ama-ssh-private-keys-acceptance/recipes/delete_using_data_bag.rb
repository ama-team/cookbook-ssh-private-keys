# frozen_string_literal: true

data_bag_name = node['ama']['ssh-private-keys']['data-bag']
data_bag(data_bag_name).each do |id|
  data = data_bag_item(data_bag_name, id)
  ssh_private_key id do
    self.class.properties.keys.each do |property_name|
      [property_name.to_s, property_name.to_sym].each do |candidate|
        send(candidate, data[candidate]) if data.key?(candidate)
      end
    end
    action :delete
  end
end
