module AMA
  module Chef
    module SSHPrivateKeys
      module Model
        class KeyPair
          attr_accessor :id
          attr_accessor :type
          attr_accessor :private_key
          attr_accessor :public_key
          attr_accessor :passphrase
          attr_accessor :comment

          def normalize
            _ = instance_variables.map do |name|
              [name[1..-1], instance_variable_get(name)]
            end
            Hash[_]
          end

          def to_s
            "KeyPair ###{id}:#{type}"
          end
        end
      end
    end
  end
end
