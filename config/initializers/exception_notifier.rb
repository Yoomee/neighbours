if Rails.env.production?
  Neighbours::Application.config.middleware.use ExceptionNotifier,
    :email_prefix => "[Neighbours] ",
    :sender_address => "notifier <notifier@neighbourscanhelp.org.uk>",
    :exception_recipients => %w{developers@yoomee.com}
end    