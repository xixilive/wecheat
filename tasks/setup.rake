require './models'

desc "setup faked data"
task :setup do
  Wecheat::Models.setup
end

desc "clear faked data"
task :purge do
  Wecheat::Models.purge
end
