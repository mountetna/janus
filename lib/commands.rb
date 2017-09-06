class Janus
  class Help < Etna::Command
    usage 'List this help'

    def execute
      puts 'Commands:'
      Janus.instance.commands.each do |name,cmd|
        puts cmd.usage
      end
    end

    def setup(config)
      Janus.instance.configure(config)
    end
  end

  class Console < Etna::Command
    usage 'Open a console with a connected magma instance.'

    def execute
      require 'irb'
      ARGV.clear
      IRB.start
    end

    def setup(config)
      Janus.instance.configure(config)
      Janus.instance.setup_db
    end
  end

  class AddUser < Etna::Command
    usage '<email> <first_name> <last_name> [<password>]'
    def execute email, first_name, last_name, password=nil
      user = User.find_or_create(email: email)
      user.tap do |user|
        user.first_name = first_name
        user.last_name  = last_name
        if password
          user.pass_hash = SignService::hash_password(password)
        end
        user.save
      end
    end

    def setup(config)
      Janus.instance.configure(config)
      Janus.instance.setup_db
    end
  end
end
