public class ClientSummary_Handler {
    
    @AuraEnabled
    public static ClientSummaryWrapper getAllAccountCount(){
        try{

            String userId = UserInfo.getUserId();
            Integer getAllOpportunityRecCount = [Select COUNT() From Opportunity WHERE OwnerId =: userId];
            Integer getAllETBAccountRecCount = [Select COUNT() From Account where Account_Stage__c = 'Active' AND OwnerId =: userId];
            Integer getAllNTBAccountRecCount = [Select COUNT() From Account where Account_Stage__c = 'New' AND OwnerId =: userId];
            Integer getAllLCAccountRecCount = [Select COUNT() From Account where Account_Stage__c = 'Inactive' AND OwnerId =: userId];
            ClientSummaryWrapper cswr = new ClientSummaryWrapper();
            if(getAllOpportunityRecCount != null) {
                cswr.oppToatlCount = getAllOpportunityRecCount;
            }
            if(getAllETBAccountRecCount != null) {
                cswr.accETBCount = getAllETBAccountRecCount;
            }
            if(getAllNTBAccountRecCount != null) {
                cswr.accNTBCount = getAllNTBAccountRecCount;
            }
            if(getAllLCAccountRecCount != null) {
                cswr.accLCCount = getAllLCAccountRecCount;
            }
            if(cswr !=null){
                return cswr; 
            }
        }catch(Exception e){
            System.debug('Error message == >'+e.getMessage() + ' && Error Line == >'+e.getLineNumber());
        }
        return null; 
    }
    
   public class ClientSummaryWrapper {
        @AuraEnabled
        public Integer oppToatlCount {get;set;}
        @AuraEnabled
        public Integer accETBCount {get;set;}
        @AuraEnabled
        public Integer accNTBCount {get;set;}
        @AuraEnabled
        public Integer accLCCount {get;set;}
    }
}