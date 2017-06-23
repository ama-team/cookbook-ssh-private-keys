# frozen_string_literal: true

require 'chef/cookbook/metadata'

parent_cookbook_path = (0..3).reduce(__dir__) do |carrier|
  File.dirname(carrier)
end
parent_metadata_path = File.join(parent_cookbook_path, 'metadata.rb')
parent = Chef::Cookbook::Metadata.new
parent.from_file(parent_metadata_path)

name 'ama-ssh-private-keys-acceptance'
maintainer parent.maintainer
maintainer_email parent.maintainer_email
source_url parent.source_url
issues_url parent.issues_url
license parent.license
description 'Installs/Configures ama-ssh-private-keys-acceptance'
long_description 'Installs/Configures ama-ssh-private-keys-acceptance'
version parent.version

depends 'ama-ssh-private-keys', parent.version
