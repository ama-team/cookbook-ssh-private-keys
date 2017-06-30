# Cookbook ama-ssh-private-keys

[![Supermarket](https://img.shields.io/cookbook/v/ama-ssh-private-keys.svg?style=flat-square)](https://supermarket.chef.io/cookbooks/ama-ssh-private-keys)
[![CircleCI / master](https://img.shields.io/circleci/project/github/ama-team/cookbook-ssh-private-keys/master.svg?style=flat-square)](https://circleci.com/gh/ama-team/cookbook-ssh-private-keys/tree/master)
[![Scrutinizer](https://img.shields.io/scrutinizer/g/ama-team/cookbook-ssh-private-keys.svg?style=flat-square)](https://scrutinizer-ci.com/g/ama-team/cookbook-ssh-private-keys/)

This cookbook allows end user to install private keys for specified 
accounts.

Cookbook provides self-explanatory `ssh_private_key` resource:
 
```ruby
ssh_private_key 'id_rsa' do
  user 'jodie'
  content '-----BEGIN PRIVATE KEY-----...'
end
```

This will save provided key as `{jodie's home}/.ssh/id_rsa` with mode 
`0600`.

Cookbook also exposes `default` recipe that will take all items from
data bag with name specified as `[ama][ssh-private-keys][data-bag]`
attribute (`ssh-private-keys` by default) and simply pass them to 
resource.

If you want to use automatic public key generation and/or validation,
additional information is specified below.

**Eye-catching warning: if you are using this cookbook, you're
quite certainly working with keys providing some sensitive access. 
Ensure and double check that you minimize risk of exposure of your 
keys as much as possible. This cookbook, on it's behalf, tries to do
the same.**

## Requirements

- Chef 12+
- Ruby 2.3.0+
- Installed and available on $PATH ssh-keygen binary for validation
and public key generation (disabled by default)

## Tested against

- Debian 7.3+
- Ubuntu 14.04+
- Centos 6.0+
- Fedora 24+

Generally internals are very simple, so it should run anywhere.

## Full resource specification

```ruby
ssh_private_key 'hackerman:default' do
  id 'id_rsa' # name_property
  user 'hackerman' # required
  type 'ssh-rsa' # ssh-(rsa|dss|ed25519), ecdsa-sha2-nistp(256|384|521)
  content '' # required
  
  parent_directory '/workspace'
  mode '0600'
  
  # optional, required for validation / public key creation
  passphrase '2018' 
  
  # optional, required for public key creation
  comment 'hack-the-time'
  
  install_public_key true # defaults to false
  public_key_mode '0644'
  public_key_suffix '.pub'
  # if not specified, public key will be derived from private key
  # using ssh-keygen
  public_key ''
  
  perform_validation true # defaults to false
  
  action :create # :create/install, :delete/remove
end
```

If `install_public_key` is set to true, resource will create public key
file next to private key file. If public key is not supplied, it will 
be derived from private key (passphrase may be needed to do so).

If `perform_validation` is set to true, internal validator will make
following assertions before any file will be installed:

- Public key may be derived from supported private key
- If public key is provided, it matches generated public key
- If key type is provided, it matches type recovered by ssh-keygen

All not-safe-for-exposure resource properties are declared as sensitive
and won't appear in logs. Private keys are written to temporary files 
(mode 0600) for validation / public key derivation which are erased
using `ensure` blocks - only newer ssh-keygen versions accept stdin 
for reading.

# Licensing

MIT License / AMA Team
