#!/bin/sh

set -e

# Set the endpoint URL
URL="https://www.cbr.ru/scripts/XML_daily.asp?date_req=$1"

# Set the Content-Type header
CONTENT_TYPE="Content-Type: text/xml; charset=utf-8"

# Send the SOAP request using curl and capture the HTTP status code and response body
HTTP_STATUS=$(curl -s -w "%{http_code}" -X GET \
    -H "$CONTENT_TYPE" \
    "$URL")

# Extract the HTTP status code
STATUS_CODE=$(echo "$HTTP_STATUS" | tail -c 4)

# If the status code is 200, print the response body in JSON, YAML, XML or HTML format
if [ "$STATUS_CODE" -eq 200 ]; then
  case "$2" in 
    "json")
      echo "$HTTP_STATUS" | head -c -4 | yq --xml-attribute-prefix + -p=xml -r ".ValCurs.Valute" -o=json
      ;;
    "xml")
      echo "$HTTP_STATUS" | head -c -4
      ;;
    *)
      exit 1
  esac    
else
    exit 1
fi
