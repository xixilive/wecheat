class WecheatApp
  post '/api/groups/create' do
    group = Wecheat::Models::Group.new(params[:group])
    if group
      @app.groups << group
      @app.save
      json group: group
    else
      json errcode: 40050
    end
  end

  get '/api/groups/get' do
    json groups: @app.groups.collect{|g| {id: g.id, name: g.name, count: @app.users.select{|u| u.group_id.to_s == g.id.to_s }.size } }
  end

  post '/api/groups/getid' do
    if user = @app.user(params[:openid])
      json group_id: user.group_id
    else
      json errcode: 40003
    end
  end

  post '/api/groups/update' do
    group = @app.group((params[:group]||{})[:id])
    if group
      group.name = params[:group][:name]
      @app.save
      json errcode: 0
    else
      json json errcode: 40050
    end
  end

  post '/api/groups/members/update' do
    if user = @app.user(params[:openid])
      user.group_id = params[:to_groupid]
      @app.save
      json errcode: 0
    else
      json errcode: 40050
    end
  end
end