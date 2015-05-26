@echo off

if "%1" == "" goto invalidParameters
if "%2" == "" goto invalidParameters

REM Variables
set schemaFolder=%1
set ipAddress=%2
set tempFileName=voipnowservicetemp.wsdl

REM Create the temporary wsdl file
echo Creating %tempFileName%...
copy %schemaFolder%\voipnowservice.wsdl %schemaFolder%\%tempFileName% > NUL
echo %tempFileName% created.

REM Remove the ending </definitions> tag from the temporary file
type %schemaFolder%\voipnowservice.wsdl | findstr /v ^</definitions^> > %schemaFolder%\%tempFileName%

REM Generate the <service> tags for each module
echo ^<service name="AccountPort"^>^<port name="AccountPort" binding="account:Account"^>^<soap:address location="https://%ipAddress%/soap2/account_agent.php"/^>^</port^>^</service^> >> %schemaFolder%\%tempFileName%
echo ^<service name="ServiceProviderPort"^>^<port name="ServiceProviderPort" binding="serviceProvider:ServiceProvider"^>^<soap:address location="https://%ipAddress%/soap2/sp_agent.php"/^>^</port^>^</service^> >> %schemaFolder%\%tempFileName%
echo ^<service name="OrganizationPort"^>^<port name="OrganizationPort" binding="organization:Organization"^>^<soap:address location="https://%ipAddress%/soap2/organization_agent.php"/^>^</port^>^</service^> >> %schemaFolder%\%tempFileName%
echo ^<service name="UserPort"^>^<port name="UserPort" binding="user:User"^>^<soap:address location="https://%ipAddress%/soap2/user_agent.php"/^>^</port^>^</service^> >> %schemaFolder%\%tempFileName%
echo ^<service name="ExtensionPort"^>^<port name="ExtensionPort" binding="extension:Extension"^>^<soap:address location="https://%ipAddress%/soap2/extension_agent.php"/^>^</port^>^</service^> >> %schemaFolder%\%tempFileName%
echo ^<service name="ChannelPort"^>^<port name="ChannelPort" binding="channel:Channel"^>^<soap:address location="https://%ipAddress%/soap2/channel_agent.php"/^>^</port^>^</service^> >> %schemaFolder%\%tempFileName%
echo ^<service name="PBXPort"^>^<port name="PBXPort" binding="pbx:PBX"^>^<soap:address location="https://%ipAddress%/soap2/pbx_agent.php"/^>^</port^>^</service^> >> %schemaFolder%\%tempFileName%
echo ^<service name="BillingPort"^>^<port name="BillingPort" binding="billing:Billing"^>^<soap:address location="https://%ipAddress%/soap2/billing_agent.php"/^>^</port^>^</service^> >> %schemaFolder%\%tempFileName%
echo ^<service name="ReportPort"^>^<port name="ReportPort" binding="report:Report"^>^<soap:address location="https://%ipAddress%/soap2/report_agent.php"/^>^</port^>^</service^> >> %schemaFolder%\%tempFileName%
echo ^<service name="GlobalOpPort"^>^<port name="GlobalOpPort" binding="globalop:GlobalOp"^>^<soap:address location="https://%ipAddress%/soap2/globalop_agent.php"/^>^</port^>^</service^> >> %schemaFolder%\%tempFileName%

REM Add back the ending </definitions> tag to the temporary file
echo ^</definitions^> >> %schemaFolder%/%tempFileName%

REM Run the wsdl2ruby.rb script
echo Generate the ruby scripts...
wsdl2ruby.rb --wsdl %schemaFolder%/%tempFileName% --type client
echo Ruby scripts generated.

REM Remove the temporary wsdl file
echo Removing "%tempFileName%"...
del %schemaFolder%\%tempFileName%
echo "%tempFileName%" removed.

REM Write success message
echo SUCCESS! You can now run your Ruby scripts with VoipNow!
goto end

:invalidParameters
echo You should run this script like this:
echo "wsdl2ruby.bat <PATH_TO_SCHEMA> <IP_ADDRESS>"
goto end

:end