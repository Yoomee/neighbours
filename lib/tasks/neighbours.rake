namespace :neighbours do

  desc 'Send top level stats email'
  task :weekly_stats do
    UserMailer.weekly_top_stats.deliver if Rails.env.production?
  end
end