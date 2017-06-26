# frozen_string_literal: true

# rubocop:disable Style/Documentation

module AMA
  module Chef
    module SSHPrivateKeys
      module Model
        class PrivateKey
          attr_accessor :content
          attr_accessor :passphrase

          def initialize(content = nil, passphrase = nil)
            @content = content
            @passphrase = passphrase
          end

          def to_s
            @content
          end
        end
      end
    end
  end
end
