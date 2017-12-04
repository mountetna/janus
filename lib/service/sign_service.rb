# General signing/hashing utilities.
module SignService
  # Generate a hash for a plain-text password
  class << self
    def hash_password(password)
      signature(
        [ password, Janus.instance.config(:pass_salt) ],
        Janus.instance.config(:pass_algo)
      )
    end

    def jwt_token(payload)
      return JWT.encode(
        payload,
        rsa_key,
        Janus.instance.config(:token_algo)
      )
    end

    def rsa_key
      @rsa_key ||= OpenSSL::PKey::RSA.new(Janus.instance.config(:rsa_private))
    end

    private

    def signature(params, algo)
      digest = case algo.downcase.to_sym
      when :md5
        Digest::MD5.new
      when :sha256
        Digest::SHA256.new
      else
        raise "Unknown signature algorithm!"
      end
      digest.update(params.join)
      digest.hexdigest
    end
  end
end
