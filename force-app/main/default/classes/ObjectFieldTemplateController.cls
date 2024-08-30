public class ObjectFieldTemplateController {
    
    @AuraEnabled
    public static Map<String,String> getAllSObjects(){
        try{
            Map<String,String> mapOfSobject = new Map<String,String>();
            System.debug('Schema.getGlobalDescribe().Values()-->'+Schema.getGlobalDescribe().Values());
            for(Schema.SObjectType objType : Schema.getGlobalDescribe().Values()){
                system.debug('objType-->'+objType);
                if(objType.getDescribe().isQueryable() && objType.getDescribe().isSearchable() && !objType.getDescribe().isCustomSetting() && objType.getDescribe().isDeletable()){
                    String apiName = objType.getDescribe().getName();
                    String labelName = objType.getDescribe().getLabel();
                    mapOfSobject.put(labelName,apiName);
                }
                
            }
            system.debug('mapOfSobject'+mapOfSobject);
            return mapOfSobject;
        } catch (Exception e){
            System.debug('Exception Line Number-->'+e.getLineNumber());
            System.debug('Exception Messag-->'+e.getMessage());
            return null;
        }
    }
    
    
    @AuraEnabled
    public static List<WrapperFields> getFieldList(String objName){
        try{
            // objName = 'Lead';
            Map<string, String> mapOfFields = new Map<string, String>();
            List<WrapperFields> listOfWrapperFields = new List<WrapperFields>();
            Map<String, Schema.SObjectField> objectFields = Schema.getGlobalDescribe().get(objName).getDescribe().fields.getMap();
            
            for(String fieldName : objectFields.keySet()) {
                
                WrapperFields fieldObj = new WrapperFields();
                fieldObj.label = objectFields.get(fieldName).getDescribe().getLabel(); 
                fieldObj.api_Name = objectFields.get(fieldName).getDescribe().getName();
                Schema.DisplayType fielddataType = objectFields.get(fieldName).getDescribe().getType();
                
                if(fielddataType == Schema.DisplayType.PICKLIST){
                    fieldObj.fielddataType = 'Picklist';
                    List<Schema.PicklistEntry> picklistValues = objectFields.get(fieldName).getDescribe().getPickListValues();
                    fieldObj.mapOfPicklist = new Map<String,String>();
                    for(Schema.PicklistEntry pvObj : picklistValues) {
                        fieldObj.mapOfPicklist.put(pvObj.getValue(),pvObj.getLabel());
                    }
                }else if(fielddataType == Schema.DisplayType.MULTIPICKLIST){
                    fieldObj.fielddataType = 'Multi-Picklist';
                    List<Schema.PicklistEntry> picklistValues = objectFields.get(fieldName).getDescribe().getPickListValues();
                    fieldObj.mapOfPicklist = new Map<String,String>();
                    for(Schema.PicklistEntry pvObj : picklistValues) {
                        fieldObj.mapOfPicklist.put(pvObj.getValue(),pvObj.getLabel());
                    }
                }else if(fielddataType == Schema.DisplayType.CURRENCY || fielddataType == Schema.DisplayType.INTEGER || fielddataType == Schema.DisplayType.DOUBLE || fielddataType == Schema.DisplayType.PERCENT || fielddataType == Schema.DisplayType.LONG){
                    fieldObj.fielddataType = 'Number';
                }else if(fielddataType == Schema.DisplayType.PERCENT){
                    fieldObj.fielddataType = 'Percentage';
                }else if(fielddataType == Schema.DisplayType.DATE || fielddataType == Schema.DisplayType.DATETIME){
                    fieldObj.fielddataType = 'Date';    
                }else if(fielddataType == Schema.DisplayType.STRING || fielddataType == Schema.DisplayType.TEXTAREA){
                    fieldObj.fielddataType = 'Text';                
                }else if(fielddataType == Schema.DisplayType.BOOLEAN){
                    fieldObj.fielddataType = 'Checkbox';
                }
                listOfWrapperFields.add(fieldObj);
            }
            System.debug('List of Wrapper class'+JSON.serialize(listOfWrapperFields));
            return listOfWrapperFields;
        } catch (Exception e){
            system.debug('ERROR :: ' + e.getMessage() + 'AT LINE NUMBER :: ' + e.getLineNumber());
            return null;
        }
    }
    
    @AuraEnabled
    public static List<String> getMatchList(String name){
        List<String> listOfString = new List<String>();
        if(name !=null && name !=''){
            String matchingValue = Matching_Type_Operator__c.getValues(name).Field_Name__c;
            if(matchingValue !=null && matchingValue !=''){
                List<String> stringList = matchingValue.split(',');
                for(String str : stringList){
                    listOfString.add(str);	    
                }    
            }
            System.debug('listOfString @@@'+listOfString);
            return listOfString;
        }
        return null;
    }

    @AuraEnabled
    public static Map<String, String> getPickListValue(String Object_Api_Name, String field_Api_Name){
        Map<String, String> optionMap = new Map<String, String>();
        if(Object_Api_Name !=null && Object_Api_Name !='' && field_Api_Name !=null && field_Api_Name !=''){
            try{
                Map<String,Schema.SObjectType> globaldesObj = Schema.getGlobalDescribe(); 
                Map<String, Schema.SObjectField> field_map = globaldesObj.get(Object_Api_Name.toLowerCase()).getDescribe().fields.getMap(); 
                List<Schema.PicklistEntry> picklistValues = field_map.get(field_Api_Name).getDescribe().getPickListValues();
                
                for(Schema.PicklistEntry pvObj : picklistValues) {
                    optionMap.put(pvObj.getValue(),pvObj.getLabel());
                }
                return optionMap;
            }catch(Exception e){
                System.debug('Exception Line Number-->'+e.getLineNumber());
                System.debug('Exception Messag-->'+e.getMessage());
                
            }
        }
        return optionMap;
    }
    
    @AuraEnabled
    public static  Map<string,string>  getEmailTemplates(){
        try{
            Map<string,string> emailMap = new Map<String,String>();
            List<EmailTemplate> emailList = [SELECT Id,Name From EmailTemplate];
            for(EmailTemplate et:emailList){
                emailMap.put(et.Name,et.Id);    
            }
            return  emailMap; 
        }catch(Exception e){
             System.debug('Exception Line Number-->'+e.getLineNumber());
             System.debug('Exception Messag-->'+e.getMessage());
        }
        return null;
    }


    @AuraEnabled
    public static void makeQuery(String objectName, String fieldName, String matchType, String matchValue, String tempId) {
        system.debug('objectName-->'+objectName);
        system.debug('fieldName-->'+fieldName);
        system.debug('matchType-->'+matchType);
        system.debug('matchValue-->'+matchValue);
        system.debug('tempId-->'+tempId);
        try {
            // Build filter criteria dynamically

            String filterCriteria = buildFilterCriteria(fieldName, matchType, matchValue);
            system.debug('filterCriteria-->'+filterCriteria);

            String query = 'SELECT Id' + fieldName + ' FROM ' + objectName + ' WHERE ' + filterCriteria;
            System.debug('query-->' + query);
            
            List<SObject> results = Database.query(query);
            System.debug('results-->' + results);

            for (SObject record : results) {
                System.debug(record);
            }
        } catch (Exception e) {
            System.debug('Exception Line Number-->' + e.getLineNumber());
            System.debug('Exception Message-->' + e.getMessage());
        }
    }

    // Helper method to build filter criteria
    public static String buildFilterCriteria(String fieldName, String matchType, String matchValue) {
        String criteria = '';

        // Handling equality and inequality
        if (matchType == '==' || matchType == 'equals') {
            criteria = fieldName + ' = \'' + matchValue + '\'';
        } else if (matchType == '!=' || matchType == 'doesNotEqual') {
            criteria = fieldName + ' != \'' + matchValue + '\'';

        // Handling comparison operators
        } else if (matchType == '>' || matchType == 'greaterThan') {
            criteria = fieldName + ' > ' + matchValue;
        } else if (matchType == '>=' || matchType == 'greaterThanOrEqual') {
            criteria = fieldName + ' >= ' + matchValue;
        } else if (matchType == '<' || matchType == 'lessThan') {
            criteria = fieldName + ' < ' + matchValue;
        } else if (matchType == '<=' || matchType == 'lessThanOrEqual') {
            criteria = fieldName + ' <= ' + matchValue;
        
        // Handling BETWEEN operator
        } else if (matchType == 'between') {
            criteria = fieldName + ' BETWEEN ' + matchValue;

        // Handling LIKE operators
        } else if (matchType == 'contains') {
            criteria = fieldName + ' LIKE \'%' + matchValue + '%\'';
        } else if (matchType == 'doesNotContain') {
            criteria = fieldName + ' NOT LIKE \'%' + matchValue + '%\'';
        } else if (matchType == 'startsWith') {
            criteria = fieldName + ' LIKE \'' + matchValue + '%\'';
        } else if (matchType == 'endsWith') {
            criteria = fieldName + ' LIKE \'%' + matchValue + '\'';

        // Handling IN and NOT IN operators
        } else if (matchType == 'in') {
            criteria = fieldName + ' IN (' + matchValue + ')';
        } else if (matchType == 'notIn') {
            criteria = fieldName + ' NOT IN (' + matchValue + ')';
        }

        return criteria;
    }


    // @AuraEnabled
    // public static void makeQuery(String objectName,String fieldName,string matchType,String matchValue,String tempId){
    //     try{

    //    // String objectName = 'Account';
    //    // String fieldName = 'Name'; 

    //    fieldName = Industry
    //     matchType = contains
    //    matchValue = Technology
    //    filterCriteria = fieldNamematchType matchValue
        
    //     String filterCriteria = 'Industry = \'Technology\'';

    //     String query = 'SELECT ' + fieldName + ' FROM ' + objectName + ' WHERE ' + filterCriteria;

    //     List<SObject> results = Database.query(query);
    //     System.debug('results-->'+results);

    //     for (SObject record : results) {
    //         System.debug(record);
    //     }

    //     }catch(Exception e){
    //          System.debug('Exception Line Number-->'+e.getLineNumber());
    //          System.debug('Exception Messag-->'+e.getMessage());
    //     }
    // }
    
    public class WrapperFields {
        @AuraEnabled
        public String label {get;set;}
        @AuraEnabled
        public String api_Name {get;set;}
        @AuraEnabled
        public String fielddataType {get;set;}
        @AuraEnabled
        public Map<String,String> mapOfPicklist {get;set;}
        @AuraEnabled
        public Map<String,String> FieldName {get;set;}
    }
    
}