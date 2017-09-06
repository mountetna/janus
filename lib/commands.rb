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

      Janus.instance.connect(Janus.instance.config(:db))
      require_relative 'server/models'
    end
  end

  class AddUser < Etna::Command
  end
end
