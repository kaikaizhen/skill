# Requirement — Unit Converter Endpoint

Build a small HTTP service with one endpoint.

`GET /convert?value=<number>&from=<unit>&to=<unit>`

Supported units: `celsius`, `fahrenheit`, `kelvin`.

Behaviour:

- Returns the converted value as JSON: `{ "value": <number>, "unit": "<to>" }`
- Rounds the result to two decimal places.
- Unsupported unit ⇒ HTTP 400 with `{ "error": "unsupported unit" }`
- Non-numeric `value` ⇒ HTTP 400 with `{ "error": "invalid value" }`
- Below absolute zero (0 K) after conversion of the input to kelvin ⇒ HTTP 400
  with `{ "error": "below absolute zero" }`

Nothing is stored. There are no users, no authentication, and no UI.

Language and framework: your choice; keep it to one small service that can be
run and tested locally.
