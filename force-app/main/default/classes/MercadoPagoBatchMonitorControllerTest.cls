@IsTest
public with sharing class MercadoPagoBatchMonitorControllerTest {
    
    @IsTest
    static private void testGetRecords() {
        insert new BitForce_Status_Log__c(Endpoint__c = 'alternative', MP_Payment_Id__c = '123', Status__c = 'Done');

        List<BitForce_Status_Log__c> recs = MercadoPagoBatchMonitorController.GetRecords();

        System.assertEquals(1, recs.size());
    }
}