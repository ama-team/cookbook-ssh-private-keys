# frozen_string_literal: true

name 'ama-ssh-private-keys'
maintainer 'AMA Team'
maintainer_email 'ops@amagroup.ru'
source_url 'https://github.com/ama-team/cookbook-ssh-private-keys'
issues_url 'https://github.com/ama-team/cookbook-ssh-private-keys/issues'
license 'MIT'
description 'Manages SSH private keys'
long_description 'Manages SSH private keys'
version '0.2.2'
chef_version '>= 12', '< 14'

supports 'ubuntu', '>= 12.04'
supports 'debian', '>= 7.3'
supports 'fedora', '>= 24.0'
supports 'centos', '>= 6.0'
