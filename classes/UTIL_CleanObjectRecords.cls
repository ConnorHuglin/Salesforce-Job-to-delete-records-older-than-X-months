/*
* Connor Huglin 2022/11/23: Functionality to remove records older than 3 months
*/
global class UTIL_CleanObjectRecords implements Database.Batchable<sObject>, Database.Stateful {
    private Objects_to_Clean__mdt mdtObject;
    
    public UTIL_CleanObjectRecords(Objects_to_Clean__mdt param) {
        mdtObject = param;
    }
    
    global Database.QueryLocator start(Database.BatchableContext bc) {
		String query = 'SELECT Id, CreatedDate FROM ' + mdtObject.ObjectAPIName__c + ' WHERE CreatedDate < LAST_N_MONTHS:' + mdtObject.MonthsDataShouldGoBack__c;
        return Database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext bc, List<sObject> records){
        // process each batch of records
        try {
            SummaryofObjectsCleaned__c summaryOfRecords = new SummaryofObjectsCleaned__c();
            summaryOfRecords.ObjectAPIName__c = mdtObject.ObjectAPIName__c;
            summaryOfRecords.CountofRecordsDeleted__c = records.size();
            insert summaryOfRecords;
            
            delete records;
        } catch (Exception exc){
            System.debug('Something went wrong when trying to delete the records: ' + exc);
        }
    }    
    global void finish(Database.BatchableContext bc){
        // execute any post-processing operations
    }    
}