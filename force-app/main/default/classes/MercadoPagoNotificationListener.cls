@RestResource(urlMapping='/v1/ipn/*')
global with sharing class MercadoPagoNotificationListener {
    
    @HttpPost
    global static void processNotification() {
        RestResponse res = RestContext.response;
        RestRequest request = RestContext.request;
        String paymentId = request.params.get('id');
        String topic = request.params.get('topic');
        String endpoint = request.requestURI.substring(8,request.requestURI.length()-1);
        Boolean processed = MercadoPagoNotificationHandler.HandleNotification(paymentId, topic, endpoint);
        if (processed) {
            res.statusCode = 200;
        } else {
            res.statusCode = 403;
        }
    }
}