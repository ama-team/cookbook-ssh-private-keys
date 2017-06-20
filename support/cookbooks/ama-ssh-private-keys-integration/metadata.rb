require 'chef/cookbook/metadata'

parent_cookbook_path = (0..2).reduce(__dir__) do |carrier|
  File.dirname(carrier)
end
parent_metadata_path = File.join(parent_cookbook_path, 'metadata.rb')
parent_metadata = Chef::Cookbook::Metadata.new
parent_metadata.from_file(parent_metadata_path)

name 'ama-ssh-private-keys-integration'
maintainer 'AMA Team'
maintainer_email 'ops@amagroup.ru'
license 'mit'
description 'Installs/Configures ama-ssh-private-keys-integration'
long_description 'Installs/Configures ama-ssh-private-keys-integration'
version parent_metadata.version

depends 'ama-ssh-private-keys', parent_metadata.version
