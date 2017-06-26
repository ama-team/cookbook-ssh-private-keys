# frozen_string_literal: true

# rubocop:disable Style/Documentation

module AMA
  module Chef
    module SSHPrivateKeys
      module Model
        class PublicKey
          attr_accessor :type
          attr_accessor :content
          attr_accessor :comment

          def initialize(type = nil, content = nil, comment = nil)
            @type = type
            @content = content
            @comment = comment
          end

          def to_s
            builder = "#{type} #{content}"
            builder += " #{comment}" if comment
            builder
          end
        end
      end
    end
  end
end
