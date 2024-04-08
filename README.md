# CBR API

The CBR API provides data from The Central Bank of the Russian Federation (https://cbr.ru) in XML, JSON, and HTML formats.

## Available Requests

* `/api/cbr/fin_org/get_full_info`
  
Description: Provides full information about a financial organization by its INN or OGRN.

Response Formats: HTML, JSON, XML

* `/api/cbr/currency/get_daily_rates`

Description: Provides daily currency rates from the Central Bank of Russia.

Response Formats: HTML, JSON, XML

## Usage

### Get Full Information about a Financial Organization

#### Request

`GET /api/cbr/fin_org/get_full_info?type={type}&data={data}&output={output}`

- `type`: Type of identifier (inn, ogrn)
- `data`: Identifier value
- `output`: Desired output format (html, json, xml)

#### Response

The response will contain the full information about the specified financial organization in the requested format.

### Get Daily Currency Rates

#### Request

`GET /api/cbr/currency/get_daily_rates?date={date}&output={output}`

- `date`: Date for which you want to retrieve currency rates (DD/MM/YYYY)
- `output`: Desired output format (html, json, xml)

#### Response

The response will contain the daily currency rates from the Central Bank of Russia for the specified date in the requested format.

# Screenshots

<details>
  <summary>Click to reveal screenshots</summary>
  
  ![Screenshot 1](https://raw.githubusercontent.com/andrewfromtver/cbr-api/main/docs/screenshot-1.png)
  ![Screenshot 2](https://raw.githubusercontent.com/andrewfromtver/cbr-api/main/docs/screenshot-2.png)
  ![Screenshot 3](https://raw.githubusercontent.com/andrewfromtver/cbr-api/main/docs/screenshot-3.png)
  ![Screenshot 4](https://raw.githubusercontent.com/andrewfromtver/cbr-api/main/docs/screenshot-4.png)
  
</details>
