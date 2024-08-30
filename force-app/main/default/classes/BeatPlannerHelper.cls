public without sharing class  BeatPlannerHelper {
    @auraEnabled
    Public Static FullCalendarController.alldataWrapper  BeetplannerDatareturn(String month,string year){
        System.debug('month==> ' + month);
        System.debug('year==> ' + year);
        Id currUserId = UserInfo.getUserId();
        List<Monthly_Beat_Plan__c> MBPlist=[SELECT id,Year__c,Status__c,Start_Date__c,OwnerId,Sales_User__c,Name,Month__c,End_Date__c,Month_Name__c,(SELECT id,Year__c,Name,Week_Identifier__c,Start_Day_of_Week__c,End_Day_of_Week__c,OwnerId,Monthly_Beat_Plan__c FROM Weekly_Beat_Plans__r ORDER BY Start_Day_of_Week__c ASC) FROM Monthly_Beat_Plan__c WHERE Month_year__c=:year AND Month_Name__c=:month AND Sales_User__c=:currUserId];
        system.debug('Monthly_Beat_Plan__c---------->'+MBPlist);
        FullCalendarController.alldataWrapper newwarp = new FullCalendarController.alldataWrapper ();
        newwarp=FullCalendarController.BeetplannerDatareturn(month,year);
        //userinfo.getName();
        return newwarp;
        
        
    }
    //this method will be used in trigger to fill month name 
    Public static void updateMonthname(List<Monthly_Beat_Plan__c> updateMBp){
        for(Monthly_Beat_Plan__c mbp:updateMBp){
            Datetime now = mbp.Start_Date__c;
            String monthName = now.format('MMMM');
            String year = String.valueOf(mbp.Start_Date__c.year());
            mbp.Month_Name__c=monthName;
            mbp.Month_year__c=year;
        }
    }
    
    @AuraEnabled
    public static void initiateApprovalProcess(Id recordId) {
        // Query for the ProcessDefinitionId based on the process name
        //String processName = 'Monthly_Beat_Expense_Approval';
        Id currUserId = UserInfo.getUserId();
        Id managerId = [SELECT Id, ManagerId FROM User WHERE Id =: currUserId].ManagerId;
        if(managerId != null && !string.isBlank(managerId)){
            Approval.ProcessSubmitRequest  pass = new Approval.ProcessSubmitRequest();
            pass.setComments('Submitting request for approval automatically using Trigger');
            pass.setObjectId(recordId);
            pass.setProcessDefinitionNameOrId('Monthly_Beat_Expense_Approval');    
            pass.setNextApproverIds(new List<Id> {managerId});          // Submit the approval request for the Opportunity
            Approval.ProcessResult result = Approval.process(pass);
        }
    }
    
    
    
    
    Public class alldataWrapper {
        @AuraEnabled
        public Monthly_Beat_Plan__c MBPlist {get; set;}
        @AuraEnabled
        public List<Visit__c> visitRecList {get;set;}
        @AuraEnabled
        Public List<KPI_Target__c> KpiTList {get; set;}
        //@AuraEnabled
        //Public integer totalCP {get; set;} 
        // @AuraEnabled
        // Public integer total {get; set;} 
    }
    
    Public static void docCategories(List<Monthly_Beat_Plan__c> newMonthlyList){
        List<Document_Category__c> docToBeinserted = new List<Document_Category__c> ();
        List<string> stringList = new List<String>{'Extra expense', 'monthlyExpense'};
            for(Monthly_Beat_Plan__c mbp:newMonthlyList){
                Document_Category__c dcm = new Document_Category__c();
                for(String str : stringList){
                    dcm.Monthly_Beat_Plan__c=mbp.id;
                    dcm.Name=str;
                }
                docToBeinserted.add(dcm);
            }
        
        insert docToBeinserted;
        
    }
    
    public static void CreateDocumentCategories(List<Monthly_Beat_Plan__c> DealList){
        String document_cat = 'Test1,test2,test3';
        List<String> document_cat_list = document_cat.split(',');
        List<Document_Category__c> DocCatListToBeInserted = new List<Document_Category__c>();
        for(Monthly_Beat_Plan__c deal : DealList){
            for(String doccat:document_cat_list){
                Document_Category__c doc_cat = new Document_Category__c();
                doc_cat.Name = doccat;
                doc_cat.Monthly_Beat_Plan__c = deal.Id;
                DocCatListToBeInserted.add(doc_cat);
            } 
        }
        insert DocCatListToBeInserted;
    }

    @AuraEnabled
    Public static list<Visit__c> getTaskdetails(String accountId){
        System.debug('accountId'+accountId);
        list<Visit__c> visitrecord=[select Name,Id,KPI_Target__r.Name,Account__c,Duration__c,Account__r.Name,Lead__c,Lead__r.Name,Start_Date_Time__c,Route__c,Route__r.Name,Visit_Status__c,Actual_visit_date__c,Planned_visit_date__c,KPI_Target_Name__c,Route_Name__c,Beat_type__c From Visit__c where id =:accountId];
        System.debug('visitrecord'+visitrecord);
        return visitrecord;        
    }

}