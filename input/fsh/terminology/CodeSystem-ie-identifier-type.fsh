CodeSystem: IEIdentifierTypeCS
Id: hse-identifier-type
Title: "IE Identifier Type"
Description: "Type of health identifier."
* ^status = #draft
* ^caseSensitive = true
* #mrn "Medical record number" "Hospital or service medical record (chart) number."
* #pcrs "PCRS number" "Primary Care Reimbursement Service number on a medical card, GP visit card or Drug Payment Scheme card."
* #gp-record "GP record number"
* #ehic "European Health Insurance Card number"
* #nhs "NHS number" "NHS number (England and Wales)."
* #hcn "Health and Care number" "Health and Care number (Northern Ireland)"
* #foreign-insurance "Foreign national health insurance number" "e.g. the French NIR."
* #registry "Registry identifier" "An identifier assigned by a national registry or information system, e.g. the NCRI Patient Id."
* #other "Other identifier"