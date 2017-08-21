module Conf
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

  VALID_HOSTS = [
    'janus.ucsf.edu',
    'janus-stage.ucsf.edu',
    'janus-dev.ucsf.edu',
    'polyphemus.ucsf.edu',
    'polyphemus-stage.ucsf.edu',
    'polyphemus-dev.ucsf.edu',
    'metis.ucsf.edu',
    'metis-stage.ucsf.edu',
    'metis-dev.ucsf.edu',
    'magma.ucsf.edu',
    'magma-stage.ucsf.edu',
    'magma-dev.ucsf.edu',
    'timur.ucsf.edu',
    'timur-stage.ucsf.edu',
    'timur-dev.ucsf.edu'
  ]
end
