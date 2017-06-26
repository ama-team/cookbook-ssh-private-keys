# frozen_string_literal: true

require 'English'

require_relative 'exception/invalid_key_exception'
require_relative 'exception/ssh_keygen_missing_exception'

module AMA
  module Chef
    module SSHPrivateKeys
      # A simple wrapper class for ssh-keygen CLI utility
      class Generator
        def initialize(binary)
          @binary = binary
        end

        def public_key_fingerprint(public_key)
          execution = run_with_temporary_file(public_key) do |path|
            return [@binary, '-l', '-f', path]
          end
          if execution.error
            message = 'Failed to generate fingerprint for ' \
              "public key #{public_key}"
            raise_execution_exception(execution, message)
          end
          execution
        end

        # @param [AMA::Chef::SSHPrivateKeys::Model::PrivateKey] private_key
        # @param [String, NilClass] comment
        # @return [AMA::Chef::SSHPrivateKeys::Model::PublicKey]
        def generate_public_key(private_key, comment = nil)
          execution = run_with_temporary_file(private_key.content) do |path|
            [@binary, '-y', '-f', path, '-P', private_key.passphrase.to_s]
          end
          if execution.error?
            message = 'Failed to create public key from private key'
            raise_execution_exception(execution, message)
          end
          raw = execution.stdout.chomp
          match_data = /([\w\-]+)\s+([^\s]+)(?:\s+(.*)\s*)?/.match(raw)
          unless match_data
            msg = "Failed to read public key created from private key: #{raw}"
            raise_invalid_key_exception(msg)
          end
          ::AMA::Chef::SSHPrivateKeys::Model::PublicKey.new.tap do |key|
            key.type = match_data[1]
            key.content = match_data[2]
            key.comment = compute_comment(match_data[3], comment)
          end
        end

        def self.locate_binary
          execution = ::Mixlib::ShellOut.new('which', 'ssh-keygen')
          execution.run_command
          execution.error? ? nil : execution.stdout.lines.first.chomp
        end

        def self.locate_binary!
          binary = locate_binary
          return binary if binary
          raise(
            ::AMA::Chef::SSHPrivateKeys::Exception::SSHKeygenMissingException,
            'Failed to locate ssh-keygen binary for key validation'
          )
        end

        private

        def compute_comment(parsed_comment, provided_comment)
          comment = extract_comment(parsed_comment)
          comment.nil? ? extract_comment(provided_comment) : comment
        end

        def extract_comment(comment)
          return nil if comment.nil?
          comment = comment.strip
          comment.empty? ? nil : comment
        end

        def execute(*command)
          ::Chef::Log.debug("Executing command: #{command}")
          ::Mixlib::ShellOut.new(*command).tap(&:run_command)
        end

        def run_with_temporary_file(content)
          with_temporary_file(content) do |path|
            execute(*yield(path))
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

        def raise_invalid_key_exception(*message)
          raise(
            ::AMA::Chef::SSHPrivateKeys::Exception::InvalidKeyException,
            message.join(" #{$ORS}")
          )
        end

        def raise_execution_exception(execution, *message)
          message.push("STDOUT: #{execution.stdout}")
          message.push("STDERR: #{execution.stderr}")
          raise_invalid_key_exception(*message)
        end
      end
    end
  end
end
