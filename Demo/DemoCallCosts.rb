=begin
4PSA VoipNow SystemAPI Client for Ruby

Copyright (c) 2012, Rack-Soft (www.4psa.com). All rights reserved.
VoipNow is a Trademark of Rack-Soft, Inc
4PSA is a Registered Trademark of Rack-Soft, Inc.
All rights reserved.

This script fetches the call costs of an extension.
=end
require 'rubygems'
require 'securerandom'
gem 'soap4r'
require 'VoIpNowServiceDriver.rb'
require 'soap/header/simplehandler'

if ARGV.length != 1
	puts "Usage: ruby <ruby_file.rb> \"<access_token>\"\n"
	puts "example: ruby DemoCallCosts.rb \"1|V_pmPvEm25-HrqAzERx_nvJbBvNs~q3F|1|v-gntT4GFH-UCUX0EM2_r9XTVDtw~qCF\"\n"
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

# We need an extension to check its call costs, so we make a request to
# fetch all the extensions.

driver = ExtensionInterface.new
driver.options['protocol.http.ssl_config.verify_mode'] = OpenSSL::SSL::VERIFY_NONE

# Add custom header
driver.headerhandler << AuthHeader.new

#the getExtensions message
messagePart = GetExtensions.new

# Log for SystemAPI request and response
driver.wiredump_file_base = "log"

#send the SystemAPI message
extensions = driver.getExtensions(messagePart)
extensionIdentifier = nil
if extensions.extension != nil
	if extensions.extension.length != 0
		randExtension = extensions.extension[rand(extensions.extension.length)]
		if randExtension.identifier != nil
			extensionIdentifier = randExtension.identifier
			if randExtension.name != nil
				puts "Fetching call costs for extension " + randExtension.name + "."
			else
				puts "Fetching call costs for extension with identifier " + extensionIdentifier + "."
			end
		end
	end
end

if extensionIdentifier == nil
	puts "No extensions found on the server. Can not make the call costs request."
	exit
end

driver = ReportInterface.new
driver.options['protocol.http.ssl_config.verify_mode'] = OpenSSL::SSL::VERIFY_NONE

# Add custom header
driver.headerhandler << AuthHeader.new

#the CallCosts message
messagePart = CallCosts.new
# Fill in Request data
messagePart.userIdentifier = extensionIdentifier
interval = Interval.new
interval.startDate = "2012-01-01"
interval.endDate = DateTime.now.strftime('%Y-%m-%d')
messagePart.interval = interval

# Log for SystemAPI request and response
driver.wiredump_file_base = "log"

#send the SystemAPI message
begin
	callCosts = driver.callCosts(messagePart)
	puts callCosts.totalCalls + " calls have been made between " + interval.startDate + " and " + interval.endDate + " with a total cost of " + callCosts.cost + " " + callCosts.currency
rescue Exception => ex
	# Catch exception, for situations when the call costs could not be fetched
	puts "Error: " + ex.message
end
