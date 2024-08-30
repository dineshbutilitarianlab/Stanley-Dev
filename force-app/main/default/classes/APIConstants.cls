public without sharing class APIConstants {
    
    public static final String UNIWARE_OAUTH_NC = 'CALLOUT:uniware_oauth';
    public static final String UNIWARE_BASE_NC = 'CALLOUT:Uniware';
    
    public static final String UNIWARE_MIDDLE_NC = '/services/rest/v1';
    
    public static final String UNIWARE_SINGLE_INV_ADJUST = '/inventory/adjust';
    public static final String UNIWARE_BULK_INV_ADJUST = '/inventory/adjust/bulk';
    public static final String UNIWARE_GET_SO = '/oms/saleorder/get';
    public static final String UNIWARE_SEARCH_SO = '/oms/saleOrder/search';
    public static final String UNIWARE_SEARCH_RETURN = '/oms/return/search';
    public static final String UNIWARE_GET_RETURN = '/oms/return/get';
    public static final String UNIWARE_GET_INVOICE = '/invoice/details/get';
    public static final String UNIWARE_GET_INVOICE_PDF = '/oms/invoice/show?invoiceCodes=';
    public static final String UNIWARE_CREATE_EDIT_ITEM = '/catalog/itemType/createOrEdit';
    public static final String UNIWARE_CREATE_EDIT_ITEMS = '/catalog/itemTypes/createOrEdit';

    public static final String HTTP_GET = 'GET';
    public static final String HTTP_POST = 'POST';
    public static final String HTTP_PUT = 'PUT';
    public static final String HTTP_DELETE = 'DELETE';
    public static final String HTTP_HEAD = 'HEAD';
    public static final String NO_RESPONSE = 'NO_RESPONSE';
    public static final String HTTP_CONTENT_TYPE = 'Content-Type';
    public static final String HTTP_FORM_URL_ENCODED = 'application/x-www-form-urlencoded';
    public static final String HTTP_RESPONSE_ERROR_STRING = 'ERROR';
    
    public static final String ADJUSTMENTTYPE_ADD = 'ADD';
    public static final String ADJUSTMENTTYPE_REMOVE = 'REMOVE';
    public static final String ADJUSTMENTTYPE_REPLACE = 'REPLACE';
    public static final String ADJUSTMENTTYPE_TRANSFER = 'TRANSFER';
    
    public static final String OrderStatusCompleteToBeConsidered = 'COMPLETE';
    public static final String OrderStatusCancelledToBeConsidered = 'CANCELLED';
    
    
    public static void logger(String text) {
        System.debug('--- '+text);
    }
    public static void logException(Exception e, String className, String methodName) {
        System.debug('--- e.getMessage'+e.getMessage());
        System.debug('--- e.getLineNumber'+e.getLineNumber());
        System.debug('--- e.getStackTraceString'+e.getStackTraceString());
        HandleBusinessException.captureError(className, methodName, e);
    }
}