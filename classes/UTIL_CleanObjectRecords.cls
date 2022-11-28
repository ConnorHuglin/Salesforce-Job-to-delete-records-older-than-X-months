/*
* Connor Huglin 2022/11/23
* Functionality to remove records older than 3 months
*/
global class UTIL_CleanObjectRecords implements Database.Batchable<sObject>, Database.Stateful {
    private Objects_to_Clean__mdt mdtObject;
    private sObjectType sObjType;
    
    public UTIL_CleanObjectRecords(Objects_to_Clean__mdt param) {
        mdtObject = param;
    }
    
    global Database.QueryLocator start(Database.BatchableContext bc) {
        List<String> accessibleFieldApiNames = new List<String>();
        
        sObjType = ((sObject) Type.forName(mdtObject.ObjectAPIName__c).newInstance()).getSObjectType();      
        
        for(Schema.SObjectField field : sObjType.getDescribe().fields.getMap().values()){
            Schema.DescribeFieldResult dfr = field.getDescribe();
            if(dfr.isAccessible()){
                accessibleFieldApiNames.add(dfr.getName());
            }
        }
        
        String dynamicQuery = 'SELECT {0} FROM {1} WHERE CreatedDate > LAST_N_MONTHS:' + mdtObject.MonthsDataShouldGoBack__c;
        
        return Database.getQueryLocator(String.format(dynamicQuery, new List<String>{String.join(accessibleFieldApiNames, ', '), mdtObject.ObjectAPIName__c}));
    }
    
    global void execute(Database.BatchableContext bc, List<sObject> records){
        // TODO: summarize records per week
        
        // process each batch of records
        try {            
            // create summary data
            Id summaryRecordId = createSummaryData(records);
            
            if(summaryRecordId != null){
                // create excel sheet as attachment and add it to the summary record
                String fileHeader = '';
                
                // create excel header dynamically
                for(Schema.SObjectField field : sObjType.getDescribe().fields.getMap().values()){
                    Schema.DescribeFieldResult dfr = field.getDescribe();
                    if(dfr.isAccessible()){
                        fileHeader += dfr.getName() + ',';
                    }
                }
                
                // set file header row
                fileHeader.removeEnd(',');
                fileHeader += ' \n';
                String finalStr = fileHeader;
                
                for(sObject obj : records){
                    String recordStr = ''; // new row per record
                    
                    // build each row in the excel sheet
                    for(Schema.SObjectField field : sObjType.getDescribe().fields.getMap().values()){
                        Schema.DescribeFieldResult dfr = field.getDescribe();
                        if(dfr.isAccessible()){
                            Object fieldValueObj = obj.get(dfr.getName());
                            
                            String fieldValueObjSerialized = String.valueOf(JSON.serialize(fieldValueObj));
                            
                            // remove commas due to the csv being comma separated
                            if(fieldValueObjSerialized.contains(',')){
                                fieldValueObjSerialized = fieldValueObjSerialized.replaceAll(',', ' --COMMA GOES HERE-- ');
                            }
                            
                            recordStr += fieldValueObjSerialized + ',';
                        }
                    }
                    
                    recordStr.removeEnd(',');
                    recordStr += ' \n';
                    finalStr += recordStr;
                }
                
                system.debug('finalStr: ' + finalStr);
                
                // set attachment attributes
                Blob csvBlob = Blob.valueOf(finalStr);
                Attachment att = new Attachment();
                att.ContentType = 'application/xml';
                att.ParentId = summaryRecordId;
                att.Body = csvBlob;
                att.Name = mdtObject.ObjectAPIName__c + '_' + DateTime.now() +'_.csv';
                insert att;
                system.debug('att: ' + att);
                
                delete records;
            } else {
                System.debug('Failed to create summary record');
            }
        } catch (Exception exc){
            System.debug('Something went wrong when trying to delete the records: ' + exc);
        }
    } 
    
    private Id createSummaryData(List<sObject> records){
        // create summary record
        SummaryofObjectsCleaned__c summaryOfRecord = new SummaryofObjectsCleaned__c();
        summaryOfRecord.ObjectAPIName__c = mdtObject.ObjectAPIName__c;
        summaryOfRecord.CountofRecordsDeleted__c = records.size();
        insert summaryOfRecord;
        
        return summaryOfRecord.Id;
    }
    
    global void finish(Database.BatchableContext bc){
        // execute any post-processing operations
    }    
}