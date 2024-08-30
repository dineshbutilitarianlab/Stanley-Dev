public class TeamAssigningController {
     @AuraEnabled(cacheable=true)
    public static List<sObject> searchLookupData(String searchKey, String sObjectApiName) {    
        List<sObject> returnList = new List<sObject>();
        String sWildCardText = '%' + searchKey + '%';
        String sQuery = 'SELECT Id, Name, UserName, Profile.Name FROM ' + sObjectApiName + 
            ' WHERE UserName LIKE :sWildCardText And Profile.Name=\'Factory Team\' ' + 
            'ORDER BY CreatedDate DESC LIMIT 1';
        for (sObject obj: Database.query(sQuery)) {
            returnList.add(obj);
        }
        return returnList;
    }
    
    @AuraEnabled
    public static sObject searchDefaultRecord(String recordId, String sObjectApiName) {
        String sQuery = 'SELECT Id, Name, UserName FROM ' + sObjectApiName + 
            ' WHERE Id = :recordId AND Profile.Name =\'Factory Team\' ';
        for (sObject obj: Database.query(sQuery)) {
            return obj;
        }
        return null;
    }
    
    @AuraEnabled
    public static void teamNotificationControl(String teamName, String factoryTeamId) {
        try {
            String body;
            String subject;
            String query = 'SELECT Id, UserName, Email FROM User WHERE Profile.Name = :teamName';
            
            if (teamName == 'Import Team') {
                query += ' LIMIT 1';
                body = 'This is a test email sent to the Import Team.';
                subject = 'Import Team Notification';
            } else if (teamName == 'Factory Team') {
                query += ' AND Id = :factoryTeamId LIMIT 1';
                body = 'This is a test email sent to the Factory Team.';
                subject = 'Factory Team Notification';
            }             
            User existMatchedUser = Database.query(query);
            if (existMatchedUser != null) {
                TechnicianAssigningController.customNotification(existMatchedUser.Id);
                emailNotification(subject, body, new List<String>{existMatchedUser.Email});
                System.debug('Notification sent successfully.');
            } else {
                System.debug('No user found for the provided team name.');
            }
        } catch (Exception ex) {
            System.debug('Error Message: ' + ex.getMessage());
        }
    }
    
    @AuraEnabled
    public static void emailNotification(String subject, String body, List<String> emails) {
        Messaging.SingleEmailMessage semail = new Messaging.SingleEmailMessage();
        semail.setToAddresses(emails);
        semail.setSubject(subject);
        semail.setPlainTextBody(body); 
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] {semail});
    }


}