Neighbours::Application.config.middleware.use ExceptionNotifier,
  :email_prefix => "[Neighbours] ",
  :sender_address => "notifier <notifier@neighbours.yoomee.com>",
  :exception_recipients => %w{developers@yoomee.com}