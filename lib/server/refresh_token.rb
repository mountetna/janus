class Janus
  class RefreshToken
    def initialize(app)
      @app = app
    end

    def cookie_response(token, status, headers, body)
      response = Rack::Response.new(body, status, headers)

      Janus.instance.set_token_cookie(response, token)

      return response.finish
    end

    def call(env)
      request = Rack::Request.new(env)

      return @app.call(env) unless request.path == '/'

      Janus.instance.tap do |janus|

        existing_token = request.cookies[janus.config(:token_name)]

        return @app.call(env) if !existing_token || !request.env['etna.user']

        janus_user = User[email: request.env['etna.user'].email]

        return [ 401, { 'Content-Type' => 'application/json' }, [ { error: 'Unknown user in token' }.to_json ] ] unless janus_user

        payload = JSON.parse(
          Base64.decode64(existing_token.split(/\./)[1]), symbolize_names: true
        ).reject{|k|k == :exp}

        return @app.call(env) if payload == janus_user.jwt_payload

        return cookie_response(janus_user.create_token!, *@app.call(env))
      end
    end
  end
end
