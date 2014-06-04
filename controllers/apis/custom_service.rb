class WecheatApp
  post '/api/customservice/getrecord' do
    ps, users = [[params[:pagesize].to_i, 10].max, 1000].min, @app.users
    json((1..ps).collect do |i|
      {
        worker: Faker::Internet.user_name,
        openid: users[rand(users.size)].openid,
        opercode: [1000, 1001, 1002, 1004, 1005, 2001, 2002, 2003][rand(8)],
        time: Time.now.to_i,
        text: Faker::Lorem.sentence
      }
    end)
  end
end