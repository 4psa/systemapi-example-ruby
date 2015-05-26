4PSA VoipNow SystemAPI Client for Ruby
version 2.0
=====================================

Disclaimer
==========

	This demonstrative code SHOULD NOT be used in production. It is designed to show how a client application can interact with the 4PSA VoipNow SystemAPI. Therefore there are no validations and the error checking is relaxed, in order to demonstrate the most common mistakes.


Requirements and setup
======================
	1. gcc (only for Linux, since Ruby for Windows comes with an installer): gcc should come with your operating system, otherwise simply run:
		yum install gcc
			or
		apt-get install gcc

	depending on your Linux distribution.

	2. Ruby 1.8.6 or later (for Linux) and 1.8.7 or later (for Windows). You can download it from here:
	 Linux:   ftp://ftp.ruby-lang.org/pub/ruby/1.8/ruby-1.8.6.tar.gz
	 Windows: rubyforge.org/frs/download.php/76277/rubyinstaller-1.8.7-p370.exe
	 
	Note: It seems that Ruby 1.8.6 for Windows is not fully compatible with SOAP4R and throws some errors when running with our demo scripts. You may try it, but it's recommended that you use the installer specified above. In our demo, we used Ruby 1.8.6 for Linux and Ruby 1.8.7 for Windows.

	  On Linux, after download, you should extract the archive to a temporary folder, go to that folder and run:
		./configure
		make
		make install
	  On Windows, just run the installer. You should check in the options to associate .rb files with Ruby and add Ruby to PATH.

	3. You need rubygems in order to install SOAP4R. If rubygems was not installed with ruby, you can download it from here: http://rubyforge.org/frs/download.php/70696/rubygems-1.3.7.tgz. After downloading, extract the contents of the archive to a temporary folder, go to that folder and run:

		ruby setup.rb
	  
	4. SOAP4R - a Ruby library for accessing Web Services via SOAP. Here is the command line to install soap4r:
	   
	   gem install soap4r --include-dependencies
	   
	   Note: Although latest versions of Ruby come with SOAP4R in their standard library, it is highly recommended using the latest gem.

	5. Create a directory on your local disk and put inside it the 4PSA VoipNow schemas (for example, C:\schema or /home/your_user/schema).

	6. Run the following commands:

	   1. On Linux:
			cd /home/your_user/schema
			./wsdl2ruby.sh . <IP_ADDRESS>

	   For example:
			./wsdl2ruby.sh . voipnow2demo.4psa.com

	   2. On Windows:
			cd C:\schema
			wsdl2ruby.bat . <IP_ADDRESS>

	   For example:
			wsdl2ruby.bat . voipnow2demo.4psa.com

	   These utilities will generate four files: 
			- VoipNowService.rb 
			- VoipNowServiceMappingRegistry.rb 
			- AccountPortClient.rb 
			- VoipNowServiceDriver.rb
	   
	   The main class used by your client program is VoipNowServiceDriver.rb. 

	7. Now you can start writting your applications for your VoipNow server.


Examples
========

	You have some already made Ruby applications:

	1. DemoAddServiceProvider.rb : script that adds a new service provider to your VoipNow server.
	2. DemoAddOrganization.rb : script that adds a new organization to your VoipNow server.
	3. DemoAddUser.rb : script that adds a new user to your VoipNow server.
	4. DemoAddExtension.rb : script that adds a new extension to your VoipNow server.
	5. DemoCallCosts.rb : script that checks the call costs of an extension from your VoipNow server.


Copyrights
==========

4PSA VoipNow - SystemAPI Client for Ruby
Copyright (C) 2012 Rack-Soft, LLC
VoipNow is a Trademark of Rack-Soft, LLC
4PSA is a Registered Trademark of Rack-Soft, LLC

This program is free software; you can redistribute it and/or
modify it under the terms of the GNU General Public License
as published by the Free Software Foundation; either version 2
of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program; if not, write to the Free Software
Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.