source 'https://yoomee:wLjuGMTu30AvxVyIrq3datc73LVUkvo@gems.yoomee.com'
source 'http://rubygems.org'

### Always used
gem 'rails', '3.1.0'
gem 'mysql2'
gem "rake", "0.8.7"

### Frequently used
gem 'exception_notification'
gem 'formtastic-bootstrap', :git => "git://github.com/cgunther/formtastic-bootstrap.git", :branch => "bootstrap-2"
gem 'whenever', :require => false

### Yoomee gems
gem 'ym_core',          "~> 0.1.61" #, :path => "~/Rails/Gems/ym_core"
gem 'ym_cms',           "~> 0.3.3"  #, :path => "~/Rails/Gems/ym_cms"
gem 'ym_users',         "~> 0.1"    #, :path => "~/Rails/Gems/ym_users"
gem 'ym_posts',         "~> 0.1"    #, :path => "~/Rails/Gems/ym_posts"
gem 'ym_search',        "~> 0.1"    #, :path => "~/Rails/Gems/ym_search"
gem 'ym_notifications', "~> 0.1"    #, :path => "~/Rails/Gems/ym_notifications"
gem 'ym_enquiries',     "~> 0.1"    #, :path => "~/Rails/Gems/ym_enquiries"
gem 'ym_snippets',      "~> 0.1.1"  #, :path => "~/Rails/Gems/ym_snippets"
gem 'ym_messages',      "~> 0.0.9"  #, :path => "~/Rails/Gems/ym_messages"

gem 'client_side_validations'
gem 'client_side_validations-formtastic'
gem 'geocoder'
gem 'cocoon'
gem 'delayed_job_active_record'
gem 'daemons'

### Groups
# Gems used only for assets and not required
# in production environments by default.
group :assets do
 gem 'sass-rails', "  ~> 3.1.0"
 gem 'coffee-rails', "~> 3.1.0"
 gem 'uglifier'
end

group :development do
 gem 'growl'
 gem 'letter_opener'
 gem 'ruby-debug19'
 gem 'yoomee', :git => "git://git.yoomee.com:4321/gems/yoomee.git", :branch => "rails3"
 gem 'passenger'
 gem 'thin' 
 gem 'sqlite3'
end

gem "rspec-rails", :group => [:test, :development]
group :test do
 gem "factory_girl_rails"
 gem 'shoulda-matchers'
 gem "capybara"
 gem "guard-rspec"
 gem "sqlite3"
 #gem 'turn', :require => false
end