public class SchedulerInsightsProgressRing_Handler {
    
    @AuraEnabled
    public static List<Roles_and_KPI__c> getRoleAndKPI(){
        //List<Roles_and_KPI__c> getAllRAKList = [Select Id,Name From Roles_and_KPI__c Where Sales_User__c =: userInfo.getUserId() ];
        List<Roles_and_KPI__c> getAllRAKList = [Select Id,Name From Roles_and_KPI__c];
        //System.debug('getAllRAKList ==>'+getAllRAKList.Sales_User__r.Name);
        System.debug('getAllRAKList ==>'+getAllRAKList);
        return getAllRAKList;
    }
    
    @AuraEnabled
    public static list<KPI_Target__c> getCountOfVisitsForDifferentKPIs(String monthName, String monthYear){
        Id currUserId = UserInfo.getUserId();
        /*Map<String, Integer> monthNumberByName = new Map<String, Integer>{'January' => 1, 'February' => 2, 'March' => 3, 'April' => 4, 'May' => 5, 'June' => 6,
'July' => 7, 'August' => 8, 'September' => 9, 'October' => 10, 'November' => 11, 'December' => 12};
Integer monthNumber = monthNumberByName.get(monthName);
Integer yearNumber = Integer.valueOf(monthYear);

/* Map<String, List<Visit__c>> listOfVisitsByKPITarget = new Map<String, List<Visit__c>>();
List<Visit__c> allVisitList = [SELECT Id, Name, KPI_Target__c, KPI_Target_Name__c FROM Visit__c WHERE Assigned_User__c =: currUserId AND CALENDAR_MONTH(Actual_visit_date__c) =: monthNumber AND CALENDAR_YEAR(Actual_visit_date__c) =: yearNumber];
for(Visit__c visRec : allVisitList){
if(listOfVisitsByKPITarget.containsKey(visRec.KPI_Target_Name__c)){
listOfVisitsByKPITarget.get(visRec.KPI_Target_Name__c).add(visRec);
}else{
listOfVisitsByKPITarget.put(visRec.KPI_Target_Name__c, new List<Visit__c>{visRec});
}
}*/
        
        List<KPI_Target__c> allKPItargetForCurrUser = [SELECT Id, Name, Monthly_Beat_Plan__c, KPI_Target_Name__c, Achieved_Count__c, Target_Count__c FROM KPI_Target__c WHERE Monthly_Beat_Plan__r.Sales_User__c=:currUserId AND Monthly_Beat_Plan__r.Month_Name__c =: monthName AND Monthly_Beat_Plan__r.Month_year__c=:monthYear];
        list<kpiWithvisitesDetails> fillDataist = new list<kpiWithvisitesDetails>();
        for(KPI_Target__c kpi:allKPItargetForCurrUser){
            kpiWithvisitesDetails fillData = new kpiWithvisitesDetails();
            fillData.kpiName=kpi.KPI_Target_Name__c;
            fillData.kpiTarget=kpi.Target_Count__c;
            fillData.CompletedCount=kpi.Achieved_Count__c;
            if (kpi.Target_Count__c != null && kpi.Achieved_Count__c != null && kpi.Achieved_Count__c != 0) {
                fillData.completedPrecentage = (kpi.Achieved_Count__c / kpi.Target_Count__c) * 100;
                fillData.completedPrecentageInt=fillData.completedPrecentage.intValue();
            }
            system.debug('fillData--->'+fillData);
            fillDataist.add(fillData);
        }
        system.debug('fillDataist--->'+fillDataist);
        return allKPItargetForCurrUser;
    }
    
    
    
    public class allKpiData{
        @AuraEnabled
        Public list<kpiWithvisitesDetails> allkpi;
    }
    
    
    public class kpiWithvisitesDetails{
        @AuraEnabled
        Public string kpiName;
        @AuraEnabled
        Public decimal kpiTarget;
        @AuraEnabled
        Public decimal CompletedCount;
        @AuraEnabled
        Public decimal completedPrecentage;
        @AuraEnabled
        Public decimal completedPrecentageInt;
        
    }
    
}