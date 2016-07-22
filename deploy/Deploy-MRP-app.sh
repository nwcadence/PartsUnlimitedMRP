# Create deployment directory
mkdir /var/lib/partsunlimited

# Kill java to stop current website
pkill -9 'java'

# Remove old artifacts
rm -f /var/lib/partsunlimited/MongoRecords.js*
rm -f /var/lib/partsunlimited/mrp.war*
rm -f /var/lib/partsunlimited/ordering-service-0.1.0.jar*

# Copy files from deployment package
find ../ -iname '*.?ar' -exec cp -t /var/lib/partsunlimited {} +;
find . -iname 'MongoRecords.js' -exec cp -t /var/lib/partsunlimited {} +;

# Add the records to ordering database on MongoDB
mongo ordering /var/lib/partsunlimited/MongoRecords.js

# Change Tomcat listening port from 8080 to 9080
sed -i s/8080/9080/g /etc/tomcat7/server.xml

# Copy WAR file to Tomcat directory for auto-deployment
cp /var/lib/partsunlimited/mrp.war /var/lib/tomcat7/webapps

# Restart Tomcat
/etc/init.d/tomcat7 restart

# Run Ordering Service app
java -jar /var/lib/partsunlimited/ordering-service-0.1.0.jar &>/dev/null &

echo "MRP application successfully deployed. Go to http://$HOSTNAME.<azureregion>.cloudapp.azure.com:9080/mrp"