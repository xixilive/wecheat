class WecheatApp
  def create_mass
    mass = Wecheat::Models::Mass.new(request: request.body.string, appid: @app.id)
    mass.response = Wecheat::MessageBuilder.new.tap do |b|
      b.cdata 'ToUserName', @app.label
      b.cdata 'FromUserName', 'mphelper'
      b.CreateTime Time.now.to_i
      b.cdata 'MsgType', 'event'
      b.cdata 'Event', 'MASSSENDJOBFINISH'
      b.MsgID mass.id
      b.cdata 'Status', 'send success'
      b.cdata 'TotalCount', 1
      b.cdata 'FilterCount', 0
      b.cdata 'SentCount', 1
      b.cdata 'ErrorCount', 0
    end.to_xml
    mass.save
    mass
  end

  post '/api/message/mass/sendall' do
    json errcode: 0, msg_id: create_mass.id
  end

  post '/api/message/mass/send' do
    json errcode: 0, msg_id: create_mass.id
  end

  post '/api/message/mass/delete' do
    if mass = Wecheat::Models::Mass.find(params[:msgid])
      mass.remove
    end
    json errcode: 0
  end
end