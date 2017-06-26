# frozen_string_literal: true

# rubocop:disable Metrics/LineLength
# rubocop:disable Metrics/BlockLength

require_relative '../../../../libraries/exception/ssh_keygen_missing_exception'
require_relative '../../../../libraries/exception/invalid_key_exception'

describe 'resource ssh_private_key:' do
  describe 'validation:' do
    before(:each) do
      stub_data_bag('ssh-private-keys').and_return(['default'])

      doubler = double(
        run_command: nil,
        error?: false,
        stdout: '/usr/bin/ssh-keygen',
        stderr: nil
      )
      matcher = receive(:new).with('which', 'ssh-keygen').and_return(doubler)
      allow(Mixlib::ShellOut).to matcher
    end

    let(:chef_run) do
      ChefSpec::SoloRunner
        .new(step_into: ['ssh_private_key'])
        .converge('ama-ssh-private-keys')
    end

    let(:which_response) do
      double(
        run_command: nil,
        error?: false,
        stdout: '/usr/bin/ssh-keygen',
        stderr: nil
      )
    end

    it 'should not run validation by default' do |test_case|
      properties = {
        type: 'ssh-rsa',
        user: 'jodie',
        content: 'aabbccdd'
      }

      stub_data_bag_item('ssh-private-keys', 'default').and_return(properties)

      doubler = double(run_command: nil, error?: true, stdout: nil, stderr: nil)
      matcher = receive(:new).with('which', 'ssh-keygen').and_return(doubler)
      allow(Mixlib::ShellOut).to matcher
      expect(doubler).not_to receive(:stdout)
      expect(Mixlib::ShellOut).not_to receive(:new)

      test_case.step 'converge' do
        expect(chef_run).to create_ssh_private_key('default').with(properties)
      end
    end

    it 'should raise exception in case of missing ssh-keygen' do |test_case|
      doubler = double(run_command: nil, error?: true, stdout: nil, stderr: nil)
      matcher = receive(:new).with('which', 'ssh-keygen').and_return(doubler)
      allow(Mixlib::ShellOut).to matcher

      properties = {
        user: 'jodie',
        content: 'aabbccdd',
        perform_validation: true
      }
      stub_data_bag_item('ssh-private-keys', 'default').and_return(properties)

      test_case.step 'catching exception about missing ssh-keygen' do
        expect { chef_run }.to raise_error(
          ::AMA::Chef::SSHPrivateKeys::Exception::SSHKeygenMissingException
        )
      end
    end

    it 'should successfully run validation against single private key' do |test_case|
      type = 'ssh-rsa'
      properties = {
        user: 'jodie',
        content: 'aabbccdd',
        type: type,
        perform_validation: true
      }

      doubler = double(
        run_command: nil,
        error?: false,
        stdout: "#{type} aabb",
        stderr: nil
      )
      allow(Mixlib::ShellOut).to receive(:new).and_return(doubler)
      stub_data_bag_item('ssh-private-keys', 'default').and_return(properties)
      expect(doubler).to receive(:stdout).at_least(:once)

      test_case.step 'converge' do
        expect(chef_run).to create_ssh_private_key('default').with(properties)
      end
    end

    it 'should successfully run validation against key pair' do |test_case|
      type = 'ssh-rsa'
      public_key = 'aabbccdd'
      properties = {
        user: 'jodie',
        content: 'aabbccdd',
        type: type,
        public_key: public_key,
        perform_validation: true
      }

      doubler = double(
        run_command: nil,
        error?: false,
        stdout: "#{type} #{public_key}",
        stderr: nil
      )
      allow(Mixlib::ShellOut).to receive(:new).and_return(doubler)
      stub_data_bag_item('ssh-private-keys', 'default').and_return(properties)
      expect(doubler).to receive(:stdout).at_least(:once)

      test_case.step 'converge' do
        expect(chef_run).to create_ssh_private_key('default').with(properties)
      end
    end

    it 'should raise exception on type mismatch' do |test_case|
      type = 'ssh-rsa'
      public_key = 'aabbccdd'
      properties = {
        user: 'jodie',
        content: 'aabbccdd',
        type: type,
        public_key: public_key,
        perform_validation: true
      }

      doubler = double(
        run_command: nil,
        error?: false,
        stdout: "ssh-dss #{public_key}",
        stderr: nil
      )
      allow(Mixlib::ShellOut).to receive(:new).and_return(doubler)
      stub_data_bag_item('ssh-private-keys', 'default').and_return(properties)
      expect(doubler).to receive(:stdout).at_least(:once)

      test_case.step 'catching invalid key exception' do
        expect { chef_run }.to raise_error(
          ::AMA::Chef::SSHPrivateKeys::Exception::InvalidKeyException
        )
      end
    end

    it 'should raise exception on public key mismatch' do |test_case|
      type = 'ssh-rsa'
      public_key = 'aabbccdd'
      properties = {
        user: 'jodie',
        content: 'aabbccdd',
        type: type,
        public_key: public_key,
        perform_validation: true
      }

      doubler = double(
        run_command: nil,
        error?: false,
        stdout: "#{type} ddccbbaa",
        stderr: nil
      )
      allow(Mixlib::ShellOut).to receive(:new).and_return(doubler)
      stub_data_bag_item('ssh-private-keys', 'default').and_return(properties)
      expect(doubler).to receive(:stdout).at_least(:once)

      test_case.step 'catching invalid key exception' do
        expect { chef_run }.to raise_error(
          ::AMA::Chef::SSHPrivateKeys::Exception::InvalidKeyException
        )
      end
    end
  end
end
