namespace :neighbours do

  desc 'Send top level stats email'
  task do
    UserMailer.weekly_top_stats.deliver
  end  
end