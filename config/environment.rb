# Load the rails application
require File.expand_path('../application', __FILE__)

# Initialize the rails application
Hydradam::Application.initialize!

Hydradam::Application.configure do 
  config.fits_path = "#{Rails.root}/vendor/fits/fits.sh"
  config.max_days_between_audits = 7
end
