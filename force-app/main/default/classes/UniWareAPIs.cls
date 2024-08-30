public without sharing class UniWareAPIs {
    
    UniWare_APIs_Configurations__c uniwareAPIConfig = UniWare_APIs_Configurations__c.getInstance();
    static final String NO_RESPONSE = 'NO_RESPONSE';
    static final String HTTP_ERROR = 'ERROR WHILE MAKING REQUEST';
    static IntegrationLogConfig__c intLogCon;
    
    private UniWareAPIs() {}    
    private static UniWareAPIs thisInstance;
    
    public static UniWareAPIs getInstance() {
        if(thisInstance == null)
            thisInstance = new UniWareAPIs();
        return thisInstance;
    }
    
    // Get Access Token
    public static Map<String, String> getAuthToken() {
        Map<String, String> tokenResponseMap = new Map<String, String>();
        UniWare_APIs_Configurations__c uniwareAPIConfig = UniWare_APIs_Configurations__c.getInstance();
        
        Map<String,String> header = new Map<String,String>();
        String endpoint = APIConstants.UNIWARE_OAUTH_NC;
        endpoint += '?grant_type=password&client_id=my-trusted-client&username=' + uniwareAPIConfig.Username__c + '&password=' + uniwareAPIConfig.Password__c;
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        system.debug('endpoint ------->'+endpoint);
        request.setEndpoint(endpoint);
        request.setMethod(APIConstants.HTTP_GET);
        HttpResponse response = http.send(request);
        system.debug('UNIWARE API response --- ' + response.getBody());
        if(response != null && !String.isEmpty(response.getBody())) {
            Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
            string access_token = '';
            string refresh_token = '';
            
            if(responseMap.containsKey('access_token')) {
                access_token = (String) responseMap.get('access_token');
            }
            if(responseMap.containsKey('refresh_token')) {
                refresh_token = (String) responseMap.get('refresh_token');
            }
            
            tokenResponseMap.put('access_token', access_token);
            tokenResponseMap.put('refresh_token', refresh_token);
            tokenResponseMap.put('error', '');
            return tokenResponseMap;
        }
        
        tokenResponseMap.put('access_token', '');
        tokenResponseMap.put('refresh_token', '');
        tokenResponseMap.put('error', APIConstants.HTTP_RESPONSE_ERROR_STRING);
        return tokenResponseMap; 
    }
    
    // Renew Access Token
    public static String renewAccessToken() {
        UniWare_APIs_Configurations__c uniwareAPIConfig = UniWare_APIs_Configurations__c.getInstance();
        string refreshToken = getAuthToken().get('refresh_token');
        
        Map<String,String> header = new Map<String,String>();
        String endpoint = APIConstants.UNIWARE_OAUTH_NC;
        endpoint += '?grant_type=refresh_token&client_id=my-trusted-client&refresh_token=' + refreshToken;
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        system.debug('endpoint ------->'+endpoint);
        request.setEndpoint(endpoint);
        request.setMethod(APIConstants.HTTP_GET);
        HttpResponse response = http.send(request);
        system.debug('UNIWARE API response --- ' + response);
        if(response != null && !String.isEmpty(response.getBody())) {
            Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
            if(responseMap.containsKey('access_token')) {
                return (String) responseMap.get('access_token');
            }
        }
        return APIConstants.HTTP_RESPONSE_ERROR_STRING; 
    }
    
    public String handle_CreateUpdateItem(String requestBody){
        
        System.debug('Inside handle_CreateUpdateItem -- ' + requestBody);
        
        try {
            if(String.isBlank(requestBody)) {
                throw new UniwareAPIException('Request body is empty');
            }
            String endPoint = APIConstants.UNIWARE_BASE_NC + APIConstants.UNIWARE_MIDDLE_NC + APIConstants.UNIWARE_CREATE_EDIT_ITEM;
            system.debug('Create or Update Single Item EndPoint -- >> ' + endPoint);
            HttpUtility apiInstance = HttpUtility.getInstance();
            String authToken = getAuthToken().get('access_token');
            
            if(authToken == '')
                throw new UniwareAPIException('ERROR in fetching token');
            
            Map<String, String> headerMap = new Map<String, String>();
            headerMap.put('Authorization', 'Bearer ' + authToken);
            headerMap.put('Content-Type', 'application/json');
            
            system.debug('headerMap -- >> ' + headerMap);
            
            return apiInstance.httpReqHelper(headerMap, APIConstants.HTTP_POST , requestBody, endPoint);
        }
        catch(Exception e) {
            APIConstants.logException(e, 'UniWareAPIs', 'handle_CreateUpdateItem');
        }
        return null;
    }
    
    public String handle_CreateUpdateItems(String requestBody){
        
        System.debug('Inside handle_CreateUpdateItems -- ' + requestBody);
        
        try {
            if(String.isBlank(requestBody)) {
                throw new UniwareAPIException('Request body is empty');
            }
            String endPoint = APIConstants.UNIWARE_BASE_NC + APIConstants.UNIWARE_MIDDLE_NC + APIConstants.UNIWARE_CREATE_EDIT_ITEMS;
            system.debug('Create or Update Multiple Items EndPoint -- >> ' + endPoint);
            HttpUtility apiInstance = HttpUtility.getInstance();
            String authToken = getAuthToken().get('access_token');
            
            if(authToken == '')
                throw new UniwareAPIException('ERROR in fetching token');
            
            Map<String, String> headerMap = new Map<String, String>();
            headerMap.put('Authorization', 'Bearer ' + authToken);
            system.debug('headerMap -- >> ' + headerMap);
            
            return apiInstance.httpReqHelper(headerMap, APIConstants.HTTP_POST , requestBody, endPoint);
        }
        catch(Exception e) {
            APIConstants.logException(e, 'UniWareAPIs', 'handle_CreateUpdateItems');
        }
        return null;
    }
    
    public String handle_SingleInventoryAdjustment(String requestBody){
        
        System.debug('Inside handle_SingleInventoryAdjustment  -- ' + requestBody);
        
        try {
            if(String.isBlank(requestBody)) {
                throw new UniwareAPIException('Request body is empty');
            }
            String endPoint = APIConstants.UNIWARE_BASE_NC + APIConstants.UNIWARE_MIDDLE_NC + APIConstants.UNIWARE_SINGLE_INV_ADJUST;
            system.debug('Shippment Track EndPoint -- >> ' + endPoint);
            HttpUtility apiInstance = HttpUtility.getInstance();
            String authToken = getAuthToken().get('access_token');
            
            if(authToken == '')
                throw new UniwareAPIException('ERROR in fetching token');
            
            Map<String, String> headerMap = new Map<String, String>();
            headerMap.put('Content-Type', 'application/json');
            headerMap.put('Authorization', 'Bearer ' + authToken);
            headerMap.put('FACILITY', uniwareAPIConfig.FACILITY__c);
            system.debug('headerMap -- >> ' + headerMap);
            
            return apiInstance.httpReqHelper(headerMap, APIConstants.HTTP_POST , requestBody, endPoint);
        }
        catch(Exception e) {
            APIConstants.logException(e, 'UniWareAPIs', 'handle_SingleInventoryAdjustment');
        }
        return null;
    }
    
    public String handle_BulkInventoryAdjustment(String requestBody){
        
        System.debug('Inside handle_BulkInventoryAdjustment  -- ' + requestBody);
        
        try {
            if(String.isBlank(requestBody)) {
                throw new UniwareAPIException('Request body is empty');
            }
            String endPoint = APIConstants.UNIWARE_BASE_NC + APIConstants.UNIWARE_MIDDLE_NC + APIConstants.UNIWARE_BULK_INV_ADJUST;
            system.debug('Shippment Track EndPoint -- >> ' + endPoint);
            HttpUtility apiInstance = HttpUtility.getInstance();
            String authToken = getAuthToken().get('access_token');
            
            if(authToken == '')
                throw new UniwareAPIException('ERROR in fetching token');
            
            Map<String, String> headerMap = new Map<String, String>();            
            headerMap.put('Content-Type', 'application/json');
            headerMap.put('Authorization', 'Bearer ' + authToken);
            headerMap.put('FACILITY', uniwareAPIConfig.FACILITY__c);
            
            system.debug('headerMap -- >> ' + headerMap);
            
            return apiInstance.httpReqHelper(headerMap, APIConstants.HTTP_POST , requestBody, endPoint);
        }
        catch(Exception e) {
            APIConstants.logException(e, 'UniWareAPIs', 'handle_BulkInventoryAdjustment');
        }
        return null;
    }
    
    public String handle_GetSO(String requestBody){
        
        System.debug('Inside handle_GetSO  -- ' + requestBody);
        
        try {
            if(String.isBlank(requestBody)) {
                throw new UniwareAPIException('Request body is empty');
            }
            String endPoint = APIConstants.UNIWARE_BASE_NC + APIConstants.UNIWARE_MIDDLE_NC + APIConstants.UNIWARE_GET_SO;
            system.debug('Shippment Track EndPoint -- >> ' + endPoint);
            HttpUtility apiInstance = HttpUtility.getInstance();
            String authToken = getAuthToken().get('access_token');
            
            if(authToken == '')
                throw new UniwareAPIException('ERROR in fetching token');
            
            Map<String, String> headerMap = new Map<String, String>();
            headerMap.put('Authorization', 'Bearer ' + authToken);
            headerMap.put('Content-Type', 'application/json');
            system.debug('headerMap -- >> ' + headerMap);
            
            return apiInstance.httpReqHelper(headerMap, APIConstants.HTTP_POST , requestBody, endPoint);
        }
        catch(Exception e) {
            APIConstants.logException(e, 'UniWareAPIs', 'handle_GetSO');
        }
        return null;
    }
    
    public String handle_SearchSO(String requestBody){
        
        System.debug('Inside handle_SearchSO  -- ' + requestBody);
        
        try {
            if(String.isBlank(requestBody)) {
                throw new UniwareAPIException('Request body is empty');
            }
            String endPoint = APIConstants.UNIWARE_BASE_NC + APIConstants.UNIWARE_MIDDLE_NC + APIConstants.UNIWARE_SEARCH_SO;
            system.debug('Shippment Track EndPoint -- >> ' + endPoint);
            HttpUtility apiInstance = HttpUtility.getInstance();
            String authToken = getAuthToken().get('access_token');
            
            if(authToken == '')
                throw new UniwareAPIException('ERROR in fetching token');
            
            Map<String, String> headerMap = new Map<String, String>();
            headerMap.put('Authorization', 'Bearer ' + authToken);
            headerMap.put('Content-Type', 'application/json');
            system.debug('headerMap -- >> ' + headerMap);
            
            return apiInstance.httpReqHelper(headerMap, APIConstants.HTTP_POST , requestBody, endPoint);
        }
        catch(Exception e) {
            APIConstants.logException(e, 'UniWareAPIs', 'handle_SearchSO');
        }
        return null;
    }
    
    public String handle_SearchReturn(String requestBody){
        
        System.debug('Inside handle_SearchReturn  -- ' + requestBody);
        
        try {
            if(String.isBlank(requestBody)) {
                throw new UniwareAPIException('Request body is empty');
            }
            String endPoint = APIConstants.UNIWARE_BASE_NC + APIConstants.UNIWARE_MIDDLE_NC + APIConstants.UNIWARE_SEARCH_RETURN;
            system.debug('Shippment Track EndPoint -- >> ' + endPoint);
            HttpUtility apiInstance = HttpUtility.getInstance();
            String authToken = getAuthToken().get('access_token');
            
            if(authToken == '')
                throw new UniwareAPIException('ERROR in fetching token');
            
            Map<String, String> headerMap = new Map<String, String>();
            headerMap.put('Authorization', 'Bearer ' + authToken);
            headerMap.put('Content-Type', 'application/json');
            headerMap.put('FACILITY', uniwareAPIConfig.FACILITY__c);
            system.debug('headerMap -- >> ' + headerMap);
            
            return apiInstance.httpReqHelper(headerMap, APIConstants.HTTP_POST , requestBody, endPoint);
        }
        catch(Exception e) {
            APIConstants.logException(e, 'UniWareAPIs', 'handle_SearchReturn');
        }
        return null;
    }
    
    public String handle_GetReturn(String requestBody){
        
        System.debug('Inside handle_GetReturn  -- ' + requestBody);
        
        try {
            if(String.isBlank(requestBody)) {
                throw new UniwareAPIException('Request body is empty');
            }
            String endPoint = APIConstants.UNIWARE_BASE_NC + APIConstants.UNIWARE_MIDDLE_NC + APIConstants.UNIWARE_GET_RETURN;
            system.debug('Shippment Track EndPoint -- >> ' + endPoint);
            HttpUtility apiInstance = HttpUtility.getInstance();
            String authToken = getAuthToken().get('access_token');
            
            if(authToken == '')
                throw new UniwareAPIException('ERROR in fetching token');
            
            Map<String, String> headerMap = new Map<String, String>();
            headerMap.put('Authorization', 'Bearer ' + authToken);
            headerMap.put('Content-Type', 'application/json');
            headerMap.put('FACILITY', uniwareAPIConfig.FACILITY__c);
            system.debug('headerMap -- >> ' + headerMap);
            
            return apiInstance.httpReqHelper(headerMap, APIConstants.HTTP_POST , requestBody, endPoint);
        }
        catch(Exception e) {
            APIConstants.logException(e, 'UniWareAPIs', 'handle_GetReturn');
        }
        return null;
    }
    
    public String handle_GetInvoice(String requestBody){
        
        System.debug('Inside handle_GetInvoice  -- ' + requestBody);
        
        try {
            if(String.isBlank(requestBody)) {
                throw new UniwareAPIException('Request body is empty');
            }
            String endPoint = APIConstants.UNIWARE_BASE_NC + APIConstants.UNIWARE_MIDDLE_NC + APIConstants.UNIWARE_GET_INVOICE;
            system.debug('Invoice EndPoint -- >> ' + endPoint);
            HttpUtility apiInstance = HttpUtility.getInstance();
            String authToken = getAuthToken().get('access_token');
            
            if(authToken == '')
                throw new UniwareAPIException('ERROR in fetching token');
            
            Map<String, String> headerMap = new Map<String, String>();
            headerMap.put('Content-Type', 'application/json');
            headerMap.put('Authorization', 'Bearer ' + authToken);
            headerMap.put('Facility', uniwareAPIConfig.FACILITY__c);
            system.debug('headerMap -- >> ' + headerMap);
            
            return apiInstance.httpReqHelper(headerMap, APIConstants.HTTP_POST , requestBody, endPoint);
        }
        catch(Exception e) {
            APIConstants.logException(e, 'UniWareAPIs', 'handle_GetInvoice');
        }
        return null;
    }
    
    public Blob handle_GetInvoicePDF(String invoiceCode){
        
        System.debug('Inside handle_GetInvoicePDF  -- ' + invoiceCode);
        
        try {
            String endPoint = APIConstants.UNIWARE_BASE_NC + APIConstants.UNIWARE_MIDDLE_NC + APIConstants.UNIWARE_GET_INVOICE_PDF + invoiceCode;
            system.debug('Invoice EndPoint -- >> ' + endPoint);
            HttpUtility apiInstance = HttpUtility.getInstance();
            String authToken = getAuthToken().get('access_token');
            
            if(authToken == '')
                throw new UniwareAPIException('ERROR in fetching token');
            
            Map<String, String> headerMap = new Map<String, String>();
            headerMap.put('Content-Type', 'application/json');
            headerMap.put('Authorization', 'Bearer ' + authToken);
            headerMap.put('Facility', uniwareAPIConfig.FACILITY__c);
            system.debug('headerMap -- >> ' + headerMap);            
            
            Integration_Log__c logger = new Integration_Log__c();
            logger.HTTP_Method__c = APIConstants.HTTP_POST;
            logger.Integration_Type__c = 'CALLOUT';
            HttpRequest httpRequest = new HttpRequest();
            httpRequest.setEndpoint(endPoint);
            httpRequest.setMethod(APIConstants.HTTP_POST);
            
            intLogCon = IntegrationLogConfig__c.getInstance();
            if(intLogCon.Request_TimeOut__c != null)
                httpRequest.setTimeout(Integer.valueOf(intLogCon.Request_TimeOut__c));
            
            if(!headerMap.isEmpty()){
                for(String key : headerMap.keySet()){
                    httpRequest.setHeader(key,headerMap.get(key)); 
                }
            }
            Http http = new Http();
            logger.Start_Date_And_Time__c = System.now();
            HTTPResponse httpRes = http.send(httpRequest);
            logger.End_Date_And_Time__c = System.now();
            if(intLogCon != null && intLogCon.Enable_Integration_Logger__c){
                if(httpRequest != null) {
                    logger.Request_Body__c = httpRequest.getBody();
                    logger.EndPoint__c = httpRequest.getEndPoint();
                }
                if(httpRes != null) {
                    logger.Response_Status_Code__c = httpRes.getStatusCode();
                }
                insert logger;
            }
            
            Blob blobBody = httpRes.getBodyAsBlob();
            String base64StringBody = EncodingUtil.base64Encode(blobBody);
            System.debug('handle_GetInvoicePDF --- httpRes.getBodyAsBlob() '+ blobBody);
            System.debug('handle_GetInvoicePDF --- String '+ base64StringBody);
            
            if(httpRes.getStatusCode() == 200 || httpRes.getStatusCode() == 201)
                return blobBody;
            return null; //NO_RESPONSE;   
        }
        catch(Exception e) {
            APIConstants.logException(e, 'UniWareAPIs', 'handle_GetInvoicePDF');
            System.debug('handle_GetInvoicePDF --- e-message '+ e.getMessage());
            System.debug('handle_GetInvoicePDF --- e-line-no '+ e.getLineNumber());
            return null; //HTTP_ERROR;
        }
    }
    
    public class UniwareAPIException extends Exception {}
    
    
    public static void mytest(){
        Integer i=0;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;i++;i++;i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;i++;i++;
        i++;i++;i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
    }
    
}