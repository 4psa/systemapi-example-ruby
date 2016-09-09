=begin
4PSA VoipNow SystemAPI Client for Ruby

Copyright (c) 2012, Rack-Soft (www.4psa.com). All rights reserved.
VoipNow is a Trademark of Rack-Soft, Inc
4PSA is a Registered Trademark of Rack-Soft, Inc.
All rights reserved.

This script adds a service provider.
=end
require 'rubygems'
require 'securerandom'
gem 'soap4r'
require 'VoIpNowServiceDriver.rb'
require 'soap/header/simplehandler'

if ARGV.length != 1
  puts "Usage: ruby <ruby_file.rb> \"<access_token>\"\n"
  puts "example: ruby DemoCallServiceProvider.rb \"1|V_pmPvEm25-HrqAzERx_nvJbBvNs~q3F|1|v-gntT4GFH-UCUX0EM2_r9XTVDtw~qCF\"\n"
  abort
end

# Custom header for authentication
class AuthHeader < SOAP::Header::SimpleHandler
  # the namespace for the header data
  NAMESPACE = 'http://4psa.com/HeaderData.xsd/3.5.0'
  # Authentication data
  ACCESS_TOKEN = ARGV[0]
  puts ACCESS_TOKEN

  #initializes an instance of this class
  def initialize()
    super(XSD::QName.new(NAMESPACE, 'userCredentials'))
  end

  #sets the user credentials with the authentication data
  def on_simple_outbound
    {"userCredentials" => {"accessToken" => ACCESS_TOKEN}}
  end
end

# We need a charging plan for the new account, so we make a request to
# fetch all the charging plans and then pick a random one from the response list.

driver = BillingInterface.new
driver.options['protocol.http.ssl_config.verify_mode'] = OpenSSL::SSL::VERIFY_NONE

# Add custom header
driver.headerhandler << AuthHeader.new

#the GetChargingPlans message
messagePart = GetChargingPlans.new

# Log for SystemAPI request and response
driver.wiredump_file_base = "log"

#send the SystemAPI message
chargingPlans = driver.getChargingPlans(messagePart)

# Get the id of a random charging plan
chargingPlanID = nil
if chargingPlans.chargingPlan != nil
	if chargingPlans.chargingPlan.length != 0
		randChargingPlan = chargingPlans.chargingPlan[rand(chargingPlans.chargingPlan.length)]
		if randChargingPlan.iD != nil
			chargingPlanID = randChargingPlan.iD
			if randChargingPlan.name != nil
				puts "Using charging plan " + randChargingPlan.name + "."
			else
				puts "Using charging plan with id " + chargingPlanID + "."
			end
		end
	end
end

driver = ServiceProviderInterface.new
driver.options['protocol.http.ssl_config.verify_mode'] = OpenSSL::SSL::VERIFY_NONE

# Add custom header
driver.headerhandler << AuthHeader.new

#the AddServiceProvider message
messagePart = AddServiceProvider.new

# Fill in ServiceProvider data
messagePart.name = 'SPRuby' + rand(1000).to_s
messagePart.login = 'SPRuby' + rand(1000).to_s
messagePart.firstName = 'FirstnameRuby' + rand(1000).to_s
messagePart.lastName = 'LastnameRuby' + rand(1000).to_s
messagePart.email = 'Email' + rand(1000).to_s + '@example.com'
messagePart.password = SecureRandom.hex(16)
messagePart.country = 'us'
messagePart.company = 'test_company'
if chargingPlanID != nil
	messagePart.chargingPlanID = chargingPlanID
end

# Log for SystemAPI request and response
driver.wiredump_file_base = "log"

#send the SystemAPI message
begin
	driver.addServiceProvider(messagePart)
	puts "Service provider created successfully."
rescue Exception => ex
	# Catch exception, for situations when the service provider could not be added
	puts "Error: " + ex.message
end
