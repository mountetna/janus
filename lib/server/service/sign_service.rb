# General signing/hashing utilities.
module SignService
  # Generate a hash for a plain-text password
  def self.hash_password(password)
    params = [ password, Janus.instance.config(:pass_salt) ]
    self.signature(params, Janus.instance.config(:pass_algo))
  end

  # Generate a hash for a token
  def self.hash_token
    params = [
      Time.now.getutc.to_s,
      self.generate_random(
        Janus.instance.config(:token_seed_length)
      ),
      Janus.instance.config(:token_salt)
    ]
    self.signature(params, Janus.instance.config(:token_algo))
  end

  def self.signature(params, algo)
    signature = case algo.downcase.to_sym
    when :md5
      sign_with_MD5(params)
    when :sha256
      sign_with_SHA256(params)
    else
      ''
    end
  end

  # Takes an ordered array of request values, strigifies it, concatenates a
  # secret and hashes the resultant string with MD5.
  def self.sign_with_MD5(params)
    param_str = stringify_params(params)
    md5 = Digest::MD5.new
    md5.update param_str
    md5.hexdigest
  end

  # Takes an ordered array of request values, strigifies it, concatenates a
  # secret and hashes the resultant string with SHA256.
  def self.sign_with_SHA256(params)
    param_str = stringify_params(params)
    sha256 = Digest::SHA256.new
    sha256.update param_str
    sha256.hexdigest
  end

  # Takes an ordered array of request vaules and strigifies it. 
  def self.stringify_params(ordered_params)
    ordered_params.join
  end

  # Generates a random string made of numbers and letters.
  def self.generate_random(length)
    o = [('a'..'z'), ('A'..'Z'), (0..9)].map(&:to_a).flatten
    (0...length).map { o[rand(o.length)] }.join
  end
end
