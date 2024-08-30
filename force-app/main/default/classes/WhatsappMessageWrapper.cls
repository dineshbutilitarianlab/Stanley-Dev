/*
* Author: DeaGle
*/
public class WhatsappMessageWrapper {
    public String messaging_product;	//whatsapp
	public String recipient_type;	//individual
	public String to;	//16315555555
	public String type;	//template
	public cls_template template;
	public class cls_template {
		public String name;	//template-name
		public cls_language language;
		public cls_components[] components;
	}
	public class cls_language {
		public String code;	//language-and-locale-code
	}
	public class cls_components {
		public String type;	//body
		public cls_parameters[] parameters;
	}
	public class cls_parameters {
		public String type;	//text
		public String text;	//text-string
	}
	public static WhatsappMessageWrapper parse(String json){
		return (WhatsappMessageWrapper) System.JSON.deserialize(json, WhatsappMessageWrapper.class);
	}

	static void testParse() {
		String json=		'{'+
		'    "messaging_product": "whatsapp",'+
		'    "recipient_type": "individual",'+
		'    "to": "16315555555",'+
		'    "type": "template",'+
		'    "template": {'+
		'        "name": "template-name",'+
		'        "language": {'+
		'            "code": "language-and-locale-code"'+
		'        },'+
		'        "components": ['+
		'            {'+
		'                "type": "body",'+
		'                "parameters": ['+
		'                    {'+
		'                        "type": "text",'+
		'                        "text": "text-string"'+
		'                    },'+
		'                    {'+
		'                        "type": "currency",'+
		'                        "currency": {'+
		'                            "fallback_value": "$100.99",'+
		'                            "code": "USD",'+
		'                            "amount_1000": 100990'+
		'                        }'+
		'                    },'+
		'                    {'+
		'                        "type": "date_time",'+
		'                        "date_time": {'+
		'                            "fallback_value": "February 25, 1977",'+
		'                            "day_of_week": 5,'+
		'                            "year": 1977,'+
		'                            "month": 2,'+
		'                            "day_of_month": 25,'+
		'                            "hour": 15,'+
		'                            "minute": 33,'+
		'                            "calendar": "GREGORIAN"'+
		'                        }'+
		'                    }'+
		'                ]'+
		'            }'+
		'        ]'+
		'    }'+
		'}';
		WhatsappMessageWrapper obj = parse(json);
		System.assert(obj != null);
	}
}