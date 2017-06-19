require_relative '../../libraries/model/key_pair'

module AMA
  module Chef
    module SSHPrivateKeys
      module KeyPairProvider
        def self.unprotected_pair
          AMA::Chef::SSHPrivateKeys::Model::KeyPair.new.tap do |pair|
            pair.id = 'unprotected'
            pair.type = 'ssh-rsa'
            pair.private_key = <<~EOF
              -----BEGIN RSA PRIVATE KEY-----
              MIIBywIBAAJhAK5YexcQVSQTeEVd23Q/xHOQYpq1wPqQH4jE/huzJfHRF7+tIsb+
              n37Wb+LVIJOmyFMeTW459bBgbQhe6lPbmYMuuHlAY16EntevGvWFfyG7Nte4gv6v
              yGr6xe22IJOxaQIDAQABAmAPpR7+ldeeEiUzzFVaHDLL0AQZMAAuO+qogkzvPWdF
              SOchqy64vrafUizeJRP0S/3+EB0l6sVWMlNCOf8VjHd8AUSLh4kw7AfZr+4vqG/l
              8S7E4MDANs7XWJcOs55H29ECMQDZ+rWJ7du5+aGZuZsRQVi6CTjaIyF5FqH0KlNS
              eiEJ2UVL5zsuplEd2p16Tu8dAWUCMQDMwWyI2CBc4sq2Mq566AottisYV4NCI4+6
              Tie5vWyz7yVM+yEHYgDvvCbqH6FyEbUCMQC85lFQWHrkLfrnVzuUtoaHodpM38jw
              QLbU+6D9hqz+9fThlF9rS+Jb9sol5iW9gykCMQCFqA1NFqepenGQlWzH1ggu5qci
              8J1B4yzDFJlh6YC3w/e5VISu6Q5rb4qHcbZVW7ECMCPDpr3dc5DGk3yR3sShawxH
              EZ9FO0f+IqMaqYduUT4hcuSC43w6exAVAA0eA4tXGA==
              -----END RSA PRIVATE KEY-----
            EOF
            pair.public_key = 'AAAAB3NzaC1yc2EAAAADAQABAAAAYQDhrEeBJCm22IsY3QAnKnU8CHTIPotvubEYfTij+pAvimwbJ0/8+y3Tav28UbWS7hyUOabPZXEBRcOFiweGyGAX/c5057P+Z5nQ8YaIbbJX7zKwsfDMIRLlgY85PjvCRns='
            pair.comment = 'unprotected'
          end
        end

        def self.passphrase_pair
          AMA::Chef::SSHPrivateKeys::Model::KeyPair.new.tap do |pair|
            pair.id = 'passphrased'
            pair.type = 'ssh-rsa'
            pair.private_key = <<~EOF
              -----BEGIN RSA PRIVATE KEY-----
              Proc-Type: 4,ENCRYPTED
              DEK-Info: AES-128-CBC,C87308057B7B93891079F7BBEDD841B9
              
              AUFHzZOXamOWIrngZkHBWAtcLEhDHDog6Usp2AxOcYFrTgmfVbIKiNgaKUO5vXHp
              6fkDpWIEFRquCf5zfprA1fYZ1e2fX/2KyR9XrGnCyUser2yytS0ws0OOkOFSGKPf
              GYZJE005wFsi8I3pz1IZQX9J25Mh+WVlQ4M/10l7OK0yNfIMUabqbvU8cxiyQqsW
              /82ePzKDcmfBoUicOYnUB1SZG+WWGasmb8bf3Qjqo7iawAJlsx4jmOjljdf+9fto
              wA2zJMvG+Pi3HVJcZxBAtaJs1WC1g2Xbdvx6SryFqz9YIqVAY6Fs/CHnYLGABcNu
              2g7p4tpDp5fteFfc2FOePi/gmi8FFaiSDBGwEIzuRB5zcZnkehc68Tjo7LdhWzYQ
              +fczcM4xPpiqXxZyS698TU4IXNQp1AV5nHDRsNRz7aNiCVwmtoae+qOrxr/Zyk7R
              fS5bjts6mFOOcjM8eT45TubmO2f3fZ3gcRij3DpVY6orxvPxSjpVC7XhsQzCGGJo
              20aW+S2UoetgxWRop13xIk7ZTVtMSE5dpFXUKaBaRAh1YxgQUXDlLxTIiN6I2cwQ
              vKbSueIdHt4+iqk3GXtGXPQmT82EzwvMEXZeTQCbLg4=
              -----END RSA PRIVATE KEY-----
            EOF
            pair.public_key = 'AAAAB3NzaC1yc2EAAAADAQABAAAAYQDCLY+8qnsrW/RrjDgz1b026hg9Lb78KV2c00sA4v6iSHVZoRKdnoIFr3dnWwV5Urt1U9fJJVy0fPLDWnAdYtI7U37k0GLpZhPS3ps/W9j1ZgslEQMQpvAD19yuJG/NXzk='
            pair.comment = 'passphrased'
            pair.passphrase = 'passphrase'
          end
        end

        def self.private_key_pair
          AMA::Chef::SSHPrivateKeys::Model::KeyPair.new.tap do |pair|
            pair.id = 'private-only'
            pair.type = 'ssh-rsa'
            pair.private_key = <<~EOF
              -----BEGIN RSA PRIVATE KEY-----
              MIIBzAIBAAJhAPYC5Y/f1GydsdsxDld3gcILOn7hUIsShvEv8W2wo1RFHZGBKMqa
              4qonXRNijz6S5GXBH5liOd8kwZJ1FYXGTaSGlI/t86hXAxkGXvn0a0TOoKpH0Fd4
              t5WkS1R5/gkQzQIDAQABAmAdWc0ftDm417ufhiPK5bQyfXp2JtWgMg6teeXZC2kB
              JdnYQUunmIEQge/F301tzsJ7SJmjHEQokCduqG9wAyplzWqwDqC4syLluBfrtBfh
              e5ApDUYi9qZMsCyCQA/j3gECMQD/5romxTUF0Cg+tI52BasFD9NHmNSLGeGNZR/u
              9qH2PAzkd4w1mIOz5y0Cvs22/4ECMQD2GzFd299VaF/fjzeFApgt/ZC+xzr3Q6B8
              cD7BQjpoStI40U7D6rQuiHcABjnZt00CMQDErM7LN2wOALK9psWK/cY4CLaoY1SP
              aB/LLTqCzXkjJ3n9KchP9NzcKsOURZMTn4ECMQDQi+R+Y6ZR6ntrpyHl7XflaPxy
              HcOi6kShjkAvZh62Z8jSatNzA30h/XPRqnT1P/UCMQCCxmy42EaisPHQxWCxvYDr
              +kBx8m82w4A/3ODRAZqUX/8HnRut1JSFrfW+N61IUU0=
              -----END RSA PRIVATE KEY-----
            EOF
            # pair.public_key = 'AAAAB3NzaC1yc2EAAAADAQABAAAAYQD2AuWP39RsnbHbMQ5Xd4HCCzp+4VCLEobxL/FtsKNURR2RgSjKmuKqJ10TYo8+kuRlwR+ZYjnfJMGSdRWFxk2khpSP7fOoVwMZBl759GtEzqCqR9BXeLeVpEtUef4JEM0='
            pair.comment = 'private-only'
          end
        end

        def self.invalid_passphrase_pair
          passphrase_pair.tap do |pair|
            pair.passphrase = pair.passphrase * 2
          end
        end

        def self.mismatching_pair
          unprotected_pair.tap do |pair|
            pair.private_key = private_key_pair.private_key
          end
        end

        def self.invalid_type_pair
          unprotected_pair.tap do |pair|
            pair.type = 'ssh-ecdsa'
          end
        end

        def self.illegal_type_pair
          unprotected_pair.tap do |pair|
            pair.type = 'ssh-bolgencrypt'
          end
        end
      end
    end
  end
end
