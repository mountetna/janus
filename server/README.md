## Some notes about this server.

You are going to need a `conf.rb` file which will contain your app secrets and
configurations, and it should look like so...

./janus/server/conf.rb

```
# conf.rb
# Configuration for Janus.

module Conf

  PASS_SALT = [A LONG SALT]
  PASS_ALGO = 'sha256'

  TOKEN_SALT = [ANOTHER LONG SALT]
  TOKEN_ALGO = 'sha256'
  TOKEN_EXP = 60*60 # Tokens expire in 'n' seconds.

  PSQL_USER = [POSTGRES USER]
  PSQL_PASS = [POSTGRES PASSWORD]
end

```