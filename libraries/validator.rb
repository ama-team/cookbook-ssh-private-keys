# frozen_string_literal: true

require 'tempfile'
require 'English'

require_relative 'generator'
require_relative 'exception/invalid_key_exception'

module AMA
  module Chef
    module SSHPrivateKeys
      # Simple utility for validating provided key pair
      class Validator
        # @param [AMA::Chef::SSHPrivateKeys::Model::KeyPair] key_pair
        def validate!(key_pair)
          generated_public_key = generator.generate_public_key(
            key_pair.compute_private_key,
            key_pair.comment
          )
          if key_pair.type && key_pair.type != generated_public_key.type
            message = "Key was provided with type #{key_pair.type}, but " \
              "#{generated_public_key.type} was discovered"
            raise_invalid_key_exception(message)
          end
          public_key = key_pair.public_key
          return unless public_key && public_key != generated_public_key.content
          message = 'Generated public key differs from provided public key'
          raise_invalid_key_exception(message)
        end

        private

        def generator
          return @generator if @generator
          @generator = Generator.new(Generator.locate_binary!)
        end

        # @param [String] message
        def raise_invalid_key_exception(message)
          klass = ::AMA::Chef::SSHPrivateKeys::Exception::InvalidKeyException
          raise klass, message
        end
      end
    end
  end
end
