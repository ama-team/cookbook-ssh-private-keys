module AMA
  module Chef
    module SSHPrivateKeys
      # Just a buinch of methods to put dirty work out of resource definition
      module ResourceHelpers
        def guess_user_home_directory(user)
          "/home/#{user}"
        end

        def get_user_home_directory(user)
          Etc.getpwnam(user).dir
        rescue ArgumentError
          directory = guess_user_home_directory(user)
          Chef::Log.warn(
            "User #{user} hasn't been found at compile time, " \
            "using #{directory} as user home directory"
          )
          directory
        end

        def get_user_ssh_directory(user)
          "#{get_user_home_directory(user)}/.ssh"
        end

        def validate_key_pair!(pair)
          Validator.new.validate!(pair)
        end

        def key_directory
          return new_resource.parent_directory if new_resource.parent_directory
          get_user_ssh_directory(new_resource.user)
        end

        def compute_pair
          raw = new_resource
          AMA::Chef::SSHPrivateKeys::Model::KeyPair.new.tap do |instance|
            instance.id = raw.id
            instance.type = raw.type
            instance.public_key = raw.public_key
            instance.private_key = raw.private_key
            instance.passphrase = raw.passphrase
            instance.comment = raw.comment
          end
        end

        # rubocop:d
        def create_key_directory(directory = nil)
          directory = key_directory unless directory
          user = new_resource.user
          begin
            resources(directory: directory)
          rescue ::Chef::Exceptions::ResourceNotFound
            self.directory directory do
              owner user
              mode '0700'
              recursive true
            end
          end
        end
      end
    end
  end
end
