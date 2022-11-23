/*
* Connor Huglin 2022/11/23: https://dev.azure.com/infinitas/Converse/_boards/board/t/Order%20to%20Cash/Backlog%20items/?workitem=185828
* Functionality to remove records older than 3 months
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