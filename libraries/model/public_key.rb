# rubocop:disable Style/Documentation

module AMA
  module Chef
    module SSHPrivateKeys
      module Model
        class PublicKey
          attr_accessor :type
          attr_accessor :data
          attr_accessor :comment
        end
      end
    end
  end
end
