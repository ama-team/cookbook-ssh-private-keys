# Cookbook ama-ssh-private-keys

[![Travis branch](https://img.shields.io/travis/ama-team/cookbook-ssh-private-keys/master.svg?style=flat-square)](https://travis-ci.org/ama-team/cookbook-ssh-private-keys)
[![Chef cookbook](https://img.shields.io/cookbook/v/ama-ssh-private-keys.svg?style=flat-square)](https://supermarket.chef.io/cookbooks/ama-ssh-private-keys)

This cookbook allows end user to install private keys for specified 
accounts.

Cookbook provides self-explanatory `ssh_private_key` resource:
 
```ruby
ssh_private_key 'id_rsa' do
  user 'jodie'
  private_key '-----BEGIN PRIVATE KEY-----...'
  public_key 'AAAAB3NzaC1kc...'
  passphrase 'i beg you pardon?'
end
```

This will create `id_rsa` and `id_rsa.pub` in jodie's `~/.ssh` folder. If 
jodie account doesn't exist yet, `/home/jodie/.ssh` will be used (or
path specified in the resource - see below). If you are a super lazy
person, there's `default` recipe that will take data bag with name
specified in `['ama']['ssh-private-keys']['data-bag']` attribute
('ssh-private-keys' by default) and iterate it's contents, creating a
new resource for each item.

By default, keys and passphrase are validated with ssh-keygen that 
confirms that all components are what they are and match each other.
This may be turned off as well, if desired.

Cookbook is tested against Debian 7.3+, Ubuntu 14.04+, Centos 6.0+ 
and Fedora 24+, but generally it should work everywhere.

## Full resource specification

```ruby
ssh_private_key 'hackerman:default' do
  id 'id_rsa' # name_property
  type 'ssh-rsa' # ssh-(rsa|dss|ed25519), ecdsa-sha2-nistp(256|384|521)
  user 'hackerman' # required
  private_key '' # required
  public_key ''
  passphrase 'choose life'
  parent_directory '/workspace'
  private_key_mode '0600'
  public_key_mode '0644'
  public_key_suffix '.pub'
  comment 'hack-the-time'
  perform_validation true
  action :create # :create/
end
```

# Licensing

MIT License / AMA Team
