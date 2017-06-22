# frozen_string_literal: true

# rubocop:disable Metrics/LineLength
# rubocop:disable Metrics/BlockLength

require 'mixlib/shellout'

require_relative '../../../libraries/exception/invalid_key_exception'
require_relative '../../../libraries/exception/ssh_keygen_missing_exception'

recipe = 'ama-ssh-private-keys::default'

type = 'ssh-rsa'
private_key = 'aabbccdd'
public_key = 'aabbccdd'
data_bag_item = {
  'user' => 'root',
  'private_key' => private_key,
  'public_key' => public_key,
  'type' => type,
  'public_key_mode' => '0777',
  'private_key_mode' => '0777',
  'public_key_suffix' => '.publee',
  'parent_directory' => '/workspace',
  'passphrase' => 'passphrase',
  'comment' => 'broccoli'
}

describe recipe do
  let(:chef_run) do
    ChefSpec::SoloRunner.new(step_into: ['ssh_private_key']).converge(recipe)
  end

  it 'should create valid key' do |test_case|
    signature = "#{type} #{public_key}"
    doubler = double(run_command: nil, error?: false, stdout: signature)
    allow(Mixlib::ShellOut).to receive(:new).and_return(doubler)
    stub_data_bag('ssh-private-keys').and_return(['root'])
    stub_data_bag_item('ssh-private-keys', 'root').and_return(data_bag_item)
    test_case.step 'Key creation validation' do
      expect(chef_run).to create_ssh_private_key('root').with(data_bag_item)
    end
  end

  it 'should throw validation exception in case of type mismatch' do |test_case|
    signature = "ssh-dss #{public_key}"
    doubler = double(run_command: nil, error?: false, stdout: signature)
    allow(Mixlib::ShellOut).to receive(:new).and_return(doubler)
    stub_data_bag('ssh-private-keys').and_return(['root'])
    stub_data_bag_item('ssh-private-keys', 'root').and_return(data_bag_item)
    test_case.step 'Error validation' do
      expect { chef_run }.to raise_error(
        AMA::Chef::SSHPrivateKeys::Exception::InvalidKeyException
      )
    end
  end

  it 'should throw validation exception if public keys mismatch' do |test_case|
    signature = "#{type} #{public_key}#{public_key}"
    doubler = double(run_command: nil, error?: false, stdout: signature)
    allow(Mixlib::ShellOut).to receive(:new).and_return(doubler)
    stub_data_bag('ssh-private-keys').and_return(['root'])
    stub_data_bag_item('ssh-private-keys', 'root').and_return(data_bag_item)
    test_case.step 'Error validation' do
      expect { chef_run }.to raise_error(
        AMA::Chef::SSHPrivateKeys::Exception::InvalidKeyException
      )
    end
  end

  it 'should throw validation exception if public key generation fails' do |test_case|
    which = double(run_command: nil, error?: false, stdout: '/usr/bin/ssh-keygen', stderr: nil)
    doubler = double(run_command: nil, error?: true, stdout: nil, stderr: nil)
    allow(Mixlib::ShellOut).to receive(:new).and_return(which, doubler)
    stub_data_bag('ssh-private-keys').and_return(['root'])
    stub_data_bag_item('ssh-private-keys', 'root').and_return(data_bag_item)
    test_case.step 'Error validation' do
      expect { chef_run }.to raise_error(
        AMA::Chef::SSHPrivateKeys::Exception::InvalidKeyException
      )
    end
  end

  it 'should throw missing ssh-keygen exception on missing ssh-keygen' do |test_case|
    which = double(run_command: nil, error?: true, stdout: nil, stderr: nil)
    doubler = double(run_command: nil, error?: false, stdout: nil, stderr: nil)
    allow(Mixlib::ShellOut).to receive(:new).and_return(which, doubler)
    stub_data_bag('ssh-private-keys').and_return(['root'])
    stub_data_bag_item('ssh-private-keys', 'root').and_return(data_bag_item)
    test_case.step 'Error validation' do
      expect { chef_run }.to raise_error(
        AMA::Chef::SSHPrivateKeys::Exception::SSHKeygenMissingException
      )
    end
  end

  it 'should create invalid key if validation is disabled' do |test_case|
    signature = "#ssh-dss #{public_key}"
    doubler = double(run_command: nil, error?: false, stdout: signature)
    allow(Mixlib::ShellOut).to receive(:new).and_return(doubler)
    stub_data_bag('ssh-private-keys').and_return(['root'])
    item_double = data_bag_item.clone
    item_double['perform_validation'] = false
    stub_data_bag_item('ssh-private-keys', 'root').and_return(item_double)
    test_case.step 'Key creation validation' do
      expect(chef_run).to create_ssh_private_key('root').with(item_double)
    end
  end
end
