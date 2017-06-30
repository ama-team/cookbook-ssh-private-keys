# frozen_string_literal: true

# rubocop:disable Style/Documentation

require_relative 'public_key'
require_relative 'private_key'

module AMA
  module Chef
    module SSHPrivateKeys
      module Model
        class KeyPair
          attr_accessor :type
          attr_accessor :public_key
          attr_accessor :private_key
          attr_accessor :passphrase
          attr_accessor :comment

          def compute_private_key
            klass = ::AMA::Chef::SSHPrivateKeys::Model::PrivateKey
            klass.new(private_key, passphrase)
          end

          def compute_public_key
            return nil unless public_key && type
            klass = ::AMA::Chef::SSHPrivateKeys::Model::PublicKey
            klass.new(type, public_key, comment)
          end
        end
      end
    end
  end
end
