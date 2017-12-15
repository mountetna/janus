class Janus
  class Nonce
    def initialize timestamp
      @timestamp = timestamp
    end

    def to_s
      # sign the time with our private key
      signature = Janus.instance.sign.private_key.sign(
        OpenSSL::Digest::SHA256.new,
        @timestamp
      )

      # Digest the signature
      hash = Digest::SHA256.hexdigest(signature)

      # encode the pair
      return Base64.strict_encode64("#{@timestamp}.#{hash}")
    end
  end
end
