# frozen-string_literal: true

# rubocop:disable Metrics/LineLength
# rubocop:disable Metrics/BlockLength

require 'mixlib/shellout'

describe 'resource ssh_private_key:' do
  describe 'behavior:' do
    type = 'ssh-rsa'
    private_key = '<private key>'
    public_key = '<public key>'
    resource = {
      user: 'jodie',
      content: private_key,
      type: type
    }

    before(:each) do
      stub_data_bag('ssh-private-keys').and_return(['default'])
      stub_data_bag_item('ssh-private-keys', 'default').and_return(resource)

      which = double(
        run_command: nil,
        error?: false,
        stdout: '/usr/bin/ssh-keygen',
        stderr: nil
      )
      allow(Mixlib::ShellOut).to(
        receive(:new).with('which', 'ssh-keygen').and_return(which)
      )

      key = double(
        run_command: nil,
        error?: false,
        stdout: "#{type} #{public_key}",
        stderr: nil
      )
      allow(Mixlib::ShellOut).to(
        receive(:new).with('/usr/bin/ssh-keygen', any_args).and_return(key)
      )
    end

    let(:chef_run) do
      ChefSpec::SoloRunner
        .new(step_into: ['ssh_private_key'])
        .converge('ama-ssh-private-keys')
    end

    it 'should install only private key by default' do |test_case|
      test_case.step 'private key generation validation' do
        expect(chef_run).to create_file('/home/jodie/.ssh/default')
      end

      test_case.step 'public key generation absence validation' do
        expect(chef_run).not_to create_file('/home/jodie/.ssh/default.pub')
      end
    end

    it 'should not create public key for installation if one is already provided' do |test_case|
      properties = resource.clone
      properties[:public_key] = public_key
      properties[:install_public_key] = true
      stub_data_bag_item('ssh-private-keys', 'default').and_return(properties)

      expect(Mixlib::ShellOut).not_to(
        receive(:new).with('/usr/bin/ssh-keygen', any_args)
      )

      test_case.step 'private key installation validation' do
        expect(chef_run).to create_file('/home/jodie/.ssh/default').with(
          content: private_key
        )
      end

      test_case.step 'public key installation validation' do
        expect(chef_run).to create_file('/home/jodie/.ssh/default.pub').with(
          content: "#{type} #{public_key}"
        )
      end
    end

    it 'should create public key for installation if none is provided' do |test_case|
      properties = resource.clone
      properties[:install_public_key] = true
      stub_data_bag_item('ssh-private-keys', 'default').and_return(properties)

      key = double(
        run_command: nil,
        error?: false,
        stdout: "#{type} #{public_key}",
        stderr: nil
      )
      allow(Mixlib::ShellOut).to(
        receive(:new).with('/usr/bin/ssh-keygen', any_args).and_return(key)
      )
      expect(Mixlib::ShellOut).to(
        receive(:new).with('/usr/bin/ssh-keygen', any_args).at_least(:once)
      )

      test_case.step 'private key installation validation' do
        expect(chef_run).to create_file('/home/jodie/.ssh/default').with(
          content: private_key
        )
      end

      test_case.step 'public key installation validation' do
        expect(chef_run).to create_file('/home/jodie/.ssh/default.pub').with(
          content: "#{type} #{public_key}"
        )
      end
    end

    it 'should use additional attributes if specified' do |test_case|
      properties = {
        user: 'jodie',
        content: private_key,
        type: type,
        mode: '0666',
        parent_directory: '/workspace'
      }
      stub_data_bag_item('ssh-private-keys', 'default').and_return(properties)

      test_case.step 'parent directory creation validation' do
        expect(chef_run).to create_directory('/workspace')
      end

      test_case.step 'private key generation validation' do
        expect(chef_run).to(
          create_file('/workspace/default')
            .with(mode: '0666', content: private_key, user: 'jodie')
        )
      end

      test_case.step 'public key generation absence validation' do
        expect(chef_run).not_to create_file('/workspace/default.pub')
      end
    end

    it 'should use additional public key attributes if specified' do |test_case|
      properties = {
        user: 'jodie',
        content: private_key,
        type: type,
        install_public_key: true,
        public_key: public_key,
        public_key_mode: '0666',
        public_key_suffix: '.suffix',
        parent_directory: '/workspace'
      }
      stub_data_bag_item('ssh-private-keys', 'default').and_return(properties)
      test_case.step 'public key generation validation' do
        expect(chef_run).to create_file('/workspace/default.suffix').with(
          content: "#{type} #{public_key}",
          mode: '0666'
        )
      end
    end

    it 'should not invoke ssh-keygen if type is not supplied' do |test_case|
      expect(Mixlib::ShellOut).not_to(
        receive(:new).with('/usr/bin/ssh-keygen', any_args)
      )

      test_case.step 'converge' do
        expect(chef_run).to create_file '/home/jodie/.ssh/default'
        expect(chef_run).not_to create_file '/home/jodie/.ssh/default.pub'
      end
    end

    it 'should invoke ssh-keygen if type is not supplied and public key installation requested' do |test_case|
      properties = resource.clone
      properties[:install_public_key] = true
      stub_data_bag_item('ssh-private-keys', 'default').and_return(properties)

      expect(Mixlib::ShellOut).to(
        receive(:new).with('/usr/bin/ssh-keygen', any_args).at_least(:once)
      )

      test_case.step 'converge' do
        expect(chef_run).to create_file '/home/jodie/.ssh/default'
        expect(chef_run).to create_file '/home/jodie/.ssh/default.pub'
      end
    end
  end
end
