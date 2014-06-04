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

  post '/api/media/uploadnews' do
    articles = params[:articles]
    halt(json errcode: 40035) unless articles.is_a?(Array)
    media = Wecheat::Models::Media.new({
      type: 'news',
      articles: articles.collect{|a| Wecheat::Models::Article.new(a) }
    })
    @app.medias << media
    @app.save
    json type: 'news', media_id: media.id, created_at: Time.now.to_i
  end

  post '/api/media/uploadvideo' do
    media = @app.media(params[:media_id])
    halt errcode: 40007 if media.nil?
    media.title = params[:title] || 'Title'
    media.description = params[:description] || 'Description'
    @app.save
    json type: 'video', media_id: media.id, created_at: Time.now.to_i
  end
end