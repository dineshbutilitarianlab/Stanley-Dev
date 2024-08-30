/**
 * Author: DeaGle~
 * Credits: https://www.youtube.com/watch?v=gsrtbw6hOU4&list=RDw5G3f8_QElM&index=6&ab_channel=Aesthetic-Topic
 */

@RESTResource(urlMapping='/webhooklistener/*')
global without sharing class WhatsappCloudWebhookService {
    
    static String WEB_TOKEN = 'EAAKJz6xiZC6gBAEQ7Ub3pazJxFazWFUXEkbp2Hlg0W0EmblRJVhrLLr1WUwL81hqfSxRXJJ8otiGZAyQ66onZBoRFTOqdjZBKioZA5iy55N0rxyZBulbw1XVgu6ktZA0b0vs6uZAFG7SodcyHayN2id8WAktoJejpdCcaTLF9NwV6FkTvizWzYBZC';
    static Whatsapp_Cloud_Settings__c wCloudSettings;
    Static {
        if(wCloudSettings == null) {
            wCloudSettings = Whatsapp_Cloud_Settings__c.getInstance();
        }
        WEB_TOKEN = wCloudSettings.Webhook_Token__c;
    }
    
    @HttpPost
    global static void webhookListener(){
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        String requestBody = req.requestBody.toString();
        System.debug('--- WEBHOOK requestBody' +requestBody);
        try{
            if(requestBody != null) {
                requestBody = requestBody.replace('"object"','"w_object"');
                requestBody = requestBody.replace('"from"','"w_from"');

            }
            WhatsappWebhookRequestWrapper requestWrapper = (WhatsappWebhookRequestWrapper)JSON.deserialize(requestBody, WhatsappWebhookRequestWrapper.class);
            System.debug('--- requestWrapper'+ requestWrapper);
            if(requestWrapper != null) {
                processMessage(requestWrapper);
            }
        }catch(Exception e) {
            System.debug('--- Exception'+ e.getMessage());
        }
        RestContext.response.addHeader('Content-Type', 'application/json');
        RestContext.response.responseBody = Blob.valueOf(JSON.serialize(new ResponseWrapper('Received', WEB_TOKEN)));
    }

    static void processMessage(WhatsappWebhookRequestWrapper requestWrapper) {
        system.debug('Method called...');
        List<Messages__c> messageListToInsert = new List<Messages__c>();
        Map<String, Messages__c> numberWiseMessagesMap = new Map<String, Messages__c>();
        Messages__c messageObj;
        for(WhatsappWebhookRequestWrapper.cls_entry entry : requestWrapper.entry) {
            for(WhatsappWebhookRequestWrapper.cls_changes change : entry.changes) {
                for(WhatsappWebhookRequestWrapper.cls_messages message : change.value.messages) {
                    messageObj = new Messages__c();
                    messageObj.From__c = message.w_from;
                    messageObj.Txn_Id__c = message.id;
                    messageObj.Timestamp__c = message.timestamp;
                    messageObj.Message_Body__c = message.text != null ? message.text.body : '';
                    messageObj.Type__c = message.type;
                    messageListToInsert.add(messageObj);
                    numberWiseMessagesMap.put(message.w_from, messageObj);
                }

            }
        }

        if(!numberWiseMessagesMap.isEmpty()) {
            System.debug('--- numberWiseMessagesMap '+numberWiseMessagesMap);
            List<Contact> contactList = [SELECT Id, MobilePhone FROM Contact WHERE MobilePhone IN : numberWiseMessagesMap.keySet()];
            System.debug('--- contactList '+contactList);
            Map<String, Contact> mobileToContact = new Map<String, Contact>(); //Keeping whole record now because based on usecase further we may require it!
            for(Contact con: contactList) {
                mobileToContact.put(con.MobilePhone, con);
            }
            System.debug('--- mobileToContact '+mobileToContact);
            for(Messages__c message : numberWiseMessagesMap.values()) {
                if(mobileToContact.containsKey(message.From__c)) {
                    message.Contact__c = mobileToContact.get(message.From__c).Id;
                }
            }

            System.debug('--- inserting messages'+ numberWiseMessagesMap.values());
            insert numberWiseMessagesMap.values();
        }

    }


    public class ResponseWrapper {
        String message;
        String token;
        public ResponseWrapper(String message, String token) { 
            this.message = message;
            this.token = token;
        }
    }

    @HttpGet
    global static Integer verify() {
        System.debug('--- params '+RestContext.request.params);
        String token = RestContext.request.params.get('hub.verify_token');
        Integer challenge = Integer.valueOf(RestContext.request.params.get('hub.challenge'));
        if(token == WEB_TOKEN) {
            return challenge;
        }
        return null;
    }

    /**
     * {
        "object": "whatsapp_business_account",
        "entry": [
            {
            "id": "WHATSAPP_BUSINESS_ACCOUNT_ID",
            "changes": [
                {
                "value": {
                    "messaging_product": "whatsapp",
                    "metadata": {
                        "display_phone_number": "PHONE_NUMBER",
                        "phone_number_id": "PHONE_NUMBER_ID"
                    },
                    # specific Webhooks payload            
                },
                "field": "messages"
                }
            ]
            }
        ]
        }
     */
}