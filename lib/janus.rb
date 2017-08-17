class Janus
  include Etna::Application
  attr_reader :db

  def connect db_config
    @db = Sequel.connect(db_config)
    @db.extension :connection_validator
    @db.pool.connection_validation_timeout = -1
    require_relative './server/models'
  end
end
