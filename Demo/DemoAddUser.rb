=begin
4PSA VoipNow SystemAPI Client for Ruby

Copyright (c) 2012, Rack-Soft (www.4psa.com). All rights reserved.
VoipNow is a Trademark of Rack-Soft, Inc
4PSA is a Registered Trademark of Rack-Soft, Inc.
All rights reserved.

This script adds a user.
=end
require 'rubygems'
require 'securerandom'
gem 'soap4r'
require 'VoIpNowServiceDriver.rb'
require 'soap/header/simplehandler'

if ARGV.length != 1
  puts "Usage: ruby <ruby_file.rb> \"<access_token>\"\n"
  puts "example: ruby DemoAddUser.rb \"1|V_pmPvEm25-HrqAzERx_nvJbBvNs~q3F|1|v-gntT4GFH-UCUX0EM2_r9XTVDtw~qCF\"\n"
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

# We need a parent organization for the new user, so we make a request to
# fetch all the organizations.

driver = OrganizationInterface.new
driver.options['protocol.http.ssl_config.verify_mode'] = OpenSSL::SSL::VERIFY_NONE

# Add custom header
driver.headerhandler << AuthHeader.new

#the getOrganizations message
messagePart = GetOrganizations.new

# Log for SystemAPI request and response
driver.wiredump_file_base = "log"

#send the SystemAPI message
puts "aici"
puts messagePart
organizations = driver.getOrganizations(messagePart)
puts "dincoace"
organizationID = nil
if organizations.organization != nil
	if organizations.organization.length != 0
		randOrganization = organizations.organization[rand(organizations.organization.length)]
		if randOrganization.iD != nil
			organizationID = randOrganization.iD
			if randOrganization.name != nil
				puts "Using parent organization " + randOrganization.name + "."
			else
				puts "Using parent organization with id " + organizationID + "."
			end
		end
	end
end

if organizationID == nil
	puts "No organizations found on the server. Can not add a user."
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
messagePart.userID = organizationID

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

driver = UserInterface.new
driver.options['protocol.http.ssl_config.verify_mode'] = OpenSSL::SSL::VERIFY_NONE

# Add custom header
driver.headerhandler << AuthHeader.new

#the AddUser message
messagePart = AddUser.new
# Fill in User data
messagePart.name = 'UserRuby' + rand(1000).to_s
messagePart.login = 'UserRuby' + rand(1000).to_s
messagePart.firstName = 'FirstnameRuby' + rand(1000).to_s
messagePart.lastName = 'LastnameRuby' + rand(1000).to_s
messagePart.email = 'Email' + rand(1000).to_s + '@example.com'
messagePart.password = SecureRandom.hex(16)
messagePart.country = 'us'
messagePart.parentID = organizationID
if chargingPlanID != nil
	messagePart.chargingPlanID = chargingPlanID
end

# Log for SystemAPI request and response
driver.wiredump_file_base = "log"

#send the SystemAPI message
begin
	driver.addUser(messagePart)
	puts "User created successfully."
rescue Exception => ex
	# Catch exception, for situations when the user could not be added
	puts "Error: " + ex.message
end
