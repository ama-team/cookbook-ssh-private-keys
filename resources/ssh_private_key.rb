# frozen_string_literal: true

# rubocop:disable Metrics/BlockLength
# rubocop:disable Metrics/AbcSize

require_relative '../libraries/resource_helpers'
require_relative '../libraries/validator'

resource_name :ssh_private_key
default_action :create

property :id, String, name_property: true
property :user, [String, Symbol], required: true
property :content, String, required: false, sensitive: true

ssh_types = %w[rsa dsa dss].map { |type| "ssh-#{type}" }
ecdsa_types = %w[256 384 521].map { |length| "ecdsa-sha2-nistp#{length}" }
types = [*ssh_types, *ecdsa_types].reduce([]) do |carrier, type|
  carrier.push(type, type.to_sym)
end
variants = [*types, nil]
property :type, [String, Symbol, NilClass], equal_to: variants, required: false

property :mode, String, default: '0600'
property :parent_directory, [String, NilClass], required: false

property :passphrase, [String, NilClass], required: false, sensitive: true
property :comment, [String, NilClass], required: false

property :install_public_key, [TrueClass, FalseClass], default: false
property :public_key_suffix, String, default: '.pub'
property :public_key_mode, String, default: '0644'
property :public_key, [String, NilClass], required: false

property :perform_validation, [TrueClass, FalseClass], default: false

action_class do
  include AMA::Chef::SSHPrivateKeys::ResourceHelpers

  def create
    data = new_resource
    unless data.content
      raise ::Chef::Exceptions::ValidationFailed, 'content is required'
    end
    key_pair = provided_key_pair

    if data.perform_validation
      ::AMA::Chef::SSHPrivateKeys::Validator.new.validate!(key_pair)
    end

    create_key_directory

    file private_key_path do
      content data.content
      owner data.user
      mode data.mode
      sensitive true
    end

    return unless data.install_public_key

    content = (key_pair.compute_public_key || generated_public_key!).to_s
    file public_key_path do
      content content
      owner data.user
      mode data.public_key_mode
      sensitive true
      action :create
    end
  end

  def delete
    file private_key_path do
      action :delete
    end
    file public_key_path do
      action :delete
    end
  end
end

action :create do
  create
end

action :install do
  create
end

action :delete do
  delete
end

action :remove do
  delete
end
