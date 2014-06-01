class WecheatApp
  post '/api/menu/create' do
    @app.button = Wecheat::Models::Button.new(request.body.string) rescue nil
    if @app.button
      @app.save
      json errcode: 0
    else
      json errcode: 40015, errmsg: 'invalid button data'
    end
  end

  get '/api/menu/get' do
    json button: @app.button
  end

  get '/api/menu/delete' do
    @app.button = []
    @app.save
    json errcode: 0
  end
end