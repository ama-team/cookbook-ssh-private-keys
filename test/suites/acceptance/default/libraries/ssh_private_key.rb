# frozen_string_literal: true

class SSHPrivateKey < Inspec.resource(1)
  name 'ssh_private_key'

  def initialize(path, pubkey_path = nil)
    @path = path
    @pubkey_path = pubkey_path ? pubkey_path : "#{path}.pub"
    inspec.file(@path).tap do |file|
      @key = file.content if file.file?
    end
    inspec.file(@pubkey_path).tap do |file|
      @pubkey = file.content if file.file?
    end
  end

  # rubocop:disable Style/MethodMissing
  def method_missing(name)
    instance_variable_get("@#{name}")
  end
  # rubocop:enable Style/MethodMissing

  def exists?
    !@key.nil?
  end

  def to_s
    "ssh private key #{@path}"
  end
end
