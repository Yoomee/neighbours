Devise.setup do |config|
  config.allow_unconfirmed_access_for = 10.years
  config.reconfirmable = false
end