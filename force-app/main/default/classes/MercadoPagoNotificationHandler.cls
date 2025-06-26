global without sharing class MercadoPagoNotificationHandler {
    
    public static boolean HandleNotification(String payment_id, String topic, String endpoint) {
        try {
            switch on topic {
                when 'payment' {
                    Map<String, Object> mercadoPagoFlowParams = new Map<String, Object>();
                    mercadoPagoFlowParams.put('Payment_Id', payment_id);
                    mercadoPagoFlowParams.put('Endpoint', endpoint);
                    
                    Flow.Interview.MercadoPago_Data_Retrieval myFlow = new Flow.Interview.MercadoPago_Data_Retrieval(mercadoPagoFlowParams);
                    myFlow.start();
                }
                when else {
                    MP_Notification_Log__c log = new MP_Notification_Log__c();
                    log.Name = endpoint + ' ' + payment_id;
                    log.Type__c = 'Info';
                    log.Origin__c = 'MercadoPagoNotificationHandler';
                    log.Description__c = 'Topic: ' + topic;
                    insert log;
                }
            }            
        } catch(Exception ex) {
            MP_Notification_Log__c log = new MP_Notification_Log__c();
            log.Name = endpoint + ' ' + payment_id;
            log.Type__c = 'Error';
            log.Origin__c = 'MercadoPagoNotificationHandler';
            log.Description__c = ex.getMessage();
            insert log;
            return false;
        }
        return true;
    }
}