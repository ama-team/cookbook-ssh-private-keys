require 'tempfile'

module AMA
  module Chef
    module SSHPrivateKeys
      class Validator
        def initialize
          @binary = nil
          @initialized = false
        end

        # @param [AMA::Chef::SSHPrivateKeys::Model::KeyPair] pair
        def validate(pair)
          lazy_initialize
          return unless @binary
          unless pair.private_key
            raise "Provided key pair #{pair.id} is missing private key"
          end
          public_key = generate_public_key(pair)
          unless pair.type == public_key.type
            raise "Key pair specified type #{pair.type}, but #{public_key.type} was discovered"
          end
          if pair.public_key and pair.public_key != public_key.data
            raise "Generated public key differs from provided public key #{pair.id}"
          end
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

        def get_public_key_fingerprint(pair)
          execution = run_with_temporary_file(pair.public_key) do |path|
            [@binary, '-l', '-f', path]
          end
          if execution.error
            prefix = "Failed to generate fingerprint for public key #{pair.id}"
            raise generate_validation_error(execution, prefix)
          end

        end

        # @param [AMA::Chef::SSHPrivateKeys::Model::KeyPair] pair
        # @return [AMA::Chef::SSHPrivateKeys::Model::PublicKey]
        def generate_public_key(pair)
          execution = with_temporary_file(pair.private_key) do |path|
            [@binary, '-y', '-f', path, '-P', pair.passphrase]
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

        def run_with_temporary_file(content, &block)
          with_temporary_file(content) do |path|
            Mixlib::ShellOut.new(&block.call(path)).run_command
          end
        end

        def with_temporary_file(content, &block)
          target = Tempfile.new(['ama-ssh-private-keys-'])
          ::IO.write(target.path, content)
          begin
            return block.call(target.path)
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
          ].join($\)
          AMA::Chef::SSHPrivateKeys::Model::InvalidKeyException.new(message)
        end
      end
    end
  end
end