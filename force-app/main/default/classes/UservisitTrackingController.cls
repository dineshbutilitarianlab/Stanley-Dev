global class UservisitTrackingController {
    public Static String userId{get;set;}
    public static string userName {get;set;}
    public static List<Visit__c> visitRecList {get;set;}
    public Static String visitDate {get;set;}
    
    
    global class datewiseVisitWrp{
        List<Map<String,Object>> markerLocationList;
        List<Visit__c> visitList;
        List<Visit__c> visitCompList;
    }
    global UservisitTrackingController(){
        userId = UserInfo.getUserId();
        userName = UserInfo.getName();
        fetchPlannedVisitDetails(visitDate);
        system.debug('Desktop Visitdate---->'+ visitDate);
    }
    
    @RemoteAction
    global static List<Visit__c> fetchPlannedVisitDetails(String visitDate){
        try{
           	System.debug('visitDate ==== >'+visitDate);
            String[] arrTest = visitDate.split('T');
            string[] dateArray = arrTest[0].split('-');
            Integer year = Integer.valueOf(dateArray[0]);
            Integer month = Integer.valueOf(dateArray[1]); 
            Integer day = Integer.valueOf(dateArray[2]);
            date VisitFormatedDate = date.newInstance(year, month, day);
            System.debug('VisitFormatedDate ==== >'+VisitFormatedDate);
            Id currentUserId = UserInfo.getUserId();
            visitRecList = new List<Visit__c>();
            visitRecList = [SELECT Id, Name, Account__c, Account__r.BillingStreet, Account__r.BillingCity, Account__r.BillingState,Account__r.Name, Lead__r.Name,
                                   Account__r.BillingPostalCode,Account__r.BillingCountry,Account__r.BillingLatitude,Account__r.BillingLongitude ,Geo_Location__latitude__s,Geo_Location__longitude__s 
                            FROM Visit__C WHERE Planned_visit_date__c =:VisitFormatedDate AND ((Account__r.BillingLatitude !=null AND  Account__r.BillingStreet !=null AND Account__r.BillingCity !=null) OR (Lead__r.Latitude !=null AND  Lead__r.Street !=null AND Lead__r.City !=null)) AND Assigned_User__c=: currentUserId];
            System.debug('visitRecList ## ==== >'+visitRecList); 
            System.debug('visitRecList.size() ## ==== >'+visitRecList.size()); 
            return visitRecList;
        }catch(Exception e){
            return null;
        }
    }
    
    @RemoteAction
    global static datewiseVisitWrp userPopulated(string visitDate,String usrId, double currentPosLat, double currentPosLng){
        datewiseVisitWrp datewiseVisitWrapper = new datewiseVisitWrp();
        system.debug('userId::'+usrId);
        system.debug('visitDate::'+visitDate);
        String[] arrTest = visitDate.split('T');
        string[] dateArray = arrTest[0].split('-');
        
        Integer year = Integer.valueOf(dateArray[0]);
        Integer month = Integer.valueOf(dateArray[1]);
        Integer day = Integer.valueOf(dateArray[2]);
        date newDate = date.newInstance(year, month, day);
        system.debug(newDate);
        List<Visit__c> visitByDateList = new List<Visit__c>();
        List<Visit__c> pendingVisitList = new List<Visit__c>();
        List<Visit__c> completedVisitList = new List<Visit__c>();
        Map<String,Object> mapuser=new Map<String,Object>();
        List<Map<String,Object>> markerLocationsList = new List<Map<String,Object>>();
       // visitRecList = new List<Visit__c>();
        List<Visit__c> visitPassToVF = new List<Visit__c>();
        if(currentPosLat != null && currentPosLng != null)
            visitByDateList = [SELECT id, Status__c, City__c, Country__c, State__c, Street__c, Postal_Code__c, Geo_Location__latitude__s, Geo_Location__longitude__s, Lead__c, Lead__r.Name ,Account__r.Name,Account__r.Phone,Account__r.BillingStreet, Account__r.BillingCity, Account__r.BillingState,
                                   Account__r.BillingPostalCode,Account__r.BillingCountry,Account__r.BillingLatitude,Account__r.BillingLongitude ,Planned_visit_date__c,Visit_Plan__c,CheckIn__c,Check_Out__c,Visit_Plan__r.End_Location__Latitude__s FROM Visit__c WHERE Assigned_User__c =: usrId  AND Planned_visit_date__c = :newDate ORDER BY DISTANCE(Geo_Location__c, GEOLOCATION(:currentPosLat,:currentPosLng), 'mi') NULLS Last];
        else
            visitByDateList = [SELECT id, Status__c, City__c, Country__c, State__c, Street__c, Postal_Code__c, Geo_Location__latitude__s, Geo_Location__longitude__s, Lead__c, Lead__r.Name ,Account__r.Name,Account__r.Phone,Account__r.BillingStreet, Account__r.BillingCity, Account__r.BillingState,
                                   Account__r.BillingPostalCode,Account__r.BillingCountry,Account__r.BillingLatitude,Account__r.BillingLongitude ,Planned_visit_date__c,Visit_Plan__c,CheckIn__c,Check_Out__c,Visit_Plan__r.End_Location__Latitude__s FROM Visit__c WHERE Assigned_User__c =: usrId AND Planned_visit_date__c = :newDate];
        system.debug('visitByDateList::'+visitByDateList);
        
        for(Visit__c vst : visitByDateList) {
            if(vst.Account__r.BillingLatitude != null && vst.Account__r.BillingLongitude  != null) {
                system.debug('vst::'+vst);
                mapuser=new Map<String,Object>();
                mapuser.put('lat',vst.Account__r.BillingLatitude);  
                mapuser.put('lng',vst.Account__r.BillingLongitude );
                if(vst.Account__r.Name !=null){
                    mapuser.put('store_name',vst.Account__r.Name);
                }
                if(vst.Lead__r.Name !=null){
                    mapuser.put('store_name1',vst.Lead__r.Name);
                }
               
                mapuser.put('status', vst.Status__c);
                system.debug('mapuser::'+mapuser);
                markerLocationsList.add(mapuser);
            }
            if(vst.Status__c == 'COMPLETED')
                completedVisitList.add(vst);
            else
                pendingVisitList.add(vst);
        }
        
        // System.debug('visitRecList 2 === >'+visitPassToVF);
       // visitRecList = visitPassToVF;
      //  System.debug('visitRecList 3 === >'+visitPassToVF);
        system.debug('markerLocationsList::'+markerLocationsList);
        datewiseVisitWrapper.markerLocationList = markerLocationsList;
        datewiseVisitWrapper.visitList = pendingVisitList;
        datewiseVisitWrapper.visitCompList = completedVisitList;
        
        return datewiseVisitWrapper;
        
        /* listmapusertrack = new List<Map<String,Object>>();
for(Visit__c vst : visitComplatedList){
if(vst.Geo_Location__latitude__s != null && vst.Geo_Location__longitude__s != null) {
system.debug('vst::'+vst);
mapuser=new Map<String,Object>();
mapuser.put('lat',vst.Geo_Location__latitude__s);  
mapuser.put('lng',vst.Geo_Location__longitude__s);
mapuser.put('store_name',vst.Account__r.Name);
mapuser.put('status', vst.Status__c);
system.debug('mapuser::'+mapuser);
listmapusertrack.add(mapuser);
}
} */
        
    }
    
    @RemoteAction
    global static String changePlannedVisitdate(String newVisitdate,String visitId){
        try{
            visit__C vstRec = new visit__c();
            vstRec.Id = visitId;
            vstRec.Planned_visit_date__c = date.valueOf(newVisitdate);
            UPDATE vstRec;
            RETURN 'Visit date has been changed successfully.';
        }catch(Exception e){
            system.debug('Exception trace::'+e.getStackTraceString());
            RETURN 'Something went wrong';
        }
        
        
    }
    
    @RemoteAction
    global static Map<String,Object> createVisitPlanAcrossUser(Decimal startLat,Decimal startLang,String userId, string visitDate){
        
        system.debug('startLat::'+startLat);
        system.debug('startLang::'+startLang);
        String[] arrTest = visitDate.split('T');
        string[] dateArray = arrTest[0].split('-');
        
        Date myDate = Date.valueOf(visitDate); // Replace this with your actual Date field value
        // Convert the Date to a Datetime object
        Datetime myDatetime = Datetime.newInstance(myDate.year(), myDate.month(), myDate.day());
        
        // Format the Datetime to get the month name
        String monthName = myDatetime.format('MMMM');
        
        Integer year = Integer.valueOf(dateArray[0]);
        Integer month = Integer.valueOf(dateArray[1]);
        //String monthName = String.valueOf(month);
        system.debug('monthName--->'+monthName);
        String yearName = String.valueOf(year);
        system.debug('yearName--->'+yearName);
        Integer day = Integer.valueOf(dateArray[2]);
        date selectedDate = date.newInstance(year, month, day);
        system.debug(selectedDate);
        Monthly_Travel_Expense__c  mteRec;
        List<Visit__c> visitListTobeTag = [SELECT id,Visit_Plan__c,Assigned_User__c FROM Visit__c WHERE Assigned_User__c =: userId AND Planned_visit_date__c = :selectedDate]; 
        List<Monthly_Travel_Expense__c> monthTravelExpList= [SELECT Id,Name,Start_Date__c,Month__c,Year__c FROM Monthly_Travel_Expense__c WHERE Month__c =:month AND Year__c=:yearName];
        system.debug('monthTravelExpList---->'+monthTravelExpList);
        Map<String, Object> returnMap = new Map<String,Object>();
        try{
            if(monthTravelExpList.Size()==0){
                system.debug('monthTravelExpList Size---->'+monthTravelExpList.Size());
                mteRec = new Monthly_Travel_Expense__c();
                String mteName= 'MTE - ' + monthName;
                mteRec.Name = mteName;
                mteRec.Start_Day__c = System.today();
                INSERT mteRec;
                system.debug('mteRec---->'+mteRec);
            }else{
                mteRec = monthTravelExpList[0];
            }
            if(visitListTobeTag.isEmpty()){
                returnMap.put('message','No visit Planned for day.');
                returnMap.put('status',false);
                return returnMap;
            }
            Day_Visit_Plan__c vstPlan = new Day_Visit_Plan__c();
            vstPlan.Service_Executive__c = userId;
            vstPlan.Start_Location__Latitude__s = startLat;
            vstPlan.Start_Location__Longitude__s = startLang;
            vstPlan.Monthly_Travel_Expense__c = mteRec.Id;
            vstPlan.Start_Date__c = System.now();
            
            INSERT vstPlan;
            
            for(Visit__c vst : visitListTobeTag){
                vst.Visit_Plan__c = vstPlan.Id;
            }
            
            UPDATE visitListTobeTag;
            returnMap.put('message','Your visit plan has been generated.');
            returnMap.put('status',true);
            returnMap.put('day_visit_id',vstPlan.Id);
            return returnMap;
            
        }catch(Exception e) {
            System.debug('Exception Trace::'+e.getStackTraceString());
            returnMap.put('message','Something went wrong.');
            returnMap.put('status',false);
            return returnMap;
        }
    }
    
    @RemoteAction
    global static Boolean endDay(Decimal endLat,Decimal endLong, String userId, Id visitId){
        Map<String, Object> returnMap = new Map<String,Object>();
        try{
            
            Day_Visit_Plan__c vstPlan = new Day_Visit_Plan__c(Id = visitId);
            vstPlan.Service_Executive__c = userId;
            vstPlan.End_Location__Latitude__s = endLat;
            vstPlan.End_Location__Longitude__s = endLong;
            vstPlan.End_Date__c = System.now();
            update vstPlan;
            return true;
            
        }catch(Exception e) {
            System.debug('Exception Trace::'+e.getStackTraceString());
            return false;
        }
    }
}