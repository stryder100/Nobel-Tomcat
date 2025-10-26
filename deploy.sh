#!/bin/bash

# --- Configuration ---
APP_NAME="nobel_app"
TOMCAT_WEBAPPS_DIR="../tomcat9/webapps" # Adjust this relative path if necessary

# 1. Stop the server (safety first)
../tomcat9/bin/shutdown.sh 

# 2. Clean up old deployment (Crucial for fresh deploy)
echo "Cleaning old deployment directory: $TOMCAT_WEBAPPS_DIR/$APP_NAME"
rm -rf "$TOMCAT_WEBAPPS_DIR/$APP_NAME"

# 3. Create the new deployment directory
mkdir "$TOMCAT_WEBAPPS_DIR/$APP_NAME"

# 4. Copy ONLY the necessary files and directories, excluding .git
# The * dot glob doesn't include hidden files like .git
echo "Copying application files (excluding hidden files and binaries) to Tomcat..."

# Copy JSPs and other source files
cp -R * "$TOMCAT_WEBAPPS_DIR/$APP_NAME"

# 5. Copy the essential JDBC JAR file to the WEB-INF/lib for the app (T-209 was global, this is better)
echo "Copying JDBC connector to WEB-INF/lib"
mkdir -p "$TOMCAT_WEBAPPS_DIR/$APP_NAME/WEB-INF/lib"
cp lib/*.jar "$TOMCAT_WEBAPPS_DIR/$APP_NAME/WEB-INF/lib/"

echo "Deployment of $APP_NAME successful."

# 1. start the server (safety first)
../tomcat9/bin/startup.sh 
