=begin
4PSA VoipNow SystemAPI Client for Ruby

Copyright (c) 2012, Rack-Soft (www.4psa.com). All rights reserved.
VoipNow is a Trademark of Rack-Soft, Inc
4PSA is a Registered Trademark of Rack-Soft, Inc.
All rights reserved.

This script adds an extension.
=end
require 'rubygems'
require 'securerandom'
gem 'soap4r'
require 'VoIpNowServiceDriver.rb'
require 'soap/header/simplehandler'

# Custom header for authentication
class AuthHeader < SOAP::Header::SimpleHandler
  # the namespace for the header data
  NAMESPACE = 'http://4psa.com/HeaderData.xsd/3.0.0'
  # authentication data
  ACCESS_TOKEN = 'CHANGEME'

  #initializes an instance of this class
  def initialize()
    super(XSD::QName.new(NAMESPACE, 'userCredentials'))
  end

  #sets the user credentials with the authentication data
  def on_simple_outbound
    {"userCredentials" => {"accessToken" => ACCESS_TOKEN}}
  end
end

# We need a parent user for the new extension, so we make a request to
# fetch all the users.

driver = UserInterface.new
driver.options['protocol.http.ssl_config.verify_mode'] = OpenSSL::SSL::VERIFY_NONE

# Add custom header
driver.headerhandler << AuthHeader.new

#the getUsers message
messagePart = GetUsers.new

# Log for SystemAPI request and response
driver.wiredump_file_base = "log"

#send the SystemAPI message
users = driver.getUsers(messagePart)
userID = nil
if users.user != nil
	if users.user.length != 0
		randUser = users.user[rand(users.user.length)]
		if randUser.iD != nil
			userID = randUser.iD
			if randUser.name != nil
				puts "Using parent user " + randUser.name + "."
			else
				puts "Using parent user with id " + userID + "."
			end
		end
	end
end

if userID == nil
	puts "No users found on the server. Can not add an extension."
	exit
end

driver = ExtensionInterface.new
driver.options['protocol.http.ssl_config.verify_mode'] = OpenSSL::SSL::VERIFY_NONE

# Add custom header
driver.headerhandler << AuthHeader.new

#the AddExtension message
messagePart = AddExtension.new
# Fill in Extension data
messagePart.label = 'ExtensionRuby' + rand(1000).to_s
messagePart.password = SecureRandom.hex(16)
messagePart.parentID = userID

# Log for SystemAPI request and response
driver.wiredump_file_base = "log"

#send the SystemAPI message
begin
	driver.addExtension(messagePart)
	puts "Extension created successfully."
rescue Exception => ex
	# Catch exception, for situations when the extension could not be added
	puts "Error: " + ex.message
end