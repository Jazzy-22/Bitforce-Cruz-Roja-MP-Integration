@IsTest
public with sharing class MercadoPagoNotificationHandlerTest {
    
    @IsTest
    private static void testHandleNotification_default() {
        Test.setMock(HttpCalloutMock.class, new MercadoPagoNotificationHandlerMock());

        Boolean error = false;

        String payment_id = '123';
        String topic = 'payment';
        String endpoint = 'default';

        try{
            MercadoPagoNotificationHandler.HandleNotification(payment_id, topic, endpoint);
        } catch(Exception ex){
            error = true;
        }

        System.assert(!error);
    }

    @IsTest
    private static void testHandleNotification_alt() {
        Test.setMock(HttpCalloutMock.class, new MercadoPagoNotificationHandlerMock());

        Boolean error = false;

        String payment_id = '123';
        String topic = 'payment';
        String endpoint = 'alternative';

        try{
            MercadoPagoNotificationHandler.HandleNotification(payment_id, topic, endpoint);
        } catch(Exception ex){
            error = true;
        }

        System.assert(!error);
    }

    @IsTest
    private static void testHandleNotificationTopicNotPayment() {
        Test.setMock(HttpCalloutMock.class, new MercadoPagoNotificationHandlerMock());

        Boolean error = false;

        String payment_id = '123';
        String topic = 'not_payment';
        String endpoint = 'default';

        try{
            MercadoPagoNotificationHandler.HandleNotification(payment_id, topic, endpoint);
        } catch(Exception ex){
            error = true;
        }

        System.assert(!error);
    }

    @IsTest
    private static void testHandleNotificationException() {
        Test.setMock(HttpCalloutMock.class, new MercadoPagoNotificationHandlerMock());

        Boolean error = false;

        String payment_id = '1234567890';
        String topic = 'payment';
        String endpoint = 'default';

        try{
            MercadoPagoNotificationHandler.HandleNotification(payment_id, topic, endpoint);
        } catch(Exception ex){
            error = true;
        }

        System.assert(!error);
    }
}