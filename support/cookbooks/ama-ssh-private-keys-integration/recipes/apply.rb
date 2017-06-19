#
# Cookbook:: ama-ssh-private-keys-integration
# Recipe:: apply
#
# The MIT License (MIT)
#
# Copyright:: 2017, AMA Team
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.

pair = node['key']

ssh_private_key pair['id'].to_s do
  type pair['type'] if pair.has_key?('type')
  private_key pair['private_key']
  public_key pair['public_key'] if pair.has_key?('public_key')
  comment pair['comment'] if pair.has_key?('comment')
  passphrase pair['passphrase'] if pair.has_key?('passphrase')
  verify pair['validate'] if pair.has_key?('validate')
end
