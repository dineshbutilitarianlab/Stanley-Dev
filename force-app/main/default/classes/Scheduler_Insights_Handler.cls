public class Scheduler_Insights_Handler {
    
    @AuraEnabled
    public static SchedulerInsightsWrapper getAllDateOfSchdeularSight(Integer pageNumber, Integer pageSize, String monthName, String monthYear){
        try{
            Map<String, Integer> monthNumberByName = new Map<String, Integer>{'January' => 1, 'February' => 2, 'March' => 3, 'April' => 4, 'May' => 5, 'June' => 6,
                'July' => 7, 'August' => 8, 'September' => 9, 'October' => 10, 'November' => 11, 'December' => 12};
                    Integer monthNumber = monthNumberByName.get(monthName);
            Integer yearNumber = Integer.valueOf(monthYear);
            System.debug('monthNumber==>' + monthNumber);
            System.debug('yearNumber==>' + yearNumber);
            Integer offset = (pageNumber - 1) * pageSize;
            
            String userId = UserInfo.getUserId();
            List<Visit__c> getAllvisitRecordList = [Select Id,KPI_Target__r.Name,Account__c,Account__r.Name,Lead__c,Lead__r.Name,Start_Date_Time__c,Route__c,Route__r.Name,Visit_Status__c,Monthly_Beat_Plan__c,Actual_visit_date__c, CreatedDate From Visit__c Where KPI_Target__c !=null AND Account__c!=null AND CALENDAR_MONTH(Actual_visit_date__c) =: monthNumber AND CALENDAR_YEAR(Actual_visit_date__c) =: yearNumber AND OwnerId =: userId LIMIT :pageSize OFFSET :offset];
            List<Lead> getAllLeadReordcList = [Select Id,FirstName,LastName,Email,Phone,Status,AccountId__c,Company,CreatedDate From Lead where CreatedById =: userInfo.getUserId() AND CALENDAR_MONTH(CreatedDate) =: monthNumber AND CALENDAR_YEAR(CreatedDate) =: yearNumber AND OwnerId =: userId LIMIT :pageSize OFFSET :offset ];
            List<Event> GetAlleventList = [Select Id,WhoId,Who.Name,WhatId, What.Name,Type,EndDateTime,StartDateTime,Description,CreatedDate From Event Where  CALENDAR_MONTH(CreatedDate) =: monthNumber AND CALENDAR_YEAR(CreatedDate) =: yearNumber AND OwnerId =: userId LIMIT :pageSize OFFSET :offset];
            List<EmailMessage> getAllEmailList = [Select Id,Lead__c,Lead__r.Company,Account__r.Name,Subject,TextBody,CreatedDate,Opportunity__c,Account__c from EmailMessage Where Lead__c!=null AND CALENDAR_MONTH(CreatedDate) =: monthNumber AND CALENDAR_YEAR(CreatedDate) =: yearNumber LIMIT :pageSize OFFSET :offset];
            List<Opportunity> getAlloppRecordList = [Select Id,Name,AccountId,Account.Name,Total_Amount__c,StageName,CloseDate,Sales_Note__c,Client_Note__c,OwnerId,Owner.Name,CreatedDate From Opportunity Where CALENDAR_MONTH(CreatedDate) =: monthNumber AND CALENDAR_YEAR(CreatedDate) =: yearNumber AND OwnerId =: userId LIMIT :pageSize OFFSET :offset];
            List<Opportunity> oppBasedNegoationStageList = [Select Id,Name,AccountId,Account.Name,Total_Amount__c,StageName,CloseDate,Sales_Note__c,Client_Note__c,CreatedDate From Opportunity Where StageName = 'Negotiation' AND CALENDAR_MONTH(CreatedDate) =: monthNumber AND CALENDAR_YEAR(CreatedDate) =: yearNumber AND OwnerId =: userId LIMIT :pageSize OFFSET :offset];
            List<Quote> getAllquoteRecordList = [Select Id,Name,AccountId,Account.Name,ExpirationDate,Status,TotalPrice,OpportunityId,CreatedDate From Quote Where AccountId!=null AND CALENDAR_MONTH(CreatedDate) =: monthNumber AND CALENDAR_YEAR(CreatedDate) =: yearNumber AND OwnerId =: userId LIMIT :pageSize OFFSET :offset];
            List<Purchase_Order__c> getAllPurchaseOrderRecordList = [Select Id,Name,Order_Status__c,PO_Date__c,Quantity__c,CreatedDate From Purchase_Order__c WHERE CALENDAR_MONTH(CreatedDate) =: monthNumber AND CALENDAR_YEAR(CreatedDate) =: yearNumber AND OwnerId =: userId LIMIT :pageSize OFFSET :offset];
            List<Invoices__c> geAllinvoceRecordList = [Select Id,Name,Payment_Option__c,Payment_Mode__c,Amount__c,Invoice_Date__c,Account__c,Opportunity__c,CreatedDate From Invoices__c Where Account__c!=null AND CALENDAR_MONTH(CreatedDate) =: monthNumber AND CALENDAR_YEAR(CreatedDate) =: yearNumber AND OwnerId =: userId LIMIT :pageSize OFFSET :offset];
            List<Case> getAllcaseRecordList = [Select Id,CaseNumber,AccountId,Account.Name,Status,CreatedDate,Subject,Description,Origin From Case Where  AccountId !=null AND CALENDAR_MONTH(CreatedDate) =: monthNumber AND CALENDAR_YEAR(CreatedDate) =: yearNumber AND OwnerId =: userId LIMIT :pageSize OFFSET :offset];
            List<Feedback__c> getAllFeedbackRecordList = [Select Id,Name,Account__c,Description__c,Feedback_Rating__c,CreatedDate From Feedback__c Where Account__c!=null AND CALENDAR_MONTH(CreatedDate) =: monthNumber AND CALENDAR_YEAR(CreatedDate) =: yearNumber LIMIT :pageSize OFFSET :offset];
            List<Day_Visit_Plan__c> getAllDayVisitPlanRecList = [Select Id,Start_Date__c,End_Date__c,Total_Distance__c,Total_Covered_Distance__c,CreatedDate From Day_Visit_Plan__c where Service_Executive__c =: userInfo.getUserId() AND CALENDAR_MONTH(CreatedDate) =: monthNumber AND CALENDAR_YEAR(CreatedDate) =: yearNumber LIMIT :pageSize OFFSET :offset];
            List<KPI_Target__c> getAllKpiTargetRecList  = [Select Id,Monthly_Beat_Plan__c,Roles_and_KPI__c,CreatedDate from KPI_Target__c WHERE CALENDAR_MONTH(CreatedDate) =: monthNumber AND CALENDAR_YEAR(CreatedDate) =: yearNumber LIMIT :pageSize OFFSET :offset];
            SchedulerInsightsWrapper sw= new  SchedulerInsightsWrapper();
            if(getAllvisitRecordList.size()>0){
                system.debug('getAllvisitRecordList.size()-->'+getAllvisitRecordList.size());
                sw.visitRecList = getAllvisitRecordList;
            }
            if(getAllLeadReordcList.size()>0){
                sw.LeadRecList = getAllLeadReordcList;
            }
            if(GetAlleventList.size()>0){
                sw.eventList = GetAlleventList;
            }
            if(getAllEmailList.size()>0){
                sw.emailList = getAllEmailList;
            }
            if(getAlloppRecordList.size()>0){
                sw.oppList = getAlloppRecordList;
            }
            if(oppBasedNegoationStageList.size()>0){
                sw.oppNegoList = oppBasedNegoationStageList;
            }
            if(getAllquoteRecordList.size()>0){
                sw.quoteList = getAllquoteRecordList;
            }
            if(getAllPurchaseOrderRecordList.size()>0){
                sw.purOrdList = getAllPurchaseOrderRecordList;
            }
            if(geAllinvoceRecordList.size()>0){
                sw.invoList = geAllinvoceRecordList;
            }
            if(getAllcaseRecordList.size()>0){
                sw.caseList = getAllcaseRecordList;
            }
            if(getAllFeedbackRecordList.size()>0){
                sw.feedbackList = getAllFeedbackRecordList;
            }
            if(getAllDayVisitPlanRecList.size()>0){
                sw.dayVisitPlanList = getAllDayVisitPlanRecList;
            }
            if(sw !=null){
                return sw; 
            }
        }catch(Exception e){
            System.debug('Error message == >'+e.getMessage() + ' && Error Line == >'+e.getLineNumber());
        }
        return null;  
    }
    
   public class SchedulerInsightsWrapper {
        @AuraEnabled
        public List<Visit__c> visitRecList {get;set;}
        @AuraEnabled
        public List<Lead> LeadRecList {get;set;}
        @AuraEnabled
        public List<Event> eventList {get;set;}
        @AuraEnabled
        public List<EmailMessage> emailList {get;set;}
        @AuraEnabled
        public List<Opportunity> oppList {get;set;}
        @AuraEnabled
        public List<Opportunity> oppNegoList {get;set;}
        @AuraEnabled
        public List<Quote> quoteList {get;set;}
        @AuraEnabled
        public List<Purchase_Order__c> purOrdList {get;set;}
        @AuraEnabled
        public List<Invoices__c> invoList {get;set;}
        @AuraEnabled
        public List<Case> caseList {get;set;}
        @AuraEnabled
        public List<Feedback__c> feedbackList {get;set;}
        @AuraEnabled
        public List<Day_Visit_Plan__c> dayVisitPlanList {get;set;}
    }
    
    // September 2023
    public static List<Day_Visit_Plan__c> getAllDateOfTravelDayVisitPlan(String month,string year){
        List<Day_Visit_Plan__c> getAllDayVisitPlanRecList = [Select Id,Start_Date__c,End_Date__c,Total_Distance__c,Total_Covered_Distance__c From Day_Visit_Plan__c where Service_Executive__c =: userInfo.getUserId() AND Month_year__c=:year AND Month_Name__c=:month];
        
        return getAllDayVisitPlanRecList;
    }
    
    Public static void updateMonthname(List<Day_Visit_Plan__c> updateDvp){
        for(Day_Visit_Plan__c dvp:updateDvp){
            Datetime now = dvp.Start_Date__c;
            String monthName = now.format('MMMM');
            String year = String.valueOf(now.year());
            dvp.Month_Name__c=monthName;
            dvp.Month_year__c=year;
        }
    }
}