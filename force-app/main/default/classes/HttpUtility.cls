/*
* Author: DeaGle
*/

public without sharing class HttpUtility {
    public static final String NO_RESPONSE = 'NO_RESPONSE';
    public static final String HTTP_ERROR = 'ERROR WHILE MAKING REQUEST';
    static Whatsapp_Cloud_Settings__c wCloudSettings;

    
    static HttpUtility httpUtilityInstance;
    
    private HttpUtility() {}

    public static HttpUtility getInstance() {
        if(httpUtilityInstance == null) {
            httpUtilityInstance = new HttpUtility();
            wCloudSettings = Whatsapp_Cloud_Settings__c.getInstance();
        }
        return httpUtilityInstance;
    }

    public String httpReqHelper(Map<String,String> headerMap, String method, String jsonBody, String endPoint) {
        System.debug('--- body '+ jsonBody);
        System.debug('--- headerMap '+ headerMap);
        System.debug('--- method '+ method);
        System.debug('--- endPoint '+ endPoint);

        // Integration_Log__c logger = new Integration_Log__c();
        // logger.HTTP_Method__c = method;
        // logger.Integration_Type__c = 'CALLOUT';
        HttpRequest httpRequest = new HttpRequest();
        httpRequest.setEndpoint(endpoint);
        httpRequest.setMethod(method);
        httpRequest.setBody(jsonBody);

        if(!headerMap.isEmpty()){
            for(String key : headerMap.keySet()){
                httpRequest.setHeader(key,headerMap.get(key)); 
            }
        }
        try {
            Http http = new Http();
            // logger.Start_Date_And_Time__c = System.now();
            HTTPResponse response = http.send(httpRequest);
            System.debug('--- response: '+response);
            // logger.End_Date_And_Time__c = System.now();
            if(wCloudSettings != null && wCloudSettings.Enable_Integration_Logger__c)
                // createLog(logger, httpRequest, response);
            if(response.getStatusCode() == 200 || response.getStatusCode() == 201)
                return response.getBody();
            return NO_RESPONSE;
        }catch (Exception e) {
            System.debug('--- e-message '+ e.getMessage());
            System.debug('--- e-line-no '+ e.getLineNumber());
            //HandleBusinessException.captureError('HttpUtility', 'httpReqHelper', e);
            return HTTP_ERROR;
        }

    }

    private void createLog(sObject logger, HttpRequest httpReq, HttpResponse httpRes) {
        // if(httpReq != null) {
        //     logger.Request_Body__c = httpReq.getBody();
        //     logger.EndPoint__c = httpReq.getEndPoint();
        // }
        // if(httpRes != null) {
        //     logger.Response_Body__c = httpRes.getBody();
        //     logger.Response_Status_Code__c = httpRes.getStatusCode();
        // }
        // insert logger;
    }

    public void createServiceLogger(String reqBody, String resBody, String endPoint, String method, Integer statusCode, DateTime startDatetime, DateTime endDateTime) {
        try {
            if(wCloudSettings != null && wCloudSettings.Enable_Apex_Service_Logger__c) {
                // Integration_Log__c logger = new Integration_Log__c();
                // logger.HTTP_Method__c = method;
                // logger.Integration_Type__c = 'SERVICE';
                // logger.Request_Body__c = reqBody;
                // logger.Response_Body__c = resBody;
                // logger.EndPoint__c = endPoint;
                // logger.Response_Status_Code__c = statusCode;
                // logger.Start_Date_And_Time__c = startDatetime;
                // logger.End_Date_And_Time__c = endDatetime;
                // insert logger;
            }
        }catch(DMLException e){
            System.debug('--- e-message '+ e.getMessage());
            System.debug('--- e-line-no '+ e.getLineNumber());
            //HandleBusinessException.captureError('HttpUtility', 'httpReqHelper', e);
        }
    }
}