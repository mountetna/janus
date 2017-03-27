module Conf

  TOKEN_EXP = 60*60 # Tokens expire in 'n' seconds.

  # Warning and error messages that will end up in the log
  WARNS = [

    :PARAMS_NOT_PRESENT,   # 0
    :PARAMS_NOT_CORRECT,   # 1
    :INVALID_LOG,          # 2
    :TOKEN_NOT_VALID,      # 3 
    :NO_PERMS,             # 4 
    :INVALID_GROUP         # 5 
  ]

  ERRORS = [

    :TOKEN_USER_MISMATCH,   # 0
    :CONNECTION_ERROR       # 1
  ]

  EMAIL_MATCH = /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/
end
