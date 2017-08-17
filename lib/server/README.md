## Some notes about setting up.

You are going to need a `secrets.rb` file which will contain your app secrets 
and it should look like so...

./janus/server/secrets.rb


```
module Secrets

  PASS_ALGO = 'sha256'
  PASS_SALT = [A LONG SALT]

  TOKEN_ALGO = 'sha256'
  TOKEN_SALT = [ANOTHER LONG SALT]

  PSQL_USER = [POSTGRES USER]
  PSQL_PASS = [POSTGRES PASSWORD]
end
```