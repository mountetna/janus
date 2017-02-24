# controller.rb
# The generic controller that handles validations and common processing tasks.

class Controller

  def initialize(request, action)

    @request = request
    @action = action
    @email_regex = /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/
  end

  def run()  

    send(@action)
  end
  
  def log_in()
  
  end

  def log_out()

  end

  def check_log()

  end

  def generate_token(email)

  end

  def check_pass(email, pass)

  end

  def send_bad_login()

  end

  def send_bad_request()

  end

  def send_server_error()

  end
end