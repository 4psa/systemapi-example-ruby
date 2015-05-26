#!/bin/bash

if [ $# != 2 ]; then
	echo "You should run this script like this:"
	echo "./wsdl2ruby.sh <PATH_TO_SCHEMA> <IP_ADDRESS>"
	exit 1
fi

# Variables
schemaFolder=$1
ipAddress=$2
tempFileName="voipnowservicetemp.wsdl"
ports=( Account ServiceProvider Organization User Extension Channel PBX Billing Report GlobalOp )
namespaces=( account serviceProvider organization user extension channel pbx billing report globalop )
agents=( account sp organization user extension channel pbx billing report globalop )
serviceTemplate="<service name=\"{port}Port\"><port name=\"{port}Port\" binding=\"{namespace}:{port}\"><soap:address location=\"https://$ipAddress/soap2/{agent}_agent.php\"/></port></service>"

# Create the temporary wsdl file
echo ""Creating $tempFileName...""
cat $schemaFolder/voipnowservice.wsdl > $schemaFolder/$tempFileName
echo ""$tempFileName created.""

# Remove the ending </definitions> tag from the temporary file
sed '/\/definitions/d' $schemaFolder/voipnowservice.wsdl > $schemaFolder/$tempFileName

# Generate the <service> tags for each module
for i in {0..9}
do
	service=${serviceTemplate//\{namespace\}/${namespaces[i]}}
	service=${service//\{port\}/${ports[i]}}
	service=${service//\{agent\}/${agents[i]}}
	echo $service >> $schemaFolder/$tempFileName
done

# Add back the ending </definitions> tag to the temporary file
echo "</definitions>" >> $schemaFolder/$tempFileName

# Run the wsdl2ruby.rb script
echo "Generate the ruby scripts..."
wsdl2ruby.rb --wsdl $schemaFolder/$tempFileName --type client
echo "Ruby scripts generated."

# Remove the temporary wsdl file
echo ""Removing $tempFileName...""
rm $schemaFolder/$tempFileName
echo ""$tempFileName removed.""

# Write success message
echo "SUCCESS! You can now run your Ruby scripts with VoipNow!"
