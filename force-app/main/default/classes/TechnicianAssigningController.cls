public class TechnicianAssigningController {
    @AuraEnabled(cacheable=true)
    public static List<sObject> searchLookupData(String searchKey, String sObjectApiName) {    
        List<sObject> returnList = new List<sObject>();
        String sWildCardText = '%' + searchKey + '%';
        String sQuery = 'SELECT Id, Name, UserName, Profile.Name FROM ' + sObjectApiName + 
            ' WHERE UserName LIKE :sWildCardText And Profile.Name=\'Technician\' ' + 
            'ORDER BY CreatedDate DESC LIMIT 2';
        for (sObject obj: Database.query(sQuery)) {
            returnList.add(obj);
        }
        return returnList;
    }
    
    @AuraEnabled
    public static sObject searchDefaultRecord(String recordId, String sObjectApiName) {
        String sQuery = 'SELECT Id, Name, UserName FROM ' + sObjectApiName + 
            ' WHERE Id = :recordId AND Profile.Name =\'Technician\' ';
        for (sObject obj: Database.query(sQuery)) {
            return obj;
        }
        return null;
    }
    
    @AuraEnabled
    public static void taskCreationcontroller(String caseId, String technicianId, Datetime scheduledTime) {
        try {
            List<Case> existMatchedCase = [SELECT Id, AccountId, ContactId FROM Case WHERE Id =: caseId];
            if (existMatchedCase != null && !existMatchedCase.isEmpty()) {
                for (Case iterateExist : existMatchedCase) {
                    iterateExist.OwnerId = technicianId;
                    iterateExist.scheduled_Visit__c = scheduledTime;
                }
                update existMatchedCase;
                User existEmail = [SELECT Id, Email FROM User WHERE Id =: technicianId];
                Task newValue = new Task();
                newValue.WhatId = caseId;
                newValue.TaskSubtype = 'Call';
                newValue.Priority = 'High';
                newValue.Status = 'Open';
                newValue.Subject = 'SRL Technical Visit scheduled';
                newValue.OwnerId = technicianId;
                insert newValue;
                customNotification(technicianId);
            } else {
                throw new AuraHandledException('No matching case found.');
            }
        } catch(Exception ex) { 
            throw new AuraHandledException('Error: ' + ex.getMessage());
        }
    }
    
    @AuraEnabled
    public static void customNotification(String technicianId) {
        CustomNotificationType cnType = [SELECT Id FROM CustomNotificationType WHERE DeveloperName = 'customnotification'];
        Messaging.CustomNotification customNotificationObj = new Messaging.CustomNotification();
        customNotificationObj.setBody('Please check the case details');
        customNotificationObj.setTitle('Testing Team Notification !!');
        customNotificationObj.setNotificationTypeId(cnType.id);
        customNotificationObj.setSenderId(UserInfo.getUserId());
        customNotificationObj.setTargetId(technicianId);
        customNotificationObj.send(new Set<String> {technicianId}); 
    }
    
  
}