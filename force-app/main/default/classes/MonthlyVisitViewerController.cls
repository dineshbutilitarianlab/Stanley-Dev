/**
* @author [Dinesh B]
* @email dinesh.b@utilitarianLab.com
* @create date 2023-03-20 18:27:29
* @modify date 2023-03-20 18:27:29
* @desc [description]
*/

global class MonthlyVisitViewerController {
    
    public boolean displayPopup {get;set;} 
    public void closePopup() {
        displayPopup = false; 
    } 
    public void showPopup() {
        displayPopup = true; 
    } 
    global MonthlyVisitViewerController(){
        
    }
    
    // ===============================================================================================================================================================================================================
    // Method for Show Visit Record on Calender
    @RemoteAction   
    global static List<Visit__c> fetchPageData(string formatteddate) {
        try{
            system.debug('formatteddate ==> '+formatteddate);
            List<string> mtdList=formatteddate.split('-');
            string monthName=mtdList[1];
            String yearName=mtdList[0];
            system.debug('monthName ==> '+monthName);
            system.debug('yearName ==> '+yearName);
            List<Monthly_Beat_Plan__c> MBPlist=[SELECT id,Year__c,Status__c,Start_Date__c,OwnerId,Sales_User__c,Name,Month__c,End_Date__c,Month_Name__c,(SELECT id,Year__c,Name,Week_Identifier__c,Start_Day_of_Week__c,End_Day_of_Week__c,OwnerId,Monthly_Beat_Plan__c,Week_Number__c FROM Weekly_Beat_Plans__r) FROM Monthly_Beat_Plan__c WHERE Year__c=:yearName AND Month_Name__c=:monthName AND OwnerId=:UserInfo.getUserId() limit 1];
            if(MBPlist.size()>0){
                System.debug('MBPlist Size ===> '+MBPlist.size());
                String mbpID =MBPlist[0].Id;
                system.debug('mbpID === >'+mbpID);
                List<Visit__c> getAllvisitRecordList = [Select Id,Name,Duration__c,KPI_Target__r.Name,Account__c,Account__r.Name,Lead__c,Lead__r.Name,Start_Date_Time__c,Route__c,Route__r.Name,Visit_Status__c,Actual_visit_date__c,KPI_Target_Name__c,KPI_Target__c,Specifier__r.Name,Specifier__c From Visit__c Where (Account__c!=NUll OR Lead__c != null OR Specifier__c !=null) and MBPID__c =:mbpID];
                if(getAllvisitRecordList.size()>0){
                    System.debug('getAllvisitRecordList Size ===> '+getAllvisitRecordList.size());
                    return getAllvisitRecordList;
                }
            }
        }catch(Exception e){
            ExceptionHelper.createExceptionLog(e);
            System.debug('Error  === >'+e.getMessage()+' && Error Line ===>'+e.getLineNumber());
        }
        return null;
    }
    
    // ===============================================================================================================================================================================================================
    @RemoteAction
    global Static List<User> fetchGroupmemeber(String AssignementGropLocation){
        System.debug('AssignementGropLocation :'+AssignementGropLocation);
        try{
            List<User> getUserList = new List<User>();
            List<Assignment_Group_Member__c> getGMemList = [SELECT Id,Name,Assignment_Group__r.Name,Group_Member__r.Name FROM Assignment_Group_Member__c WHERE Assignment_Group__r.Name =: AssignementGropLocation];
            Set<String> gorupNameSet = new Set<String>();
               system.debug('getGMemList.Name-->'+getGMemList);
            for(Assignment_Group_Member__c agm : getGMemList){
                system.debug('agm.Group_Member__r.Name-->'+agm.Group_Member__r.Name);
                gorupNameSet.add(agm.Group_Member__r.Name);
            }
            System.debug('gorupNameSet ->>>>>'+gorupNameSet);
            List<User> userList = [SELECT Id, FirstName, LastName, UserName FROM User WHERE Name IN: gorupNameSet];
            system.debug('userList-->'+userList);
            for(User use : userList){
                System.debug('use == >'+use);
                getUserList.add(use);
            }
            // getUserList.add( userList);
            System.debug('getUserList ::'+getUserList);
            return getUserList;
        }catch(Exception e){
            ExceptionHelper.createExceptionLog(e);
            System.debug('The Error '+e.getMessage());
            System.debug('Erron Line '+e.getLineNumber());
        }
        return null;
    }
    
    // ===============================================================================================================================================================================================================
    // Showing All Routes Name in dropdown
    @RemoteAction
    global Static List<String> getcurrentUserRoutesNew(){
        try{
            List<String> routeList = new List<String>();
            List<String> newRouteSet = new List<String>{'Hyderabad','Karnataka','Goa','Hubali','Kerala','Chennai'};
            for(Route__c route : [SELECT Id,Name,Route_Name__c,Sales_User__c FROM Route__c WHERE Sales_User__c=:UserInfo.getUserId() AND Route_Name__c IN : newRouteSet]){
                routeList.add(route.Route_Name__c);
            }
            if(routeList.size()>0){
                return routeList;
            }
        }catch(Exception e){
            ExceptionHelper.createExceptionLog(e);
            System.debug('The Error ::'+e.getMessage() +' AND Error Line No :'+e.getLineNumber());
        }
        return null;
    }
    
    // ===============================================================================================================================================================================================================
    // Showing Lead & Account in dropdown
    @RemoteAction
    global Static List<String> getSobjectType(){
        try{
            List<String> sobjectTypeList = new List<String>();
            sobjectTypeList.add('Account');
            sobjectTypeList.add('Lead');
            sobjectTypeList.add('Specifier');
            if(sobjectTypeList.size()>0){
                return sobjectTypeList;
            }
        }catch(Exception e){
            ExceptionHelper.createExceptionLog(e);
            System.debug('The Error ::'+e.getMessage() +' AND Error Line No :'+e.getLineNumber());
        }
        return null;
    }
    
    // ===============================================================================================================================================================================================================
    @RemoteAction
    global static String createVisits(List<Visit__c> visitList) {
        try{
            List<Visit__c> visitListt = new  List<Visit__c>();
            System.debug('--- visitList '+visitList);
            for(Visit__c vst: visitList){
                vst.Actual_visit_date__c=vst.Planned_visit_date__c;
                visitListt.add(vst);                  
            }
            
            upsert visitListt;
            return 'visits created successfully.';
        }catch(Exception e){
            ExceptionHelper.createExceptionLog(e);
            printError(e);
        }
        return 'something went wrong.';
    }
    
    // ===============================================================================================================================================================================================================
    // Method for getting Account Or Lead based on Route and Object Type
    @RemoteAction
    global static Map<String,Object> getUserVisitsUpdated(String routeName, String objectType) {
        try{
            String currUserId = UserInfo.getUserId();
            Map<String, Object> pageData = new Map<String,Object>();
            System.debug('routeName ===> '+routeName);
            if(!String.isBlank(routeName)) {
                String query = '%' +routeName +'%';
                System.debug('query ===> '+query);
                if(objectType == 'Account'){
                    pageData.put('accountList', [SELECT Id,Geo_Location__Latitude__s, Geo_Location__Longitude__s,Name,BillingStreet,ShippingCountry,ShippingState,ShippingStreet,ShippingPostalCode,ShippingCity,BillingCity,BillingCountry,BillingPostalCode,BillingState, BillingLatitude, BillingLongitude, ShippingLatitude, ShippingLongitude, (SELECT Id,Address__City__s, Address__CountryCode__s, Address__PostalCode__s, Address__StateCode__s, Address__Street__s, Address__Longitude__s, Address__Latitude__s FROM Dispatch_Address__r) FROM Account WHERE BillingStreet LIKE : query AND OwnerId =: currUserId]);
                }
                if(objectType == 'Lead'){
                    pageData.put('leadList', [Select Id, Name,Street,City,PostalCode,/*StateCode,CountryCode,*/Country, State, Latitude, Longitude FROM Lead WHERE Street LIKE : query AND OwnerId =: currUserId]);
                }
                if(objectType == 'Specifier'){
                  //  pageData.put('specifierList',[SELECT Id,Name,Street_Address__c,CityName__c,Zip_Postal_Code__c,State_Province__c,Country__c FROM Contact WHERE Street_Address__c LIKE : query AND OwnerId =: currUserId ]);
                  pageData.put('specifierList',[SELECT Id,Name,Street_Address__c,CityName__c,Zip_Postal_Code__c,State_Province__c,Country__c FROM Contact WHERE CityName__c LIKE : query AND OwnerId =: currUserId LIMIT 15 ]);
                }
                System.debug('pageData == >'+pageData);
                return pageData;
            }
        }catch(Exception e){
            ExceptionHelper.createExceptionLog(e);
            System.debug('The Error ::'+e.getMessage() +' AND Error Line No :'+e.getLineNumber());
        }
        return null;   
    }
    
    // ===============================================================================================================================================================================================================
    @RemoteAction
    global static void deleteEvent(String eventID) {
        if(!String.isBlank(eventID))
            delete new Visit__c(Id = eventID);
    }
    
    // ===============================================================================================================================================================================================================
    // Get Search Result as Account
    @RemoteAction
    global static List<Account> getRepAccounts(String repId, String location) {
        system.debug('repId-->'+repId);
        system.debug('location-->'+location);
        List<Account> accList = new List<Account>();
        System.debug('repId ::'+repId);
        //System.debug('searchString ::'+searchString);
        //  String searchPattern = '%'+String.escapeSingleQuotes(searchString)+'%';
        accList = [SELECT Id, Geo_Location__Latitude__s, Geo_Location__Longitude__s,Name,Location__r.Name,owner.name,ShippingCountry,ShippingState,ShippingStreet,ShippingPostalCode,(SELECT Id,Address__City__s, Address__CountryCode__s, Address__PostalCode__s, Address__StateCode__s, Address__Street__s, Address__Longitude__s, Address__Latitude__s FROM Dispatch_Address__r) FROM Account WHERE owner.name = :repId AND  Location__r.Name =: location  LIMIT 15];
        System.debug('accList ::'+accList);
        return accList;
    }
    
    // ===============================================================================================================================================================================================================
    // Get Search Result as Lead
    @RemoteAction
    global Static List<Lead> getRepLeads(String repId,  String location){
        System.debug('repId ::'+repId);
        
        System.debug('location ::'+location);
        List<Lead> ledList = new List<Lead>();
        
        ledList = [SELECT Id,Name,Location__c,owner.LastName FROM Lead WHERE owner.LastName =: repId AND Location__c =:location  LIMIT 10];
        System.debug('leadList ::'+ledList);
        return ledList;
    }
    
    // ===============================================================================================================================================================================================================
    // Creare Visit Record on Account & Lead Drag
    @RemoteAction
    global Static String createVisitObjectType(Id SobjectId, string datestring, String geolatitude, String geolongitude){
        System.debug('datestring =====> ' + datestring);
        System.debug('SobjectId :'+SobjectId);
        String sObjName = SobjectId.getSObjectType().getDescribe().getName();
        System.debug('Object Name ::'+sObjName);
        if(sObjName == 'Lead'){
            Visit__c vs = new Visit__c();
            vs.Lead__c = SobjectId;
            vs.Assigned_User__c = UserInfo.getUserId();
            vs.Planned_visit_date__c = Date.valueOf(datestring);
            vs.Geo_Location__Latitude__s = Decimal.valueOf(geolatitude);
            vs.Geo_Location__Longitude__s =  Decimal.valueOf(geolongitude);
            insert vs;
            System.debug('Visit Record  for Lead ::'+vs);
            
        }else if(sObjName == 'Account'){
            Visit__c vs = new Visit__c();
            vs.Account__c = SobjectId;
            vs.Assigned_User__c = UserInfo.getUserId();
            vs.Planned_visit_date__c = Date.valueOf(datestring);
            vs.Geo_Location__Latitude__s = Decimal.valueOf(geolatitude);
            vs.Geo_Location__Longitude__s =  Decimal.valueOf(geolongitude);
            insert vs;
            System.debug('Visit Record  for Account ::'+vs);
        }       
        return 'SUCCESS';
    }
    
    // ===============================================================================================================================================================================================================
    // Method for Creating Visit Record Based on Object Type - Lead/Account
    @RemoteAction
    global Static String createVisitObjectTypev1(Id SobjectId, string datestring, String geolatitude, String geolongitude,String StartTime,String EndTime, Boolean tagRSM){
        try{
            System.debug('datestring==> ' + datestring);
            System.debug('StartTime==> ' + StartTime);
            List<Weekly_Beat_Plan__c> WBPRec=new List<Weekly_Beat_Plan__c>();
            String sObjName = SobjectId.getSObjectType().getDescribe().getName();
            Id currentUserId = UserInfo.getUserId();
            System.debug('sObjName==> ' + sObjName);
            System.debug('currentUserId==> ' + currentUserId);
            String rsmId;
            Datetime startDateTimeValue;
            Datetime endDateTimeValue;
            
            if(datestring!=null){
                Date selectedDate=Date.valueOf(datestring);
                Integer monthNumber = selectedDate.month();
                Date weekStart = (selectedDate.toStartofWeek().addDays(1));
                Date WeekEndDate=weekStart.addDays(6);
                if(weekStart!=null || WeekEndDate!=null){
                    WBPRec=[Select Id,Start_Day_of_Week__c,End_Day_of_Week__c,Monthly_Beat_Plan__c From Weekly_Beat_Plan__c Where Start_Day_of_Week__c>=:weekStart AND End_Day_of_Week__c<=:WeekEndDate AND OwnerId =: currentUserId AND Month__c =: monthNumber];
                }
                
                List<String> dateParts = dateString.split('-');
                Integer year = Integer.valueOf(dateParts[0]);
                Integer month = Integer.valueOf(dateParts[1]);
                Integer day = Integer.valueOf(dateParts[2]);
                
                List<String> timeParts = new List<String>();
                List<String> timePartsEnd = new List<String>();
                Integer hourEnd;
                Integer minuteEnd;
                Integer minuteStart;
                Integer hourStart;
                
                
                if(StartTime != null && StartTime != ''){
                    timeParts = StartTime.split(':');
                    hourStart = Integer.valueOf(timeParts[0]);
                    minuteStart = Integer.valueOf(timeParts[1]);
                }
                
                if(EndTime != null && EndTime != ''){
                    timePartsEnd = EndTime.split(':');
                    hourEnd = Integer.valueOf(timePartsEnd[0]);
                    minuteEnd = Integer.valueOf(timePartsEnd[1]);
                }
                
                startDateTimeValue = Datetime.newInstance(year, month, day, hourStart, minuteStart, 0);
                endDateTimeValue = Datetime.newInstance(year, month, day, hourEnd, minuteEnd, 0);
            }
            
            if(StartTime != null){
                String[] strStartTimeTimeSplit = StartTime.split(':');
                String[] strEndTimeTimeSplit = EndTime.split(':');
                time realStartTime =Time.newInstance(Integer.valueOf(strStartTimeTimeSplit[0]),Integer.valueOf(strStartTimeTimeSplit[1]),0 ,0);
                time realEndTime = Time.newInstance(Integer.valueOf(strEndTimeTimeSplit[0]),Integer.valueOf(strEndTimeTimeSplit[1]),0 ,0);
                system.debug('realStartTime==>'+realStartTime);
                system.debug('realEndTime==>'+realEndTime);
                List<visit__C> visitList = [Select id ,Assigned_User__c, Expected_Start_Time__c , Expected_End_Time__c from visit__c 
                                            where Expected_Start_Time__c <= :realStartTime AND  Expected_End_Time__c >= :realEndTime 
                                            AND Planned_visit_date__c =:system.today() AND Assigned_User__c=:UserInfo.getUserId()];
                if(visitList.size() > 0){
                    return 'visit is already scheduled for this slot!!';
                }
            }
            
            Visit__c vs = new Visit__c();
            
            if(sObjName == 'Lead'){
                System.debug('inside tagRSM lead==>'+sObjName);
                vs.Lead__c = SobjectId;
                vs.Assigned_User__c = UserInfo.getUserId();
                vs.Planned_visit_date__c = Date.valueOf(datestring);
                vs.Actual_visit_date__c = Date.valueOf(datestring);
                vs.Visit_Status__c = 'Assigned';
                if(WBPRec[0].Monthly_Beat_Plan__c !=null){
                    vs.Monthly_Beat_Plan__c=WBPRec[0].Monthly_Beat_Plan__c; 
                }
                if(WBPRec[0].Id!=null){
                    vs.Weekly_Beat_Plan__c=WBPRec[0].Id; 
                }
                if(tagRSM){
                    System.debug('inside tagRSM lead==>');
                    rsmId = [SELECT Id, Name, ManagerId FROM User WHERE Id=: currentUserId][0].ManagerId;
                    if(rsmId != null && rsmId != ''){
                        System.debug('inside tagRSM lead==>');
                        vs.Manager__c = rsmId;
                    }
                }
                String[] strStartTimeTimeSplit = StartTime.split(':');
                vs.Expected_Start_Time__c=Time.newInstance(Integer.valueOf(strStartTimeTimeSplit[0]),Integer.valueOf(strStartTimeTimeSplit[1]),0 ,0);
                String[] strEndTimeTimeSplit = EndTime.split(':');
                vs.Expected_End_Time__c=Time.newInstance(Integer.valueOf(strEndTimeTimeSplit[0]),Integer.valueOf(strEndTimeTimeSplit[1]),0 ,0);
                vs.Geo_Location__Latitude__s = Decimal.valueOf(geolatitude);
                vs.Geo_Location__Longitude__s =  Decimal.valueOf(geolongitude);
                insert vs;
                
                if(tagRSM && rsmId != null && rsmId != ''){
                    System.debug('inside tagRSM lead==>');
                    Event objEvent = new Event();
                    objEvent.Type = 'Visit';
                    objEvent.Subject = 'Field Visit Scheduled';
                    objEvent.Description = 'A Field Visit has been scheduled by one of your team member'; 
                    objEvent.StartDateTime = startDateTimeValue;
                    objEvent.EndDateTime = endDateTimeValue;
                    objEvent.WhatId = vs.Id;
                    objEvent.OwnerId = rsmId;
                    //objEvent.Location = 'Sample';
                    insert objEvent;
                    System.debug('objEvent==> ' + objEvent);
                }
                System.debug('Visit Create for Lead__c == >'+vs);
                
            }else if(sObjName == 'Account'){
                System.debug('inside tagRSM Account==>'+sObjName);
                vs.Account__c = SobjectId;
                vs.Assigned_User__c = UserInfo.getUserId();
                vs.Planned_Visit_Date__c = Date.valueOf(datestring);
                vs.Actual_Visit_Date__c = Date.valueOf(datestring);
                vs.Visit_Status__c = 'Assigned';
                if(WBPRec[0].Monthly_Beat_Plan__c !=null){
                    vs.Monthly_Beat_Plan__c=WBPRec[0].Monthly_Beat_Plan__c; 
                }
                if(WBPRec[0].Id !=null){
                    vs.Weekly_Beat_Plan__c=WBPRec[0].Id; 
                }
                if(tagRSM){
                    System.debug('inside tagRSM Account==>');
                    rsmId = [SELECT Id, Name, ManagerId FROM User WHERE Id=: currentUserId][0].ManagerId;
                    if(rsmId != null && rsmId != ''){
                        System.debug('inside rsmId Account==>');
                        vs.Manager__c = rsmId;
                    }
                }
                String[] strStartTimeTimeSplit = StartTime.split(':');
                vs.Expected_Start_Time__c=Time.newInstance(Integer.valueOf(strStartTimeTimeSplit[0]),Integer.valueOf(strStartTimeTimeSplit[1]),0 ,0);
                String[] strEndTimeTimeSplit = EndTime.split(':');
                vs.Expected_End_Time__c=Time.newInstance(Integer.valueOf(strEndTimeTimeSplit[0]),Integer.valueOf(strEndTimeTimeSplit[1]),0 ,0);
                vs.Geo_Location__Latitude__s = Decimal.valueOf(geolatitude);
                vs.Geo_Location__Longitude__s =  Decimal.valueOf(geolongitude);
                insert vs;
                if(tagRSM && rsmId != null && rsmId != ''){
                    Event objEvent = new Event();
                    objEvent.Type = 'Visit';
                    objEvent.Subject = 'Field Visit Scheduled';
                    objEvent.Description = 'A Field Visit has been scheduled by one of your team member'; 
                    objEvent.StartDateTime = startDateTimeValue;
                    objEvent.EndDateTime = endDateTimeValue;
                    objEvent.WhatId = vs.Id;
                    objEvent.OwnerId = rsmId;
                    //objEvent.Location = 'Sample';
                    insert objEvent;
                    System.debug('objEvent==> ' + objEvent);
                }
                System.debug('Visit Created For Account == >'+ vs); 
            }       
            return vs.Id;
        }catch(Exception e){
            ExceptionHelper.createExceptionLog(e);
            System.debug('The Error ::'+e.getMessage() +' AND Error Line No :'+e.getLineNumber());
        }
        return 'ERROR';
    }
    
    static void printError(Exception e) {
        System.debug('--- ErrorMsg :'+e.getMessage());
        System.debug('--- ErrorLineNo :'+e.getMessage());
    }
    
    // ===============================================================================================================================================================================================================
    @RemoteAction
    global static Sobject getCurrentRecordGeoLocation(String recordId){
        if(!String.isBlank(recordId)){
            Id myId = Id.valueOf(recordId);
            String sObjName = myId.getSObjectType().getDescribe().getName();
            if(sObjName == 'Lead'){
                System.debug('Lead Found');
                Lead led = [SELECT Id, Name, Latitude, Longitude FROM Lead WHERE Id =: recordId];
                System.debug('Lead Record :::'+led);
                return led;
            }else if(sObjName == 'Account'){
                System.debug('Account Found'); 
                Account acc = [SELECT Id,Geo_Location__Latitude__s, Geo_Location__Longitude__s,Name, BillingCity, BillingCountry, BillingPostalCode, BillingState, BillingStreet, BillingLatitude, BillingLongitude, ShippingLatitude, ShippingLongitude, ShippingCountry,ShippingState,ShippingStreet,ShippingPostalCode, ShippingCity FROM Account WHERE Id =: recordId];
                System.debug('Account Record :::'+acc);
                return acc;
            }
            return null;
        }else{
            return null;
        }
    }
    
    // ===============================================================================================================================================================================================================
    @RemoteAction
    global static List<KPI_Target__c> showKpi(String visitId){
        List<KPI_Target__c> allKpiTargetRecList  = [Select Id,KPI_Target_Name__c,Monthly_Beat_Plan__c,Roles_and_KPI__c from KPI_Target__c where KPI_Target_Name__c!=null AND Monthly_Beat_Plan__c=:[Select MBPID__c,KPI_Target__c From Visit__c Where  Id =:visitId].MBPID__c];
        
        return allKpiTargetRecList;
    }
    
    // ===============================================================================================================================================================================================================
    @RemoteAction
    global static String tagKIPToVisit(String visitId, String kPIId){
        Visit__c visit = new Visit__c(Id=visitId,KPI_Target__c=kPIId);
        update visit;
        return 'Success';
    }

    // Create Visit For Specifier 
    @RemoteAction
    global static Visit__c createVisitForSpecifier(String SpecifierId,String datestring,String starttime,String endtime, String Description ){
        System.debug('SpecifierId == >'+SpecifierId+' && endtime === >'+endtime+' && starttime === >'+starttime+' && datestring == >'+datestring+' && Description == >'+Description);
        try{
             List<Weekly_Beat_Plan__c> WBPRec=new List<Weekly_Beat_Plan__c>();
            String[] strtTimeSplit = starttime.split(':');
            Time StarttimeChange = Time.newInstance( Integer.valueOf(strtTimeSplit[0]) ,Integer.valueOf(strtTimeSplit[1]),0,0); 
            
            String[] EndTimeSplit = endtime.split(':');
            Time EndtimeChange = Time.newInstance( Integer.valueOf(EndTimeSplit[0]) ,Integer.valueOf(EndTimeSplit[1]),0,0); 
            if(datestring !=null){
                Date selectedDate=Date.valueOf(datestring);
                Integer monthNumber = selectedDate.month();
                Date weekStart = (selectedDate.toStartofWeek().addDays(1));
                Date WeekEndDate=weekStart.addDays(6);
                if(weekStart!=null || WeekEndDate!=null){
                    WBPRec=[Select Id,Start_Day_of_Week__c,End_Day_of_Week__c,Monthly_Beat_Plan__c From Weekly_Beat_Plan__c Where Start_Day_of_Week__c>=:weekStart AND End_Day_of_Week__c<=:WeekEndDate AND OwnerId =:  UserInfo.getUserId() AND Month__c =: monthNumber];
                } 
            } 
            system.debug('WBPRec === >'+WBPRec);
            Visit__c vs = new Visit__c();
            vs.Planned_visit_date__c = Date.valueOf(datestring);
            vs.Actual_visit_date__c = Date.valueOf(datestring);
            vs.Specifier__c = SpecifierId;
            vs.Expected_End_Time__c = StarttimeChange;
            vs.Expected_Start_Time__c = EndtimeChange;
            vs.Visit_Status__c = 'New';
            vs.Assigned_User__c = UserInfo.getUserId();
            if(WBPRec[0].Monthly_Beat_Plan__c !=null){
                vs.Monthly_Beat_Plan__c=WBPRec[0].Monthly_Beat_Plan__c; 
            }
            if(WBPRec[0].Id!=null){
                vs.Weekly_Beat_Plan__c=WBPRec[0].Id; 
            }
            insert vs;
            System.debug('Visit Record Created For Specifier == >'+vs);
            return vs;
        }catch(Exception e){
            ExceptionHelper.createExceptionLog(e);
            System.debug('The Error ::'+e.getMessage() +' AND Error Line No :'+e.getLineNumber());
        }
        return null;  
    }          
        
}