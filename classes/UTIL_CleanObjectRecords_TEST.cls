@isTest
public class UTIL_CleanObjectRecords_TEST {
    @testSetup
    public static void makeData(){
        ErrorLog__c errLog = new ErrorLog__c();
        errLog.ClassName__c = 'Test';
        errLog.ExceptionMessage__c = 'Test';
        errLog.ExceptionType__c = 'Test';
        errLog.MethodName__c = 'Test';
        errLog.RelatedToId__c = 'Test';
        insert errLog;
        
        Test.setCreatedDate(errLog.Id, Date.newInstance(2020, 01, 31));
    }
    
    public static testMethod void testUTIL_CleanObjectRecords(){
        test.startTest();
        UTIL_CleanObjectRecordsScheduleable ctrl = new UTIL_CleanObjectRecordsScheduleable();
        ctrl.execute(null);
        test.stoptest();
    }
}