public class MercadoPagoSyncBatch implements Database.Batchable<BitForce_Status_Log__c>, Database.AllowsCallouts{

    private final List<BitForce_Status_Log__c> records;

    public MercadoPagoSyncBatch(List<String> payments, String processName, String endpoint) {
        List<BitForce_Status_Log__c> recs = new List<BitForce_Status_Log__c>();

        for(String p : payments)
            recs.add(new BitForce_Status_Log__c(
                Name = processName,
                Status__c = 'Queued',
                MP_Payment_Id__c = p,
                Endpoint__c = endpoint
            ));

        insert recs;

        this.records = recs;
    }

    public List<BitForce_Status_Log__c> start(DataBase.BatchableContext bc){
        return records;
    }

    public void execute(Database.BatchableContext bc, List<BitForce_Status_Log__c> records){
        BitForce_Status_Log__c rec = records[0];

        try{
            Boolean processed = MercadoPagoNotificationHandler.HandleNotification(rec.MP_Payment_Id__c, 'payment', rec.Endpoint__c);

            if(processed){
                rec.Status__c = 'Done - Success';
            } else{
                rec.Status__c = 'Done - Failed';
            }

            List<MP_Payment__c> payments = [SELECT Id FROM MP_Payment__c WHERE Name = :rec.MP_Payment_Id__c];

            if(payments.size() > 0)
                rec.Payment__c = payments[0].Id;
            else
                rec.Status_Details__c = 'Done - Check Notification Log';

        } catch(Exception ex){
            rec.Status__c = 'Error';
            rec.Status_Details__c = ex.getMessage() + ' - ' + ex.getStackTraceString();
        }

        update rec;
    }

    public void finish(Database.BatchableContext bc){
        System.debug('done');
    }
}