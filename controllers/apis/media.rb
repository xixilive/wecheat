class WecheatApp
  get '/api/media/get' do
    media = @app.media(params[:media_id])
    p File.join(settings.root, media.path)
    unless media.nil?
      send_file File.join(settings.public_folder, media.path)
    else
      json errcode: 40007
    end
  end

  post '/api/media/upload' do
    type = params[:type].to_s.downcase
    halt(json errcode: 40004) unless ['image', 'thumb', 'video', 'voice'].include?(type)
    media = @app.medias.select{|m| m.type == type}.first
    json type: type, media_id: media.id, created_at: Time.now.to_i
  end
end