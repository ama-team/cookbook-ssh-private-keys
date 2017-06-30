# frozen_string_literal: true

definitions = attribute('ama-ssh-private-keys', {})

definitions.each do |id, definition|
  expected = !definition.fetch('expects_failure', false)
  type = definition['type'] || 'ssh-rsa'
  private_key = definition['content']
  public_key = "#{type} #{definition['public_key']}" if definition['public_key']
  install_public_key = definition['install_public_key']

  describe ssh_private_key("/root/.ssh/#{id}") do
    if expected
      it { should exist }
      its('key') { should eq private_key }
      its('pubkey') do
        if install_public_key
          should_not be nil
          should include public_key if public_key
        else
          should be nil
        end
      end
    else
      it { should_not exist }
    end
  end
end
