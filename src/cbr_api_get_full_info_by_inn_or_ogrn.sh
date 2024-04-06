#!/bin/sh

set -e

# Set api query type
case "$1" in 
  "ogrn")
    QUERY_TYPE="GetFullInfoByOGRN"
    ;;
  "inn")
    QUERY_TYPE="GetFullInfoByINN"
    ;;
  *)
    exit 1
esac

# Set the SOAP request XML content
SOAP_REQUEST=$(cat <<EOF
<?xml version="1.0" encoding="utf-8"?>
<soap12:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soap12="http://www.w3.org/2003/05/soap-envelope">
  <soap12:Body>
    <$QUERY_TYPE xmlns="http://web.cbr.ru/">
      <INN>$2</INN>
    </$QUERY_TYPE>
  </soap12:Body>
</soap12:Envelope>
EOF
)

# Set the endpoint URL
URL="https://www.cbr.ru/FO_ZoomWS/FinOrg.asmx"

# Set the Content-Type header
CONTENT_TYPE="Content-Type: text/xml; charset=utf-8"

# Set the SOAPAction header
SOAP_ACTION="SOAPAction: \"http://web.cbr.ru/$QUERY_TYPE\""

# Send the SOAP request using curl and capture the HTTP status code and response body
HTTP_STATUS=$(curl -s -w "%{http_code}" -X POST \
    -H "$CONTENT_TYPE" \
    -H "$SOAP_ACTION" \
    --data "$SOAP_REQUEST" \
    "$URL")

# Extract the HTTP status code
STATUS_CODE=$(echo "$HTTP_STATUS" | tail -c 4)

# If the status code is 200, print the response body in JSON, YAML, XML or HTML format
if [ "$STATUS_CODE" -eq 200 ]; then
  case "$3" in 
    "json")
      echo "$HTTP_STATUS" | head -c -4 | xmlstarlet fo --omit-decl | yq --xml-attribute-prefix + -p=xml -o=json
      ;;
    "yaml")
      echo "$HTTP_STATUS" | head -c -4 | xmlstarlet fo --omit-decl | yq --xml-attribute-prefix + -p=xml -o=yaml
      ;;
    "xml")
      echo "$HTTP_STATUS" | head -c -4 | xmlstarlet fo --omit-decl
      ;;
    "html")
      DATA=$(echo "$HTTP_STATUS" | head -c -4 | xmlstarlet fo --omit-decl | yq --xml-attribute-prefix + -p=xml -o=json)
      NAME=$(echo "$DATA" | yq -r ".Envelope.Body.${QUERY_TYPE}Response.${QUERY_TYPE}Result.Name")
      SHORT_NAME=$(echo "$DATA" | yq -r ".Envelope.Body.${QUERY_TYPE}Response.${QUERY_TYPE}Result.ShortName")
      ADDRESS=$(echo "$DATA" | yq -r ".Envelope.Body.${QUERY_TYPE}Response.${QUERY_TYPE}Result.Address")
      EMAIL=$(echo "$DATA" | yq -r ".Envelope.Body.${QUERY_TYPE}Response.${QUERY_TYPE}Result.Email")
      PHONE=$(echo "$DATA" | yq -r ".Envelope.Body.${QUERY_TYPE}Response.${QUERY_TYPE}Result.Phones")
      OGRN=$(echo "$DATA" | yq -r ".Envelope.Body.${QUERY_TYPE}Response.${QUERY_TYPE}Result.OGRN")
      INN=$(echo "$DATA" | yq -r ".Envelope.Body.${QUERY_TYPE}Response.${QUERY_TYPE}Result.INN")
      BIC=$(echo "$DATA" | yq -r ".Envelope.Body.${QUERY_TYPE}Response.${QUERY_TYPE}Result.BIC")
      cat ./card.html | \
        sed "s/%NAME%/${NAME}/g" | \
        sed "s/%SHORT_NAME%/${SHORT_NAME}/g" | \
        sed "s/%ADDRESS%/${ADDRESS}/g" | \
        sed "s/%EMAIL%/${EMAIL}/g" | \
        sed "s/%PHONE%/${PHONE}/g" | \
        sed "s/%OGRN%/${OGRN}/g" | \
        sed "s/%INN%/${INN}/g" | \
        sed "s/%BIC%/${BIC}/g"
      ;;
    *)
      exit 1
  esac    
else
    exit 1
fi
