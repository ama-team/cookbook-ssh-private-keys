# frozen_string_literal: true

describe 'Functional' do
  describe ':: Resource' do
    describe ':: ssh_private_key' do
      describe ':: Requirements' do
        before(:each) do
          stub_data_bag('ssh-private-keys').and_return(['default'])
        end

        let(:runner) do
          ChefSpec::SoloRunner
            .new(step_into: ['ssh_private_key'])
        end

        it 'requires content to install' do
          value = { user: 'jodie', id: 'id_rsa' }
          stub_data_bag_item('ssh-private-keys', 'default').and_return(value)
          proc = lambda do
            runner.converge('ama-ssh-private-keys')
          end
          expect(&proc).to raise_error(::Chef::Exceptions::ValidationFailed)
        end

        it 'does not require content for deletion' do
          value = { user: 'jodie', id: 'id_rsa' }
          stub_data_bag_item('ssh-private-keys', 'default').and_return(value)
          converge = nil
          proc = lambda do
            recipe = 'ama-ssh-private-keys-acceptance::delete_using_data_bag'
            converge = runner.converge(recipe)
          end
          expect(&proc).not_to raise_error
          expect(converge).to delete_ssh_private_key('default').with(content: nil)
        end
      end
    end
  end
end
