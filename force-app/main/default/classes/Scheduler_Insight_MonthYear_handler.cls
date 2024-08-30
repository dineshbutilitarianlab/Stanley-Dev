public class Scheduler_Insight_MonthYear_handler {
    
    @AuraEnabled
    public static returnDAta getMonthBeatPlan(String month,string year){
         System.debug('month ==>'+month);
         System.debug('year ==>'+year);
        returnDAta mainData = new returnDAta();
        Monthly_Beat_Plan__c getAllMBPList = [Select Id,Name,Sales_User__c,Sales_User__r.Name,CreatedDate,Month__c,Month_Name__c,Year__c,Status__c,Month_year__c From Monthly_Beat_Plan__c Where Sales_User__c =: userInfo.getUserId() AND Month_year__c=: year AND Month_Name__c=:month LIMIT 1];
        mainData.mbplRecord=getAllMBPList;
        System.debug('getAllMBPList ==>'+getAllMBPList.Sales_User__r.Name);
        System.debug('getAllMBPList ==>'+getAllMBPList);
            mainData.approvalData=ApprovalDetailsHelper.getActualApprovalDetails(getAllMBPList.id);
        system.debug('mainData--->'+mainData);
        return mainData;
    }
    
    @AuraEnabled
    Public static List<Day_Visit_Plan__c> getMonthlyRecord(String month,string year){
        
        Map<String, Integer> monthMap = new Map<String, Integer>{
            'January' => 1,
            'February' => 2,
            'March' => 3,
            'April' => 4,
            'May' => 5,
            'June' => 6,
            'July' => 7,
            'August' => 8,
            'September' => 9,
            'October' => 10,
            'November' => 11,
            'December' => 12
        };
        
        System.debug('month==> ' + month);
        System.debug('year==> ' + year);
        Integer monthInt=integer.valueof(monthMap.get(month));
        Integer yearInt=integer.valueof(year);
        Monthly_Beat_Plan__c getAllMBPList = [Select Id,Name,Sales_User__c,Sales_User__r.Name,CreatedDate,Month__c,Month_Name__c,Year__c,Status__c From Monthly_Beat_Plan__c Where Sales_User__c =: userInfo.getUserId() AND Month_year__c=:year AND Month_Name__c=:month LIMIT 1];
        List<Day_Visit_Plan__c> getAllDayVisitPlanRecList = [Select Id,Start_Date__c,End_Date__c,Total_Distance__c, Total_Covered_Distance__c,CreatedDate,year__c From Day_Visit_Plan__c where Service_Executive__c =: userInfo.getUserId() AND year__c=:year AND Month__c=:monthInt ORDER BY Start_Date__c ASC];
        return getAllDayVisitPlanRecList;
    }

      @AuraEnabled
    Public static List<Day_Visit_Plan__c> getMonthlyDayVisitRecords(String month,string year){
        Map<String, Integer> monthMap = new Map<String, Integer>{
            'January' => 1,
            'February' => 2,
            'March' => 3,
            'April' => 4,
            'May' => 5,
            'June' => 6,
            'July' => 7,
            'August' => 8,
            'September' => 9,
            'October' => 10,
            'November' => 11,
            'December' => 12
        };

       
        Integer monthInt=monthMap.get(month);
        Integer yearInt=integer.valueof(year);
//        Monthly_Beat_Plan__c getAllMBPList = [Select Id,Name,Sales_User__c,Sales_User__r.Name,CreatedDate,Month__c,Month_Name__c,Year__c,Status__c From Monthly_Beat_Plan__c Where Sales_User__c =: userInfo.getUserId() AND Month_year__c=:year AND Month_Name__c=:month LIMIT 1];
        List<Day_Visit_Plan__c> getAllDayVisitPlanRecList = [Select Id,Start_Date__c,End_Date__c,Total_Distance__c, Total_Covered_Distance__c,CreatedDate,Service_Executive__c From Day_Visit_Plan__c where Service_Executive__c =: userInfo.getUserId() AND year__c=:year AND Month__c=:monthInt];
        return getAllDayVisitPlanRecList;
    }
    
    PUblic class returnDAta{
        @AuraEnabled
        Public Monthly_Beat_Plan__c mbplRecord {set;get;}
        @AuraEnabled
        Public ApprovalDetailsHelper.ApprovalUserDetails approvalData {set;get;}
    }

    @AuraEnabled
    Public static  List<Route__c> getAllroutes(){

        List<Route__c> routes = [SELECT Id, Name, Route_Name__c,Predefined_Area__c FROM Route__c   WHERE Sales_User__c = :UserInfo.getUserId()];
        return routes;
    }
}