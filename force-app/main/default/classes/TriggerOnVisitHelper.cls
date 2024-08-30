public class TriggerOnVisitHelper {
    public static void updateDistanceOnRelatedDatVisit(List<Visit__c> updatedVisits, Map<Id, Visit__c> oldVisitMap) {
        Map<Id, List<Visit__c>> dayVisitMap = new Map<Id, List<Visit__c>>();
        
        for (Visit__c newVisit : updatedVisits) {
            system.debug('newVisit ID-->'+newVisit.ID);
            system.debug('newVisit Distance_Km__c-->'+newVisit.Distance__c);
            if (newVisit.Visit_Plan__c != null) {
                if (!dayVisitMap.containsKey(newVisit.Visit_Plan__c)) {
                    dayVisitMap.put(newVisit.Visit_Plan__c, new List<Visit__c>());
                }
                dayVisitMap.get(newVisit.Visit_Plan__c).add(newVisit);
            }
        }
        
        List<Day_Visit_Plan__c> dayVisitToBeUpdatedDistance = new List<Day_Visit_Plan__c>();
        system.debug('dayVisitToBeUpdatedDistance-->'+dayVisitToBeUpdatedDistance);
        for (Id dayVisitId : dayVisitMap.keySet()) {
            Day_Visit_Plan__c toUpdateDis = new Day_Visit_Plan__c(Id = dayVisitId);
            Double totalDistance = 0;
            for (Visit__c visit : dayVisitMap.get(dayVisitId)) {
                try {
                    // Make sure Distance__c is populated before using it
                    system.debug('visit.Distance_Km__c-->'+visit.Distance__c);
                    if (visit.Distance__c != null) {
                        totalDistance += visit.Distance__c;
                        system.debug('totalDistance-->'+totalDistance);
                    }
                } catch (Exception e) {
                    System.debug('Exception occurred: ' + e.getMessage());
                    System.debug('Exception occurred at Line: ' + e.getLineNumber());
                    // Log additional information about the exception for debugging
                }
            }
            
            // Retrieve existing Total_Covered_Distance__c and add the new distance
            toUpdateDis = [SELECT Id, Total_Covered_Distance__c FROM Day_Visit_Plan__c WHERE Id = :dayVisitId LIMIT 1];
            toUpdateDis.Total_Covered_Distance__c += totalDistance;
            dayVisitToBeUpdatedDistance.add(toUpdateDis);
        }
        
        if (!dayVisitToBeUpdatedDistance.isEmpty()) {
            try {
                System.debug('dayVisitToBeUpdatedDistance: ' + dayVisitToBeUpdatedDistance);
                update dayVisitToBeUpdatedDistance;
                System.debug('dayVisitToBeUpdatedDistance------>>> ' + dayVisitToBeUpdatedDistance);
            } catch (Exception e) {
                System.debug('Exception occurred during update: ' + e.getMessage());
                System.debug('Exception occurred at Line: ' + e.getLineNumber());
                // Log additional information about the exception for debugging
            }
        }
    }
    
    public static void updateAchivedCountOnKPI(List<Visit__c> updatedVisits, Map<Id, Visit__c> oldVisitMap){
        list<KPI_Target__c> updateKpiAchivedValuelist =new list<KPI_Target__c>();
        Map<Id, List<Visit__c>> kpiVisitMap = new Map<Id, List<Visit__c>>();
        set<ID> kpids = new set<id>();
        for (Visit__c newVisit : updatedVisits) {
            if (newVisit.KPI_Target__c != null) {
                if (!kpiVisitMap.containsKey(newVisit.KPI_Target__c)) {
                    kpiVisitMap.put(newVisit.KPI_Target__c, new List<Visit__c>());
                }
                kpiVisitMap.get(newVisit.KPI_Target__c).add(newVisit);
            }
        }
        
        list<KPI_Target__c> kpiWithVisits=[SELECT id,Name,KPI_Target_Name__c,Target_Count__c,Roles_and_KPI__c,(select id,name,Visit_Status__c,Check_Out__c,CheckIn__c,Distance_Km__c  from visit__r) from KPI_Target__c WHERE id In:kpiVisitMap.keyset()];
        for(KPI_Target__c kpi :kpiWithVisits){
            KPI_Target__c updateKpiAchivedValue = new KPI_Target__c();
            integer CompletedVists=0;
            for(Visit__c vst:kpi.visit__r){
                if(vst.Visit_Status__c=='Completed'){
                    CompletedVists ++;
                }
            }
            updateKpiAchivedValue.Achieved_Count__c = CompletedVists;
            updateKpiAchivedValue.id = kpi.Id;
            
            // Add this line to ensure each KPI record is added to the list
            updateKpiAchivedValuelist.add(updateKpiAchivedValue);
        }
        if (!updateKpiAchivedValuelist.isEmpty()) {
            try {
                System.debug('updateKpiAchivedValuelist: ' + updateKpiAchivedValuelist);
                update updateKpiAchivedValuelist;
            } catch (Exception e) {
                System.debug('Exception occurred during update: ' + e.getMessage());
                System.debug('Exception occurred at Line: ' + e.getLineNumber());
                // Log additional information about the exception for debugging
            }
        }
        
    }
    
    public static void CalculateTrvaelandTotalDistance(List<Visit__c> updatedVisits, Map<Id, Visit__c> oldVisitMap){
        
         Map<Id, List<Visit__c>> dayVisitMap = new Map<Id, List<Visit__c>>();
        
        for (Visit__c newVisit : updatedVisits) {
            if (newVisit.Visit_Plan__c != null) {
                if (!dayVisitMap.containsKey(newVisit.Visit_Plan__c)) {
                    dayVisitMap.put(newVisit.Visit_Plan__c, new List<Visit__c>());
                }
                dayVisitMap.get(newVisit.Visit_Plan__c).add(newVisit);
            }
        }
    } 
}