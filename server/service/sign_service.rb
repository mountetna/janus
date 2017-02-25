# sign_service.rb
# General signing/hashing utilities.

module SignService

  # Creates an ordered array of items (which includes a password and salt) for
  # hashing
  def self.order_params(pass)

    params = [pass, Conf::PASS_SALT]
  end

  # Takes an ordered array of request values and returns a signed hash.
  def self.hash_password(params, algo)

    signature = case algo.downcase
    when 'md5'    then sign_with_MD5(params)
    when 'sha256' then sign_with_SHA256(params)
    else ''
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
end