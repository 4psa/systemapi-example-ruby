=begin
4PSA VoipNow SystemAPI Client for Ruby

Copyright (c) 2012, Rack-Soft (www.4psa.com). All rights reserved.
VoipNow is a Trademark of Rack-Soft, Inc
4PSA is a Registered Trademark of Rack-Soft, Inc.
All rights reserved.

This script adds an organization.
=end
require 'rubygems'
require 'securerandom'
gem 'soap4r'
require 'VoIpNowServiceDriver.rb'
require 'soap/header/simplehandler'

if ARGV.length != 1
  puts "Usage: ruby <ruby_file.rb> \"<access_token>\"\n"
  puts "example: ruby DemoAddOrganization.rb \"1|V_pmPvEm25-HrqAzERx_nvJbBvNs~q3F|1|v-gntT4GFH-UCUX0EM2_r9XTVDtw~qCF\"\n"
  abort
end

# Custom header for authentication
class AuthHeader < SOAP::Header::SimpleHandler
  # the namespace for the header data
  NAMESPACE = 'http://4psa.com/HeaderData.xsd/3.5.0'
  # authentication data
  ACCESS_TOKEN = ARGV[0]

  #initializes an instance of this class
  def initialize()
    super(XSD::QName.new(NAMESPACE, 'userCredentials'))
  end

  #sets the user credentials with the authentication data
  def on_simple_outbound
    {"userCredentials" => {"accessToken" => ACCESS_TOKEN}}
  end
end

# We need a parent service provider for the new organization, so we make a request to
# fetch all the service providers.

driver = ServiceProviderInterface.new
driver.options['protocol.http.ssl_config.verify_mode'] = OpenSSL::SSL::VERIFY_NONE

# Add custom header
driver.headerhandler << AuthHeader.new

#the getServiceProviders message
messagePart = GetServiceProviders.new

# Log for SystemAPI request and response
driver.wiredump_file_base = "log"

#send the SystemAPI message
serviceProviders = driver.getServiceProviders(messagePart)
serviceProviderID = nil
if serviceProviders.serviceProvider != nil
	if serviceProviders.serviceProvider.length != 0
		randServiceProvider = serviceProviders.serviceProvider[rand(serviceProviders.serviceProvider.length)]
		if randServiceProvider.iD != nil
			serviceProviderID = randServiceProvider.iD
			if randServiceProvider.name != nil
				puts "Using parent service provider " + randServiceProvider.name + "."
			else
				puts "Using parent service provider with id " + serviceProviderID + "."
			end
		end
	end
end

if serviceProviderID == nil
	puts "No service providers found on the server. Can not add an organization."
	exit
end

# We need a charging plan for the new account, so we make a request to
# fetch all the charging plans and then pick a random one from the response list.

driver = BillingInterface.new
driver.options['protocol.http.ssl_config.verify_mode'] = OpenSSL::SSL::VERIFY_NONE

# Add custom header
driver.headerhandler << AuthHeader.new

#the GetChargingPlans message
messagePart = GetChargingPlans.new

# Fill in request data
messagePart.userID = serviceProviderID

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

driver = OrganizationInterface.new
driver.options['protocol.http.ssl_config.verify_mode'] = OpenSSL::SSL::VERIFY_NONE

# Add custom header
driver.headerhandler << AuthHeader.new

#the AddOrganization message
messagePart = AddOrganization.new

# Fill in Organization data
messagePart.name = 'OrgRuby' + rand(1000).to_s
messagePart.login = 'OrgRuby' + rand(1000).to_s
messagePart.firstName = 'FirstnameRuby' + rand(1000).to_s
messagePart.lastName = 'LastnameRuby' + rand(1000).to_s
messagePart.email = 'Email' + rand(1000).to_s + '@example.com'
messagePart.password = SecureRandom.hex(16)
messagePart.country = 'us'
messagePart.company = 'test_company'
messagePart.parentID = serviceProviderID
if chargingPlanID != nil
	messagePart.chargingPlanID = chargingPlanID
end

# Log for SystemAPI request and response
driver.wiredump_file_base = "log"

#send the SystemAPI message
begin
	driver.addOrganization(messagePart)
	puts "Organization created successfully."
rescue Exception => ex
	# Catch exception, for situations when the organization could not be added
	puts "Error: " + ex.message
end
