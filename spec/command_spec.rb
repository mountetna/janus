require_relative '../lib/commands'

# A note on Etna::Command#setup
#
# Unfortunately Rack already sets up the application - this may cause us
# headache some day, since the commands are meant to call setup(config)
#
# If it ever does, we should figure out how to exercise setup here.
#
# For now we skip setup

describe Janus::Console do
  it "starts a console" do
    require 'irb'
    allow(IRB).to receive(:start)

    c = Janus::Console.new

    c.execute

    expect(IRB).to have_received(:start)
  end
end

describe Janus::AddUser do
  it "adds a user to the database" do
    c = Janus::AddUser.new

    c.execute(email, first_name, last_name)
  end
end
