public class IncentiveModule_cntrl {
    @AuraEnabled
    public static Wrapper getallIncentiveRec(string fiscarYearid ){
        Wrapper wrapRec = New Wrapper();
        List<Quarter_Period__c> quarterPeriodList =[Select id,Name,Quarter_Start_Period__c,Quarter_End_Period__c ,Fiscal_Year__r.Name From Quarter_Period__c where Fiscal_Year__c =:fiscarYearid  ORDER BY Quarter_Start_Period__c ASC];
        System.debug('quarterPeriodList==='+ quarterPeriodList);
        wrapRec.fiscalYearName = quarterPeriodList[0].Fiscal_Year__r.Name;
        System.debug(' wrapRec.fiscalYearName==='+ wrapRec.fiscalYearName);
        wrapRec.quarterlist = quarterPeriodList;
        
        string fiscalName = quarterPeriodList[0].Fiscal_Year__r.Name;
        Yearly_Goal__c  yeargoalRec = [Select id,User__r.FirstName,User__r.LastName,Yearly_Target__c,Target_Achieved__c,Role__c,Fiscal_Year__r.Name,Achieved_Percentage__c,Total_Incentive_Recieved__c From Yearly_Goal__c where Fiscal_Year__r.Name =: fiscalName]; //Achieved_Percentage__c
        System.debug(' yeargoalRec==='+yeargoalRec);
        wrapRec.yearlygoal  =yeargoalRec; 
        return  wrapRec;
    }
    public class Wrapper  {
        @AuraEnabled
        public  String fiscalYearName {get;set;}
        @AuraEnabled
        public   List<Quarter_Period__c> quarterlist {get;set;}   
        @AuraEnabled
        public Yearly_Goal__c yearlygoal {get;set;}
     }
    @AuraEnabled
    public static List<Quarterly_Goal_Bifercation__c> getallQuartergoalBifercation(String quarterid){
        List<Quarterly_Goal_Bifercation__c> bifercationlist = [Select id,Target_Type__c,Target_Value__c,Achieved_Value__c,Achieved_Percentage__c From Quarterly_Goal_Bifercation__c where Quarter_Period__c =:quarterid];//
        return bifercationlist;
    }
    @AuraEnabled
    public static List<Monthly_Incentive_Component__c> getallIncentiveRecordList(String quarterid){
        List<Monthly_Incentive_Component__c> micRecordlist ;
        if(quarterid != null){
            Quarterly_Goal__c quaterGoal = [Select id,Quarter_Period__c from Quarterly_Goal__c Where Quarter_Period__c =: quarterid  limit 1];
            if(quaterGoal.id != null ){
                Monthly_Incentive_Goal__c micRec = [Select id,Quarterly_Goal__c from Monthly_Incentive_Goal__c where Quarterly_Goal__c =: quaterGoal.id limit 1];
                if(micRec.id != null){
                    micRecordlist =[Select id, Target_Type__c,Incentive_Slab__r.Name,Incentive_Value_For_Slab__c,Monthly_Incentive__r.Incecntive_Percentage__c from Monthly_Incentive_Component__c where Monthly_Incentive__c =: micRec.id ] ;
                }
                
            }
        }
         System.debug(' micRecordlist==='+micRecordlist);
        return micRecordlist;
    }
    @AuraEnabled
    public static  string geahievedPercentage( ){
        Quarterly_Goal__c QCRec  = [Select id,Achieved_Percentage__c,Traget_Achieved__c from Quarterly_Goal__c limit 1];
        string accivedPercentage = String.valueOf(QCRec.Achieved_Percentage__c.format());
        system.debug('accivedPercentage===='+accivedPercentage);
        return accivedPercentage;
    }
    public static void UpdateMonthlyIncentive(List<Opportunity> newOpportunities, Map<Id, Opportunity> oldOpportunitiesMap){
        set<Date> closeDT = new  set<Date>();
        
        list<Opportunity> opplist = new list<Opportunity>();
        for(Opportunity Opp : newOpportunities){
            Opportunity oldOpp = oldOpportunitiesMap.get(opp.Id);
            if (Opp.StageName == 'Closed Won' && oldOpp.StageName != 'Closed Won'){
                closeDT.add(Opp.CloseDate);
            }
        }
        
        System.debug(' closeDT==='+closeDT);
        if(closeDT.Size()>0){
             
               Monthly_Incentive_Goal__c monthIncentiveRec = [Select id,Total_Target_Achieved__c,Start_Date__c,End_Date__c
                                                               From Monthly_Incentive_Goal__c 
                                                               Where Start_Date__c >=: closeDT AND End_Date__c <=: closeDT AND Fiscal_Year__c ='a1d5i000000mnuVAAQ' Limit 1];
           System.debug(' monthIncentiveRec==='+monthIncentiveRec);    
            if(monthIncentiveRec != null){
                for(Opportunity Opp1 : newOpportunities){
                    Opp1.Monthly_Incentive_Goal__c = monthIncentiveRec.id;
                    opplist.add(Opp1);
                }
                update opplist;
            }   
        }
        
    }
}