@IsTest
public with sharing class MercadoPagoNotificationListenerTest {
    
    @IsTest
    private static void testProcessNotification() {
        Test.setMock(HttpCalloutMock.class, new MercadoPagoNotificationHandlerMock());

        //As Per Best Practice it is important to instantiate the Rest Context
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/v1/ipn/default?';
        req.httpMethod = 'POST';
        req.addParameter('topic', 'payment');
        req.addParameter('id', '123');

        RestContext.request = req;
        RestContext.response = res;

        Test.startTest();
        MercadoPagoNotificationListener.processNotification();
        Test.stopTest();

        List<MP_Payment__c> payments = [SELECT Id FROM MP_Payment__c];

        System.assertEquals(1, payments.size());
    }

    @IsTest
    private static void testFailedNotification() {
        Test.setMock(HttpCalloutMock.class, new MercadoPagoNotificationHandlerMock());

        //As Per Best Practice it is important to instantiate the Rest Context
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/v1/ipn/default?';
        req.httpMethod = 'POST';
        req.addParameter('topic', 'payment');
        req.addParameter('id', '1234567890');

        RestContext.request = req;
        RestContext.response = res;

        Test.startTest();
        MercadoPagoNotificationListener.processNotification();
        Test.stopTest();

        List<MP_Notification_Log__c> logs = [SELECT Id FROM MP_Notification_Log__c];

        System.assertEquals(1, logs.size());

    }
}