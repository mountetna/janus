# controller.rb
# The generic controller that handles validations and common processing tasks.

class Controller

  def initialize(request, action)

    @request = request
    @action = action
  end
end