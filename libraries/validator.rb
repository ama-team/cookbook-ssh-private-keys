# frozen_string_literal: true

require 'tempfile'
require 'English'

require_relative 'ssh_keygen_handler'
require_relative 'exception/invalid_key_exception'

module AMA
  module Chef
    module SSHPrivateKeys
      # Validates provided key pair using ssh-keygen
      class Validator
        def initialize
          @handler = nil
        end

        # @param [AMA::Chef::SSHPrivateKeys::Model::KeyPair] pair
        def validate!(pair)
          unless pair.private_key
            message = "Provided key pair #{pair.id} is missing private key"
            raise_invalid_key_exception(message)
          end
          public_key = handler.generate_public_key(pair)
          unless pair.type == public_key.type
            message = "Key pair specified type #{pair.type}, but " \
              "#{public_key.type} was discovered"
            raise_invalid_key_exception(message)
          end
          return unless pair.public_key && pair.public_key != public_key.data
          message = [
            'Generated public key differs from ' \
              "provided public key `#{pair.id}`",
            "Provided: #{pair.public_key}",
            "Generated: #{public_key.data}"
          ]
          raise_invalid_key_exception(message.join(" #{$ORS}"))
        end

        private

        def handler
          return @handler if @handler
          binary = SSHKeygenHandler.locate_binary!
          @handler = SSHKeygenHandler.new(binary)
        end

        # @param [String] message
        def raise_invalid_key_exception(message)
          klass = AMA::Chef::SSHPrivateKeys::Exception::InvalidKeyException
          raise klass, message
        end
      end
    end
  end
end
