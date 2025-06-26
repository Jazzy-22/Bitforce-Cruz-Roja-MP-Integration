@IsTest
public with sharing class MercadoPagoSyncBatchTest {
    
    @IsTest
    static private void testBatch(){
        List<String> payments = new List<String>{'123'};
        String processName = 'Test Context';
        String endpoint= 'alternative';

        Test.startTest();
        MercadoPagoSyncBatch b = new MercadoPagoSyncBatch(payments, processName, endpoint);
        ID batchprocessid = Database.executeBatch(b);
        Test.stopTest();

        List<BitForce_Status_Log__c> logs = [SELECT Id FROM BitForce_Status_Log__c];

        System.assertEquals(1, logs.size());
    }
}