#!/bin/sh

set -e

# Ensure required parameters are provided
if [ -z "$1" ]; then
  echo "Usage: $0 <Name> [Addr] [output_format]"
  exit 1
fi

# Assign input parameters
NAME="$1"
OUTPUT_FORMAT="${2:-json}"

# Set the SOAP request XML content
SOAP_REQUEST=$(cat <<EOF
<?xml version="1.0" encoding="utf-8"?>
<soap:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" 
  xmlns:xsd="http://www.w3.org/2001/XMLSchema" 
  xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/"
>
  <soap:Body>
    <Search xmlns="http://web.cbr.ru/">
      <Name>${NAME}</Name>
      <Addr></Addr>
      <Status>Active</Status>
      <FoType></FoType>
      <VidID>53</VidID>
      <OKATO>-1</OKATO>
      <page>0</page>
    </Search>
  </soap:Body>
</soap:Envelope>
EOF
)

# Set the endpoint URL
URL="https://www.cbr.ru/FO_ZoomWS/FinOrg.asmx"

# Set the Content-Type header
CONTENT_TYPE="Content-Type: text/xml; charset=utf-8"

# Set the SOAPAction header
SOAP_ACTION="SOAPAction: \"http://web.cbr.ru/Search\""

# Send the SOAP request using curl and capture the HTTP status code and response body
HTTP_STATUS=$(curl -s -w "%{http_code}" -X POST \
    -H "$CONTENT_TYPE" \
    -H "$SOAP_ACTION" \
    --data "$SOAP_REQUEST" \
    "$URL")

# Extract the HTTP status code
STATUS_CODE=$(echo "$HTTP_STATUS" | tail -c 4)

# If the status code is 200, process the response
if [ "$STATUS_CODE" -eq 200 ]; then
  RESPONSE_BODY=$(echo "$HTTP_STATUS" | head -c -4)
  case "$OUTPUT_FORMAT" in 
    "json")
      echo "$RESPONSE_BODY" | yq --xml-attribute-prefix + -p=xml -o=json | yq '.Envelope.Body.SearchResponse.SearchResult.DS.Record'
      ;;
    "xml")
      echo "$RESPONSE_BODY"
      ;;
    *)
      echo "Invalid output format: $OUTPUT_FORMAT" >&2
      exit 1
  esac
else
  echo "Request failed with status code $STATUS_CODE" >&2
  exit 1
fi
