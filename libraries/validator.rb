require 'tempfile'
require 'English'

module AMA
  module Chef
    module SSHPrivateKeys
      # Validates provided key pair using ssh-keygen
      class Validator
        def initialize
          @binary = nil
          @initialized = false
        end

        # @param [AMA::Chef::SSHPrivateKeys::Model::KeyPair] pair
        def validate!(pair)
          lazy_initialize
          unless @binary
            ::Chef::Log.warn(
              "Can't validate key pair #{pair.id}: " \
              'ssh-keygen executable not found'
            )
            return
          end
          unless pair.private_key
            message = "Provided key pair #{pair.id} is missing private key"
            raise_invalid_key_exception(message)
          end
          public_key = generate_public_key(pair)
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

        def lazy_initialize
          return if @initialized
          @binary = locate_binary
          @initialized = true
        end

        def locate_binary
          execution = Mixlib::ShellOut.new('which', 'ssh-keygen').run_command
          execution.error? ? nil : execution.stdout.lines.first.chomp
        end

        # @param [String] message
        def raise_invalid_key_exception(message)
          klass = AMA::Chef::SSHPrivateKeys::Model::InvalidKeyException
          raise klass.new(message)
        end

        def get_public_key_fingerprint(pair)
          execution = run_with_temporary_file(pair.public_key) do |path|
            return [@binary, '-l', '-f', path]
          end
          if execution.error
            prefix = "Failed to generate fingerprint for public key #{pair.id}"
            raise generate_validation_error(execution, prefix)
          end
          execution
        end

        # @param [AMA::Chef::SSHPrivateKeys::Model::KeyPair] pair
        # @return [AMA::Chef::SSHPrivateKeys::Model::PublicKey]
        def generate_public_key(pair)
          execution = run_with_temporary_file(pair.private_key) do |path|
            [@binary, '-y', '-f', path, '-P', pair.passphrase.to_s]
          end
          if execution.error?
            prefix = "Failed to create public key from private key #{pair.id}"
            raise generate_validation_error(execution, prefix)
          end
          raw = execution.stdout.chomp
          match_data = /([\w\-]+)\s+([^\s]+)\s*(.*)/.match(raw)
          unless match_data
            raise "Failed to read public key created from private key: #{raw}"
          end
          AMA::Chef::SSHPrivateKeys::Model::PublicKey.new.tap do |key|
            key.type = match_data[1]
            key.data = match_data[2]
            key.comment = match_data[3]
          end
        end

        def run_with_temporary_file(content)
          with_temporary_file(content) do |path|
            command = yield(path)
            ::Chef::Log.debug("Executing command: #{command}")
            ::Mixlib::ShellOut.new(*command).run_command
          end
        end

        def with_temporary_file(content)
          target = Tempfile.new(['ama-ssh-private-keys-'])
          ::IO.write(target.path, content)
          begin
            return yield(target.path)
          ensure
            target.close(true)
          end
        end

        # @param [Mixlib::ShellOut] execution
        # @param [String] prefix
        def generate_validation_error(execution, prefix = nil)
          unless prefix
            prefix = "Error while running command #{execution.command}:"
          end
          message = [
            prefix,
            "STDOUT: #{execution.stdout}",
            "STDERR: #{execution.stderr}"
          ].join(" #{$ORS}")
          AMA::Chef::SSHPrivateKeys::Model::InvalidKeyException.new(message)
        end
      end
    end
  end
end
