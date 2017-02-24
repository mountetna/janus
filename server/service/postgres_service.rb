# postgres_service.rb

class PostgresService

  def initialize()

    db_config = {

      :adapter=> 'postgres',
      :host=> 'localhost', 
      :database=> 'janus',

      :user=> Conf::PSQL_USER,
      :password=> Conf::PSQL_PASS,
      :search_path=>['private']
    }

    @postgres = Sequel.connect(db_config)
  end
end