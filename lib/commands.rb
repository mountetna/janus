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
          user.pass_hash = Janus.instance.sign.hash_password(password)
        end
        user.save
      end
    end

    def setup(config)
      Janus.instance.configure(config)
      Janus.instance.setup_db
    end
  end

  class AddProject < Etna::Command
    usage '<project_name> <project_name_full>'
    def execute project_name, project_name_full
      attributes = { project_name: project_name }
      project = Project.find(attributes) || Project.new(attributes)
      project.project_name_full = project_name_full
      project.save
    end

    def setup(config)
      Janus.instance.configure(config)
      Janus.instance.setup_db
    end
  end

  class Permit < Etna::Command
    usage '<email> <project_name> <role>'
    def execute email, project_name, role
      user = User[email: email]
      project = Project[project_name: project_name]
      if !user
        puts "User not found."
        exit
      end

      if !project
        puts "Project not found."
        exit
      end

      attributes = { project: project, user: user }
      perm = Permission.find(attributes) || Permission.new(attributes)
      perm.role = role
      perm.save
    end

    def setup(config)
      Janus.instance.configure(config)
      Janus.instance.setup_db
    end
  end
  class Migrate < Etna::Command
    usage 'Run migrations for the current environment.'
    
    def execute(version=nil)
      Sequel.extension(:migration)
      db = Janus.instance.db

      if version
        puts "Migrating to version #{version}"
        Sequel::Migrator.run(db, 'db/migrations', target: version.to_i)
      else
        puts 'Migrating to latest'
        Sequel::Migrator.run(db, 'db/migrations')
      end
    end

    def setup(config)
      super
      Janus.instance.setup_db(false)
    end
  end
end
