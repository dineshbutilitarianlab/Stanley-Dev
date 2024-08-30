public class FullCalendarController {
    
    @AuraEnabled
    public static List<Event> getEvents(){
        return [SELECT AccountId,EndDateTime,Id,StartDateTime,Subject FROM Event];
    }
    
    @AuraEnabled
    Public Static alldataWrapper BeetplannerDatareturn(String month,string year){
        Approval_Process_Requirement__c aList = Approval_Process_Requirement__c.getInstance('Field Visit');
        Boolean isApproval = aList.isApprovalRequired__c;  
        string MBPid;
        Id currUserId = UserInfo.getUserId();
        System.debug('month==> ' + month);
        System.debug('year==> ' + year);
        List<Monthly_Beat_Plan__c> MBPlist=[SELECT id,Year__c,Status__c,Start_Date__c,OwnerId,Sales_User__c,Sales_User__r.Name,Name,Month__c,End_Date__c,Month_Name__c,(SELECT id,Year__c,Name,Week_Identifier__c,Start_Day_of_Week__c,End_Day_of_Week__c,OwnerId,Monthly_Beat_Plan__c,Week_Number__c FROM Weekly_Beat_Plans__r),
                                            (Select Id,Monthly_Beat_Plan__c,Roles_and_KPI__c,KPI_Target_Name__c,Target_Count__c from KPI_Targets__r WHERE KPI_Target_Name__c !=NULL)
                                            FROM Monthly_Beat_Plan__c WHERE Month_year__c=:year AND Month_Name__c=:month AND Sales_User__c=:currUserId limit 1];
        system.debug('Monthly_Beat_Plan__c---------->'+MBPlist);
        alldataWrapper sw = new alldataWrapper();
        
        if(MBPlist.size()>0){
            MBPid=MBPlist[0].Id;
            system.debug('MBPid----'+MBPid);
            List<Weekly_Beat_Plan__c> allvisitRecordListt = [SELECT Year__c,Start_Day_of_Week__c,End_Day_of_Week__c,Week_Number__c,Monthly_Beat_Plan__c,(SELECT id, name, KPI_Target_Name__c FROM Visit__r) FROM Weekly_Beat_Plan__c WHERE Monthly_Beat_Plan__c =:MBPid ORDER BY Start_Day_of_Week__c ASC];
            system.debug('getAllvisitRecordListt-------'+allvisitRecordListt);
            map<string,integer> kpiNameWithCount = new   map<string,integer>();
            List<Visit__c> getAllvisitRecordList = [Select Id,KPI_Target__r.Name,Account__c,Account__r.Name,Lead__c,Lead__r.Name,Start_Date_Time__c,Route__c,Route__r.Name,Visit_Status__c,Actual_visit_date__c,Planned_visit_date__c,KPI_Target_Name__c From Visit__c Where (Account__c!=NUll or Lead__c !=Null) and MBPID__c =:MBPid];
            
            
            List<KPI_Target__c> getAllKpiTargetRecList  = [Select Id,Monthly_Beat_Plan__c,Roles_and_KPI__c from KPI_Target__c where Monthly_Beat_Plan__c=:MBPid];
            
            sw.MBPlist=MBPlist[0];
            sw.isApprovalRequired = isApproval;
            sw.Weeks=new List<weeklybp>();
            for(Weekly_Beat_Plan__c weeklyBP :allvisitRecordListt ){
                sw.Weeks.add(new weeklybp(weeklyBP.Week_Number__c,weeklyBP.Start_Day_of_Week__c+' TO ' + weeklyBP.End_Day_of_Week__c,weeklyBP.Visit__r));
                if(weeklyBP.Visit__r.size() >0){
                sw.showApprovalButton = true;
            }
            }
            sw.KpiTList=getAllKpiTargetRecList;
            sw.visitRecList=getAllvisitRecordList;
            system.debug('----------sw--'+sw);
            
            sw.weeklyWrapper = getWeeklyKPI(MBPid);
        }
        else{
            sw.MBPlist= null;
            sw.Weeks=null;
            sw.KpiTList=null;
            system.debug('----------sw--'+sw);
        }
        
        return sw;
        
    }
    
    Public class alldataWrapper {
        @AuraEnabled
        public Monthly_Beat_Plan__c MBPlist {get; set;}
        @AuraEnabled
        public List<weeklybp> Weeks {get;set;}
        @AuraEnabled
        Public List<KPI_Target__c> KpiTList {get; set;}
        @AuraEnabled
        public List<Visit__c> visitRecList {get;set;}
        @AuraEnabled
        public boolean showApprovalButton {get;set;}
        @AuraEnabled
        public boolean isApprovalRequired {get;set;}
        
        @AuraEnabled
        public List<WeeklyKPIWrapper> weeklyWrapper {get;set;}
        //@AuraEnabled
        //Public integer totalCP {get; set;} 
        // @AuraEnabled
        // Public integer total {get; set;} 
    }
    
    Public class weeklybp {
        
        @AuraEnabled
        public string weektext {get; set;}
        @AuraEnabled
        public string weekDesc {get; set;}
        @AuraEnabled
        public map<string,integer>  kpi {get; set;}
        
        public weeklybp(String Weektext,String weekDesc,List<Visit__c> allWeeklyVisit){
            this.weektext = Weektext;
            this.weekDesc = weekDesc;
            //this.weektext = Weektext;
            map<string,integer>  Weeklykpi = new map<string,integer> ();
            for(Visit__c visitRec: allWeeklyVisit){
                if(Weeklykpi.containsKey(visitRec.KPI_Target_Name__c)){
                    Integer tempCount = Weeklykpi.get(visitRec.KPI_Target_Name__c);
                    Weeklykpi.put(visitRec.KPI_Target_Name__c,tempCount+1);
                }else{
                    if(visitRec.KPI_Target_Name__c != null)
                        Weeklykpi.put(visitRec.KPI_Target_Name__c,1);
                }
            }
            this.kpi = Weeklykpi;
        }
    }
    
    
    public static List<WeeklyKPIWrapper> getWeeklyKPI(String monthId){
        system.debug('monthId---'+monthId);
        Map<String,Map<String,Integer>> weeklyKPICountMap = new Map<String,Map<String,Integer>>();
      
        Map<Id,Weekly_Beat_Plan__c> weeklyBeatPlanMap = new Map<Id,Weekly_Beat_Plan__c>([Select Id,Week_Number__c,Start_Day_of_Week__c,End_Day_of_Week__c,Week_Format__c From Weekly_Beat_Plan__c Where Monthly_Beat_Plan__c =: monthId]);
       system.debug('weeklyBeatPlanMap---'+weeklyBeatPlanMap);
        List<Visit__c> visits = [Select Id,Weekly_Beat_Plan__c,KPI_Target_Name__c From Visit__c Where Weekly_Beat_Plan__c IN : weeklyBeatPlanMap.keySet()];
        Map<String,String> weekIdByWeekStartAndEnd = new Map<String,String>();
        system.debug('visits---'+visits);
        for(Visit__c visit : visits){
            Weekly_Beat_Plan__c wB = weeklyBeatPlanMap.get(visit.Weekly_Beat_Plan__c);
            String weekId = wB.Week_Number__c;
            //String weekId = wB.Week_Number__c<>NULL?wB.Week_Number__c:'Week - ' + '(' +formatDate(wB.Start_Day_of_Week__c) + ' - ' +  formatDate(wB.End_Day_of_Week__c) + ')';
            //String weekId = wB.Week_Format__c;
      	     if(weeklyKPICountMap.containsKey(weekId)){
                Map<String,Integer> kPIMap = weeklyKPICountMap.get(weekId);
                
                kPIMap.put(visit.KPI_Target_Name__c,kPIMap.containsKey(visit.KPI_Target_Name__c)?kPIMap.get(visit.KPI_Target_Name__c)+1:1);
                
                weeklyKPICountMap.put(weekId,kPIMap);
            }else{
                Map<String,Integer> kPIMap = new Map<String,Integer>();
                kPIMap.put(visit.KPI_Target_Name__c,1);
                weeklyKPICountMap.put(weekId,kPIMap);
            }
            if(weekIdByWeekStartAndEnd.containsKey(weekId)){
                //
            }else{
                weekIdByWeekStartAndEnd.put(weekId,wB.Week_Format__c);
            }
            
                
        }
        
        List<WeeklyKPIWrapper> weeklyWappers = new List<WeeklyKPIWrapper>();
        
        for(String weekKey : weeklyKPICountMap.keySet()){
            WeeklyKPIWrapper weeklyWrapper           = new WeeklyKPIWrapper();
            List<KPICountWrapper> kPICounterWrappers = new List<KPICountWrapper>();
            
            weeklyWrapper.weekName = weekKey;
            weeklyWrapper.weekstartAndEndText=weekIdByWeekStartAndEnd.get(weekKey);
            
            Map<String,Integer> kPICountMap = weeklyKPICountMap.get(weekKey);
            
            for(String kPIKey : kPICountMap.keySet()){
                KPICountWrapper kPICountWrapper = new KPICountWrapper();
                kPICountWrapper.kPIName = kPIKey;
                kPICountWrapper.count = kPICountMap.get(kPIKey);
                kPICounterWrappers.add(kPICountWrapper);
            }
            
            weeklyWrapper.kpiList = kPICounterWrappers;
            weeklyWappers.add(weeklyWrapper);
        }
        system.debug('weeklyWappers'+weeklyWappers);
        return weeklyWappers;
    }
    
    
    public static String formatDate(Date rDate){
        
        Integer d  = rDate.day();
        Integer mo = rDate.month();
        Integer yr = rDate.year();
        
        DateTime dt = DateTime.newInstance(yr, mo, d);
        
        return dt.format('d MMM');
    }
    
    public class WeeklyKPIWrapper{
        @AuraEnabled
        public String weekstartAndEndText;
       @AuraEnabled
       Public  String weekName;
        @AuraEnabled
        Public  List<KPICountWrapper> kpiList;
    }
    
    public class KPICountWrapper{
        @AuraEnabled
        Public   String kPIName  {get; set;}
        @AuraEnabled
        Public   Integer count  {get; set;}
    }
}