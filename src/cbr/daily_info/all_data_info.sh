#!/bin/sh

set -e

# Output format (default: json)
OUTPUT_FORMAT="${1:-json}"

# SOAP request body
SOAP_REQUEST=$(cat <<EOF
<?xml version="1.0" encoding="utf-8"?>
<soap:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
  xmlns:xsd="http://www.w3.org/2001/XMLSchema"
  xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/"
>
  <soap:Body>
    <AllDataInfoXML xmlns="http://web.cbr.ru/" />
  </soap:Body>
</soap:Envelope>
EOF
)

# Endpoint URL
URL="https://www.cbr.ru/DailyInfoWebServ/DailyInfo.asmx"

# Headers
CONTENT_TYPE="Content-Type: text/xml; charset=utf-8"
SOAP_ACTION="SOAPAction: \"http://web.cbr.ru/AllDataInfoXML\""

# Send request
HTTP_STATUS=$(curl -s -w "%{http_code}" -X POST \
    -H "$CONTENT_TYPE" \
    -H "$SOAP_ACTION" \
    --data "$SOAP_REQUEST" \
    "$URL")

# Extract status code
STATUS_CODE=$(echo "$HTTP_STATUS" | tail -c 4)

# Process response
if [ "$STATUS_CODE" -eq 200 ]; then
  RESPONSE_BODY=$(echo "$HTTP_STATUS" | head -c -4)

  case "$OUTPUT_FORMAT" in
    "json")
      echo "$RESPONSE_BODY" \
        | yq --xml-attribute-prefix + -p=xml -o=json \
        | yq '.Envelope.Body.AllDataInfoXMLResponse.AllDataInfoXMLResult'
      ;;
    "xml")
      echo "$RESPONSE_BODY"
      ;;
    "html")
      DATA=$(echo "$RESPONSE_BODY" | yq -p=xml -o=json)
      ROOT=".Envelope.Body.AllDataInfoXMLResponse.AllDataInfoXMLResult.AllData"

      USD=$(echo "$DATA" | yq -r "$ROOT.MainIndicatorsVR.Currency.USD.curs")
      EUR=$(echo "$DATA" | yq -r "$ROOT.MainIndicatorsVR.Currency.EUR.curs")
      CNY=$(echo "$DATA" | yq -r "$ROOT.MainIndicatorsVR.Currency.CNY.curs")

      GOLD=$(echo "$DATA" | yq -r "$ROOT.MainIndicatorsVR.Metall.Золото.+@val")
      SILVER=$(echo "$DATA" | yq -r "$ROOT.MainIndicatorsVR.Metall.Серебро.+@val")
      PLAT=$(echo "$DATA" | yq -r "$ROOT.MainIndicatorsVR.Metall.Платина.+@val")
      PALL=$(echo "$DATA" | yq -r "$ROOT.MainIndicatorsVR.Metall.Палладий.+@val")

      INFLATION=$(echo "$DATA" | yq -r "$ROOT.MainIndicatorsVR.Inflation.+@val")
      KEY_RATE=$(echo "$DATA" | yq -r "$ROOT.KEY_RATE.+@val")
      RUONIA=$(echo "$DATA" | yq -r "$ROOT.MainIndicatorsVR.RUONIA.D1.+@val")

      MACRO=$(echo "$DATA" | yq -r "$ROOT.Macro.M_rez.+@val")

      cat ./cbr/daily_info/card.html | \
        sed "s/%USD%/${USD}/g" | \
        sed "s/%EUR%/${EUR}/g" | \
        sed "s/%CNY%/${CNY}/g" | \
        sed "s/%GOLD%/${GOLD}/g" | \
        sed "s/%SILVER%/${SILVER}/g" | \
        sed "s/%PLAT%/${PLAT}/g" | \
        sed "s/%PALL%/${PALL}/g" | \
        sed "s/%INFLATION%/${INFLATION}/g" | \
        sed "s/%KEY_RATE%/${KEY_RATE}/g" | \
        sed "s/%RUONIA%/${RUONIA}/g" | \
        sed "s/%MACRO%/${MACRO}/g"
        
      ;;
    *)
      echo "Invalid output format: $OUTPUT_FORMAT" >&2
      exit 1
      ;;
  esac
else
  echo "Request failed with status code $STATUS_CODE" >&2
  exit 1
fi
