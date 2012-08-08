STAGING = %x{pwd}.match(/^\/data\/neighbours_staging\//).present?

# Load the rails application
require File.expand_path('../application', __FILE__)

# Initialize the rails application
Neighbours::Application.initialize!
