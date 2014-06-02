class WecheatApp
  post '/api/qrcode/create' do
    qr = Wecheat::Models::QRCode.new({
      appid: @app.id,
      action_name: params[:action_name],
      expire_seconds: params[:expire_seconds].to_i,
      scene_id: ((params[:action_info]||{})[:scene]||{})[:scene_id].to_i
    })
    qr.save
    json ticket: qr.ticket, expire_seconds: qr.expire_seconds
  end

  get '/api/showqrcode' do
    qr = Wecheat::Models::QRCode.find(params[:ticket])
    halt 404 if qr.nil?
    send_file qr.image(CGI.escape uri("/qrcode/#{qr.ticket}"))
  end
end