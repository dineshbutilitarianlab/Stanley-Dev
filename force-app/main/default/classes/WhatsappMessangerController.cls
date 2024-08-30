/**
 * DeaGle:
 * 
 */
public without sharing class WhatsappMessangerController {
    
    private static String WHATSAPP_TOKEN;
    private static final String WHATSAPP_ENDPOINT = 'callout:Whatsapp_Cloud';
    static Whatsapp_Cloud_Settings__c wCloudSettings;

    Static {
        if(wCloudSettings == null) {
            wCloudSettings = Whatsapp_Cloud_Settings__c.getInstance();
        }
        WHATSAPP_TOKEN = wCloudSettings.Token__c;
    }
    
    @AuraEnabled(cacheable=true)
    public static List<MessageWrapper> getContactWhatsappHistory(String contactId){
        system.debug('--- '+contactId);
        try {
            List<MessageWrapper> messages = new List<MessageWrapper>();
            if(!String.isBlank(contactId)) {
                for(Messages__c message : [SELECT Id, OwnerId, IsDeleted, Name, CreatedDate, CreatedById, LastModifiedDate, LastModifiedById, SystemModstamp, LastActivityDate, Txn_Id__c, Sent__c, Display_Phone_Number__c, Phone_Number_Id__c, Contact_Name__c, Wa_Id__c, From__c, Message_Id__c, Timestamp__c, Message_Body__c, Type__c FROM Messages__c WHERE Contact__c = :contactId ORDER By CreatedDate/*  DESC LIMIT 20 */]) {
                    
                    messages.add(new MessageWrapper(message.id, message.From__c, message.Message_Body__c, getTimeStringFromStamp(Long.valueOf(message.Timestamp__c)), message.Sent__c ? 'message current-user '+message.Id : 'message '+message.Id, message.Sent__c, message.Txn_Id__c));
                }
            }
            return messages;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    private static String getTimeStringFromStamp(Long unixTimestamp) {
        if(unixTimestamp == null)
            return '';
        Datetime dTime = Datetime.newInstance(unixTimestamp * 1000);
        return dTime.format('HH:mm');
    }

    @AuraEnabled(cacheable=true)
    public static List<sObject> search(String searchTerm, string myObject, String filter) {
        String myQuery = null;
        if(filter != null && filter != ''){
            myQuery = 'Select Id, Name, Template_Name__c from '+myObject+' Where Name Like  \'%' + searchTerm + '%\' AND '+filter+' LIMIT  5';
        }
        else {
            if(searchTerm == null || searchTerm == ''){
                myQuery = 'Select Id, Name, Template_Name__c from '+myObject+' Where LastViewedDate != NULL ORDER BY LastViewedDate DESC LIMIT  5';
            }
            else {
                myQuery = 'Select Id, Name, Template_Name__c from '+myObject+' Where Name Like  \'%' + searchTerm + '%\' LIMIT  5';
            }
        }
        List<sObject> lookUpList = database.query(myQuery);
        return lookUpList;
    }

    

    
    @AuraEnabled
    public static Boolean sendMessageTemplate(String templateName, String phoneNumber) {
        try {
            Map<String,String> headerMap = new Map<String,String>{'Content-Type' => 'application/json', 'Authorization' => 'Bearer '+ WHATSAPP_TOKEN};
            HttpUtility utilityInstance = HttpUtility.getInstance();
            String responseBody = utilityInstance.httpReqHelper(headerMap, 'POST', JSON.serialize(constructTemplateBody(templateName, phoneNumber), true), WHATSAPP_ENDPOINT);
            System.debug('--- httpReqHelper '+ responseBody);
            return true;

        }catch(Exception e) {
            System.debug('--- error message '+e.getMessage());
            return false;
        }
    }

    //static String testText = '{"phone_number": "whatsapp:+919738951291","message": {"content": {"type": "text","text": "Hello, this is a test message!"}}}';
    @AuraEnabled
    public static Boolean sendMessageText(String textMessage, String phoneNumber, Id parentId, String replyMessageId){
        try {
            Map<String,String> headerMap = new Map<String,String>{'Content-Type' => 'application/json', 'Authorization' => 'Bearer '+ WHATSAPP_TOKEN};
            HttpUtility utilityInstance = HttpUtility.getInstance();
            String responseBody = utilityInstance.httpReqHelper(headerMap, 'POST', JSON.serialize(constructTextMsgBody(textMessage, phoneNumber, replyMessageId), true),WHATSAPP_ENDPOINT);
            System.debug('--- httpReqHelper '+ responseBody);
            if(!String.isBlank(responseBody) && responseBody != HttpUtility.NO_RESPONSE && responseBody != HttpUtility.HTTP_ERROR) {
                Messages__c sentMessage = constructSentMessage(responseBody, textMessage, phoneNumber, parentId);
                if(sentMessage != null) {
                    System.debug('--- inserting message obj: '+sentMessage);
                    insert sentMessage;
                }
                return true;
            }else {
                return false;
            }
        } catch (Exception e) {
            System.debug('--- error line no '+e.getLineNumber());
            System.debug('--- error message '+e.getMessage());
            return false;
        }
    }

    private static Messages__c constructSentMessage(String responseBody, String textMessage, String phoneNumber, Id parentId) {
        Map<String,Object> responseMap = (Map<String,Object>)JSON.deserializeUntyped(responseBody);
        if(responseMap.containsKey('messages')) {
            Messages__c messageObj = new Messages__c();
            messageObj.From__c = '123123123';
            messageObj.Txn_Id__c = !((List<Object>)responseMap.get('messages')).isEmpty() ? ((String)((Map<String,Object>)((List<Object>)responseMap.get('messages'))[0]).get('id')) : 'hardcoded_id';
            messageObj.Timestamp__c = String.valueOf(getTimeInUnix());
            messageObj.Message_Body__c = textMessage;
            messageObj.Type__c = 'Text';
            messageObj.Contact__c = parentId;
            return messageObj;
        }
        return null;
    }

    private static Long getTimeInUnix() {
        DateTime now = DateTime.now();
        return now.getTime() / 1000;
    }

    //static String testText = '{"messaging_product": "whatsapp","recipient_type": "individual","to": "+919738951291","type": "text","text": {"preview_url": false,"body": "testing"}}';
    private static WTextMsgWrapper constructTextMsgBody(String textMessage, String phoneNumber, String replyMessageId) {
        WTextMsgWrapper msgWrapper = new WTextMsgWrapper();
        msgWrapper.messaging_product = 'whatsapp';
        msgWrapper.recipient_type = 'individual';
        msgWrapper.to = phoneNumber;
        msgWrapper.type = 'text';

        WTextWrapper textWrapper = new WTextWrapper();
        textWrapper.body = textMessage;

        msgWrapper.text = textWrapper;

        if(!String.isBlank(replyMessageId)) {
            msgWrapper.context = new Context(replyMessageId); 
        }
        return msgWrapper;

    }

    
    private static WhatsappMessageWrapper constructTemplateBody(String templateName, String phoneNumber) {
        
        /*{"messaging_product": "whatsapp","to": "919738951291","type": "template","template": {"name": "hello_world","language": {"code": "en_US"}}}*/

        WhatsappMessageWrapper msgWrapper = new WhatsappMessageWrapper();
        msgWrapper.messaging_product = 'whatsapp';
        msgWrapper.type = 'template';
        msgWrapper.to = phoneNumber;
        WhatsappMessageWrapper.cls_template templateObj = new WhatsappMessageWrapper.cls_template();
        templateObj.name = templateName;

        WhatsappMessageWrapper.cls_language languageObj = new WhatsappMessageWrapper.cls_language();
        languageObj.code = 'en_US';

        templateObj.language = languageObj;

        msgWrapper.template = templateObj;

        return msgWrapper;
    }

    public class MessageWrapper {
        @AuraEnabled
        public String id;
        @AuraEnabled
        public String sender;
        @AuraEnabled
        public String content;
        @AuraEnabled
        public String timee;
        @AuraEnabled
        public String messageClass;
        @AuraEnabled
        public Boolean isCurrentUser;
        @AuraEnabled
        public String replyId;

        public MessageWrapper(String id, String sender, String content, String timee, String messageClass, Boolean isCurrentUser, String replyId) {
            this.id = id;
            this.sender = sender;
            this.content = content;
            this.timee = timee;
            this.messageClass = messageClass;
            this.isCurrentUser = isCurrentUser;
            this.replyId = replyId;
        }
    }


    /**
     * {
            "messaging_product": "whatsapp",
            "recipient_type": "individual",
            "to": "+919738951291",
            "type": "text",
            "text": { // the text object
                "preview_url": false,
                "body": "testing"
                }
        }
     */
    public class WTextMsgWrapper {
        public String messaging_product;
        public String recipient_type;
        public String to;
        public String type;
        public WTextWrapper text;
        public Context context;
    }

    public class Context {
        String message_id;
        public Context(String message_id) {
            this.message_id = message_id;
        }
    }

    public class WTextWrapper {
        public Boolean preview_url;
        public String body;
    }

    /*Msg success response wrapper
    {
        "messaging_product": "whatsapp",
        "contacts": [
            {
                "input": "919738951291",
                "wa_id": "919738951291"
            }
        ],
        "messages": [
            {
                "id": "wamid.HBgMOTE5NzM4OTUxMjkxFQIAERgSNEY5OERCODRCNTczQkZFQkI3AA=="
            }
        ]
    }
    */

    //list helpers
    @AuraEnabled(cacheable = true)
    public static List<Contact> getContactList() {
        return [SELECT Id, FirstName, LastName, Title, Email FROM Contact LIMIT 10];
    }
    
}