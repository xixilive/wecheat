class WecheatApp
  get '/api/user/get' do
    json total: @app.users.size, count: @app.users.size, data: {openid: @app.users.collect{|u| u.openid }}, next_openid: ''
  end

  get '/api/user/info' do
    json @app.user(params[:openid]) || {errcode: 46004}
  end
end