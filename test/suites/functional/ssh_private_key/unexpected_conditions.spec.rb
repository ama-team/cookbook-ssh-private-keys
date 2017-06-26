# frozen_string_literal: true

# rubocop:disable Metrics/LineLength
# rubocop:disable Metrics/BlockLength

require_relative '../../../../libraries/exception/invalid_key_exception'
require_relative '../../../../libraries/exception/ssh_keygen_missing_exception'

describe 'resource ssh_private_key:' do
  describe 'unexpected conditions:' do
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

    it 'should raise exception in case of missing ssh-keygen' do |test_case|
      properties = {
        user: 'jodie',
        content: 'aabbccdd',
        perform_validation: true
      }
      stub_data_bag_item('ssh-private-keys', 'default').and_return(properties)

      doubler = double(run_command: nil, error?: true, stdout: nil, stderr: nil)
      matcher = receive(:new).with('which', 'ssh-keygen').and_return(doubler)
      allow(Mixlib::ShellOut).to matcher

      test_case.step 'catching exception about missing ssh-keygen' do
        expect { chef_run }.to raise_error(
          ::AMA::Chef::SSHPrivateKeys::Exception::SSHKeygenMissingException
        )
      end
    end

    it 'should raise exception in case of unreadable ssh-keygen output' do |test_case|
      properties = {
        user: 'jodie',
        content: 'aabbccdd',
        perform_validation: true
      }
      stub_data_bag_item('ssh-private-keys', 'default').and_return(properties)

      doubler = double(
        run_command: nil,
        error?: false,
        stdout: 'wharrgarbl',
        stderr: nil
      )
      allow(Mixlib::ShellOut).to receive(:new).and_return(doubler)

      test_case.step 'catching invalid output exception' do
        expect { chef_run }.to raise_error(
          ::AMA::Chef::SSHPrivateKeys::Exception::InvalidKeyException
        )
      end
    end
  end
end
