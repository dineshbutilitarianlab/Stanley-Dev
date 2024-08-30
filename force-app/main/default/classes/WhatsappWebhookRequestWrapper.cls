/**
 * Author: Deagle
 * Thu, 2nd Mar, 23
 */
public class WhatsappWebhookRequestWrapper{
    public String w_object;	//whatsapp_business_account
    public cls_entry[] entry;
    
    public class cls_entry {
        public String id;	//112092931818059
        public cls_changes[] changes;
    }
    public class cls_changes {
        public cls_value value;
        public String field;	//messages
    }
    public class cls_value {
        public String messaging_product;	//whatsapp
        public cls_metadata metadata;
        public cls_contacts[] contacts;
        public cls_messages[] messages;
    }
    public class cls_metadata {
        public String display_phone_number;	//15550236265
        public String phone_number_id;	//107678682262859
    }
    public class cls_contacts {
        public cls_profile profile;
        public String wa_id;	//919738951291
    }
    public class cls_profile {
        public String name;	//Prithvi
    }
    public class cls_messages {
        public String w_from;	//919738951291
        public String id;	//wamid.HBgMOTE5NzM4OTUxMjkxFQIAEhggM0EzNzY1Q0RENjQwRTBBNTk2MkJCMUQwRjA3M0EzMkUA
        public String timestamp;	//1677692082
        public cls_text text;
        public String type;	//text
    }
    public class cls_text {
        public String body;	//Teddy
    }
    public static WhatsappWebhookRequestWrapper parse(String json){
        return (WhatsappWebhookRequestWrapper) System.JSON.deserialize(json, WhatsappWebhookRequestWrapper.class);
    }

    /* static testMethod void testParse() {
        String json=		'{'+
        '  "object": "whatsapp_business_account",'+
        '  "entry": ['+
        '    {'+
        '      "id": "112092931818059",'+
        '      "changes": ['+
        '        {'+
        '          "value": {'+
        '            "messaging_product": "whatsapp",'+
        '            "metadata": {'+
        '              "display_phone_number": "15550236265",'+
        '              "phone_number_id": "107678682262859"'+
        '            },'+
        '            "contacts": ['+
        '              {'+
        '                "profile": {'+
        '                  "name": "Prithvi"'+
        '                },'+
        '                "wa_id": "919738951291"'+
        '              }'+
        '            ],'+
        '            "messages": ['+
        '              {'+
        '                "from": "919738951291",'+
        '                "id": "wamid.HBgMOTE5NzM4OTUxMjkxFQIAEhggM0EzNzY1Q0RENjQwRTBBNTk2MkJCMUQwRjA3M0EzMkUA",'+
        '                "timestamp": "1677692082",'+
        '                "text": {'+
        '                  "body": "Teddy"'+
        '                },'+
        '                "type": "text"'+
        '              }'+
        '            ]'+
        '          },'+
        '          "field": "messages"'+
        '        }'+
        '      ]'+
        '    }'+
        '  ]'+
        '}';
        WebhookRequestWrapper obj = parse(json);
        System.assert(obj != null);
    } */
}