public without sharing class MercadoPagoBatchMonitorController {
    
    @AuraEnabled
    public static List<BitForce_Status_Log__c> GetRecords(){
        return [SELECT Id, Name, CreatedDate, CreatedById, LastModifiedDate, LastModifiedById, Status__c, MP_Payment_Id__c, Payment__c, Payment__r.Name, Endpoint__c, Status_Details__c FROM BitForce_Status_Log__c];
    }

}