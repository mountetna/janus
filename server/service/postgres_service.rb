module PostgresService

  def self.connect()

    db_config = {

      :adapter=> 'postgres',
      :host=> 'localhost', 
      :database=> 'janus',

      :user=> Conf::PSQL_USER,
      :password=> Conf::PSQL_PASS,
      :search_path=>['private']
    }

    Sequel.connect(db_config)
  end
end