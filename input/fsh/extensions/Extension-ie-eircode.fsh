Extension: IEEircode
Id: ie-eircode
Title: "Eircode"
Description: "The Eircode routing key and unique identifier for an Irish address, as issued by Eircode Ltd / An Post. No existing HL7 Europe or IPS extension covers this, so it is authored nationally per Governance Rule 3 (local identifiers) after confirming (Rule 7) that no reusable European extension exists."
Context: Address
* value[x] only string
* valueString 1..1
* valueString ^short = "7-character Eircode (3-character routing key + 4-character unique identifier), e.g. D02AF30"
* valueString obeys ie-eircode-format
