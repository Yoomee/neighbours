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
# ym_gem 'core'
# ym_gem 'videos'
# ym_gem 'cms'
# ym_gem 'permalinks'
# ym_gem 'users'
# ym_gem 'posts'
# ym_gem 'search'

gem 'ym_core' #, :path => "/Users/ianmooney/Rails/Gems/ym_core"
gem 'ym_users' #, :path => "/Users/ianmooney/Rails/Gems/ym_users"

gem 'client_side_validations'

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
 gem 'ruby-debug19'
 gem 'yoomee', :git => "git://git.yoomee.com:4321/gems/yoomee.git", :branch => "rails3"
 # comment this when deploying
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