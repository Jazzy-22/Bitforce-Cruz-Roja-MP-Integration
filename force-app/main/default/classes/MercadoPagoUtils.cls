global without sharing class MercadoPagoUtils {
    
    @InvocableMethod
    public static List<Results> MercadoPagoUtilities(List<Requests> requests) {
        if (requests[0].action == 'GetPayerData') {
            return GetPayerData(requests);
        } else if (requests[0].action == 'ParsePaymentDates') {
            return ParsePaymentDates(requests);
        } else if (requests[0].action == 'ParseSubscriptionDates') {
            return ParseSubscriptionDates(requests);
        } else if (requests[0].action == 'ParsePlanDates') {
            return ParsePlanDates(requests);
        } else {
            Results res = new Results();
            res.status = false;
            List<Results> resultList = new List<Results>();
            resultList.add(res);
            return resultList;
        }
        
    }
    
    private static List<Results> GetPayerData(List<Requests> requests) {
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        String ep = requests[0].endpoint;
        String payerEmail = requests[0].payerEmail;
        switch on ep {
            when 'default' {
                request.setEndpoint('callout:MercadoPago_Preapproval_Search_Default/?payer_id=' + requests[0].payerId);
            }
            when 'alternative' {
                request.setEndpoint('callout:MercadoPago_Preapproval_Search_Alternative/?payer_id=' + requests[0].payerId);
            }
        }
        request.setMethod('GET');
        HttpResponse response = http.send(request);
        Results res = new Results();
        if (response.getStatusCode() == 200) {
            Map<String, Object> searchResponse = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
            List<Object> mapResults = (List<Object>) searchResponse.get('results');
            Contact c = new Contact(MP_Payer_ID__c = requests[0].payerId);
            Boolean found = false;
            if (mapResults.size() > 0) {
                for (Object mapResult : mapResults) {
                    Map<String, Object> result = (Map<String, Object>) mapResult;
                    String surName = String.ValueOf(result.get('payer_last_name'));
                    c.FirstName = String.ValueOf(result.get('payer_first_name'));
                    if (surName.containsNone('*') && surName.length() > 0) {
                        c.LastName = surName;
                        found = true;
                        break;
                    }
                }
            }
            if (!found && !String.isEmpty(payerEmail)) {
                c.FirstName = '';
                c.LastName = payerEmail;
            } else if (!found) {
                c.LastName = '.';
            }
            res.c = c;
            res.status = true;
        } else {
            res.status = false;
        }
        List<Results> resultList = new List<Results>();
        resultList.add(res);
        return resultList;
    }
    
    private static List<Results> ParsePaymentDates(List<Requests> requests) {
        MP_Payment__c payment = requests[0].payment;
        payment.Card_Date_Created_DT__c = payment.Card_Date_Created__c == null ? null : parseDate(payment.Card_Date_Created__c);
        payment.Card_Date_Last_Updated_DT__c = payment.Card_Date_Last_Updated__c == null ? null : parseDate(payment.Card_Date_Last_Updated__c);
        payment.Date_Approved_DT__c = payment.Date_Approved__c == null ? null : parseDate(payment.Date_Approved__c);
        payment.Date_Created_DT__c = payment.Date_Created__c == null ? null : parseDate(payment.Date_Created__c);
        payment.Date_Last_Updated_DT__c = payment.Date_Last_Updated__c == null ? null : parseDate(payment.Date_Last_Updated__c);
        Results res = new Results();
        res.paymentR = payment;
        res.status = true;
        List<Results> resultList = new List<Results>();
        resultList.add(res);
        return resultList;
    }
    
    private static List<Results> ParseSubscriptionDates(List<Requests> requests) {
        MP_Subscription__c sub = requests[0].subscription;
        sub.MP_Auto_Recurring_End_Date_DT__c= sub.MP_Auto_Recurring_End_Date__c == null ? null : parseDate(sub.MP_Auto_Recurring_End_Date__c);
        sub.MP_Auto_Recurring_Start_Date_DT__c= sub.MP_Auto_Recurring_Start_Date__c == null ? null : parseDate(sub.MP_Auto_Recurring_Start_Date__c);
        sub.MP_Date_Created_DT__c= sub.MP_Date_Created__c == null ? null : parseDate(sub.MP_Date_Created__c);
        sub.MP_Last_Modified_DT__c= sub.MP_Last_Modified__c == null ? null : parseDate(sub.MP_Last_Modified__c);
        sub.MP_Next_Installment_Date_DT__c= sub.MP_Next_Installment_Date__c == null ? null : parseDate(sub.MP_Next_Installment_Date__c).dateGMT();
        sub.MP_Summary_Last_Charged_Date_DT__c = sub.MP_Summary_Last_Charged_Date__c == null ? null : parseDate(sub.MP_Summary_Last_Charged_Date__c);
        Results res = new Results();
        res.subscriptionR = sub;
        res.status = true;
        if (sub.MP_Auto_Recurring_Frequency_Type__c == 'months') {
            res.dayOfMonth = sub.MP_Auto_Recurring_Start_Date_DT__c.day();
        }
        List<Results> resultList = new List<Results>();
        resultList.add(res);
        return resultList;
    }
    
    private static List<Results> ParsePlanDates(List<Requests> requests) {
        MP_Subscription_Plan__c plan = requests[0].plan;
        plan.MP_Date_Created_DT__c = plan.MP_Date_Created__c == null ? null : parseDate(plan.MP_Date_Created__c);
        plan.MP_Last_Modified_DT__c = plan.MP_Last_Modified__c == null ? null : parseDate(plan.MP_Last_Modified__c);
        Results res = new Results();
        res.planR = plan;
        res.status = true;
        List<Results> resultList = new List<Results>();
        resultList.add(res);
        return resultList;
    }
    
    private static Datetime parseDate(String text) {
        String tZmins = text.substring(23,24)+text.substring(27,29);
        Datetime fullDate = Datetime.newInstanceGmt(Integer.valueOf(text.substring(0,4)),Integer.valueOf(text.substring(5,7)),Integer.valueOf(text.substring(8,10)),Integer.valueOf(text.substring(11,13)),Integer.valueOf(text.substring(14,16)),Integer.valueOf(text.substring(17,19)));
        fullDate = fullDate.addHours(-Integer.valueOf(text.substring(23,26)));
        fullDate = fullDate.addMinutes(-Integer.valueOf(tzMins));
        return fullDate;
    }
    
    global class Requests {
        @InvocableVariable 
        global String action;
        @InvocableVariable
        global String payerId;
        @InvocableVariable
        global String endpoint;
        @InvocableVariable
        global String payerEmail;
        @InvocableVariable
        global MP_Payment__c payment;
        @InvocableVariable
        global MP_Subscription__c subscription;
        @InvocableVariable
        global MP_Subscription_Plan__c plan;
    }
    
    global class Results{
        @InvocableVariable
        global Contact c;
        @InvocableVariable
        global boolean status;
        @InvocableVariable
        global MP_Payment__c paymentR;
        @InvocableVariable
        global MP_Subscription__c subscriptionR;
        @InvocableVariable
        global MP_Subscription_Plan__c planR;
        @InvocableVariable
        global Integer dayOfMonth;
    }
}