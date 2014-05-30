require './models'

desc "setup faked data"
task :setup do
  Wechat::Models.setup
end

desc "clear faked data"
task :purge do
  Wechat::Models.purge
end
