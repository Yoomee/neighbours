# http://github.com/javan/whenever

every 1.day, :at => '6pm' do
  set :output, File.expand_path("#{File.dirname(__FILE__)}/../../../shared/sphinx_rebuilds.log")
  rake "ts:index -t"
end

every :monday, :at => '8am' do
  runner "UserMailer.weekly_top_stats.deliver"
end

