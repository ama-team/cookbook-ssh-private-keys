definitions = attribute('ama-ssh-private-keys', {})

definitions.each do |id, definition|
  expected = !definition.fetch('expects_failure', false)
  private_key = definition['private_key']
  public_key = definition['public_key']

  describe ssh_private_key("/root/.ssh/#{id}") do
    if expected
      it { should exist }
      its('key') { should eq private_key }
      its('pubkey') { should eq public_key }
    else
      it { should_not exist }
    end
  end
end
