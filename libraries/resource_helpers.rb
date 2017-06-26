# frozen_string_literal: true

require_relative 'model/private_key'
require_relative 'model/public_key'
require_relative 'generator'

module AMA
  module Chef
    module SSHPrivateKeys
      # Just a bunch of methods to put dirty work out of resource definition
      module ResourceHelpers
        def guess_user_home_directory(user)
          "/home/#{user}"
        end

        def user_home_directory(user)
          Etc.getpwnam(user).dir
        rescue ArgumentError
          guess_user_home_directory(user).tap do |directory|
            ::Chef::Log.warn(
              "User #{user} hasn't been found at compile time, " \
              "using #{directory} as user home directory"
            )
          end
        end

        def ssh_directory(user)
          "#{user_home_directory(user)}/.ssh"
        end

        # @param [String] content
        # @param [String] passphrase
        # @return [AMA::Chef::SSHPrivateKeys::Model::PrivateKey]
        def new_private_key(content, passphrase)
          klass = ::AMA::Chef::SSHPrivateKeys::Model::PrivateKey
          klass.new(content, passphrase)
        end

        # @param [String] type
        # @param [String] content
        # @param [String] comment
        # @return [AMA::Chef::SSHPrivateKeys::Model::PublicKey]
        def new_public_key(type, content, comment = nil)
          klass = ::AMA::Chef::SSHPrivateKeys::Model::PublicKey
          klass.new(type, content, comment)
        end

        # @param [AMA::Chef::SSHPrivateKeys::Model::PrivateKey] private_key
        # @param [String, NilClass] comment
        # @return [AMA::Chef::SSHPrivateKeys::Model::PublicKey]
        def generate_public_key!(private_key, comment = nil)
          binary = Generator.locate_binary!
          Generator.new(binary).generate_public_key(private_key, comment)
        end

        # new_resource-aware methods

        def create_key_directory(directory = nil)
          user = new_resource.user
          directory = key_directory unless directory
          return if ::File.exist?(directory)
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

        def provided_public_key
          return nil unless new_resource.public_key
          new_public_key(
            new_resource.type,
            new_resource.public_key,
            new_resource.public_key_comment
          )
        end

        def provided_private_key
          new_private_key(new_resource.content, new_resource.passphrase)
        end

        def provided_key_pair
          ::AMA::Chef::SSHPrivateKeys::Model::KeyPair.new.tap do |pair|
            pair.type = new_resource.type
            pair.private_key = new_resource.content
            pair.public_key = new_resource.public_key
            pair.passphrase = new_resource.passphrase
            pair.comment = new_resource.comment
          end
        end

        def generated_public_key!
          generate_public_key!(provided_private_key, new_resource.comment)
        end

        def key_directory
          return @key_directory if instance_variable_defined?(:@key_directory)
          data = new_resource
          @key_directory = data.parent_directory || ssh_directory(data.user)
        end

        def private_key_path
          "#{key_directory}/#{new_resource.id}"
        end

        def public_key_path
          "#{private_key_path}#{new_resource.public_key_suffix}"
        end
      end
    end
  end
end
