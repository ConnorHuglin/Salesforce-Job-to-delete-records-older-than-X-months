/*
* Connor Huglin 2022/11/23: Functionality to remove records older than 3 months
*/
global class UTIL_CleanObjectRecordsScheduleable Implements Schedulable {
    global void execute(SchedulableContext sc)
    {
        callJob();
    }

    public void callJob(){
        List<Objects_to_Clean__mdt> objectsToCleanMDT = Objects_to_Clean__mdt.getAll().values();
        
        for(Objects_to_Clean__mdt obj : objectsToCleanMDT){
            UTIL_CleanObjectRecords bc = new UTIL_CleanObjectRecords(obj);
            Id batchId = Database.executeBatch(bc);
        }
    }
}