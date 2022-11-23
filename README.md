# Salesforce-Job-to-delete-records-older-than-X-months
Automation of dynamic record deleting. Ie: ensuring that all ErrorLog__c older than  3 months are deleted

1) setup the records in the custom metadata, Objects_to_Clean__mdt

2) Schedule UTIL_CleanObjectRecordsScheduleable (this uses Objects_to_Clean__mdt, and calls UTIL_CleanObjectRecords to delete records after a certain amount of months. 
A sumary of the delete records can be viewed in SummaryofObjectsCleaned__c (create a report this)
