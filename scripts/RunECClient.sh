#!/bin/bash

LIB_DIR=lib

if [ $# -eq 2 ]; then
    HOST=$1
    PORT=$2
else 
   echo "USAGE: $0 HOST PORT"
   exit 1
fi


# Apache XMLRPC Server
cpath="$LIB_DIR/xmlrpc-client-3.1.2.jar"
cpath="$cpath:$LIB_DIR/xmlrpc-common-3.1.2.jar"
cpath="$cpath:$LIB_DIR/xmlrpc-server-3.1.2.jar"
cpath="$cpath:$LIB_DIR/org-apache-commons-logging.jar"
cpath="$cpath:$LIB_DIR/org.apache.commons.httpclient.jar"
cpath="$cpath:$LIB_DIR/apache-commons-codec-1.4.jar"
cpath="$cpath:$LIB_DIR/apache-commons.jar"
cpath="$cpath:$LIB_DIR/ws-commons-util-1.0.2.jar"
cpath="$cpath:$LIB_DIR/commons-logging-1.1.1.jar"
cpath="$cpath:$LIB_DIR/commons-httpclient-3.1.jar"
cpath="$cpath:$LIB_DIR/commons-codec-1.3.jar"


# Ashwin's Entity Comparison Metric
cpath="$cpath:$LIB_DIR/java-json.jar"
cpath="$cpath:$LIB_DIR/secondstring.jar"
cpath="$cpath:$LIB_DIR/entitycomparison.jar"
#cpath="$cpath:$LIB_DIR/SecondString.jar"
#cpath="$cpath:$LIB_DIR/EntityComparisonXmlrpc.jar"

java -cp $cpath:$CLASSPATH edu.illinois.cs.cogcomp.entitySimilarity.xmlrpc.ECClient $HOST $PORT
