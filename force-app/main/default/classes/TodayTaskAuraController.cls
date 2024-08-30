public without sharing class TodayTaskAuraController {
    
    //method to create a visit record on field visit lead creation
    @AuraEnabled
    public static String createVisitRecord(String leadId) {
        System.debug('Lead Id from field visit ==>' + leadId);
        List<Visit__c> visitList = new List<Visit__c>();
        List<Weekly_Beat_Plan__c> WBPRec = new List<Weekly_Beat_Plan__c>();
        Id mbpId;
        Date selectedDate = Date.today();
        Integer monthNumber = selectedDate.month();
        Date weekStart = selectedDate.toStartOfWeek().addDays(1);
        Date WeekEndDate = weekStart.addDays(6);
        
        if (weekStart != null && WeekEndDate != null) {
            WBPRec = [SELECT Id, Start_Day_of_Week__c, End_Day_of_Week__c, Monthly_Beat_Plan__c  FROM Weekly_Beat_Plan__c   WHERE Start_Day_of_Week__c >= :weekStart  AND End_Day_of_Week__c <= :WeekEndDate  AND OwnerId = :UserInfo.getUserId() AND Month__c = :monthNumber];
        }
        Lead ldRec = [SELECT Id, Mark_Visit_as_Completed__c, Street, City, State, PostalCode, Country,/* StateCode, CountryCode,*/ Latitude, Longitude  FROM Lead  WHERE Id = :leadId];
        for (Weekly_Beat_Plan__c wbp : WBPRec) {
            Visit__c visitRec = new Visit__c();
            visitRec.Lead__c = leadId;
            visitRec.Assigned_User__c = UserInfo.getUserId();
            visitRec.Monthly_Beat_Plan__c = wbp.Monthly_Beat_Plan__c;
            visitRec.Weekly_Beat_Plan__c = wbp.Id;
            visitRec.Planned_visit_date__c = system.today();
            visitRec.Actual_visit_date__c = system.today();
            visitRec.Street__c = ldRec.Street;
            visitRec.City__c=ldRec.City;
            visitRec.State__c = ldRec.State;
            visitRec.Postal_Code__c = ldRec.PostalCode;
            visitRec.Country__c = ldRec.Country;
            visitRec.Geo_Location__Latitude__s = ldRec.Latitude;
            visitRec.Geo_Location__Longitude__s = ldRec.Longitude;
            visitRec.Visit_Status__c = ldRec.Mark_Visit_as_Completed__c ? 'Completed' : 'Assigned';   
            visitList.add(visitRec);
        }
        try {
            if (!visitList.isEmpty()) {
                Insert visitList;
                return 'SUCCESS';
            }
        } catch (Exception e) {
            System.debug('Error creating Visit record: ' + e.getMessage());
            ExceptionHelper.createExceptionLog(e);
        }
        return null;
    }
    
    //method for getting all visit records based on date passed
    @AuraEnabled
    public static todaytaskWrapper getAllVisitToday(String visitDate){
        System.debug('visitDate ===>>'+visitDate);
        List<Visit__c> visitListToShow = new List<Visit__c>();
        try{
            Approval_Process_Requirement__c aList = Approval_Process_Requirement__c.getInstance('Field Visit');
            Boolean isApproval = aList.isApprovalRequired__c;  
            if(String.isNotBlank(visitDate)){
                String[] arrTest = visitDate.split('T');
                string[] dateArray = arrTest[0].split('-');
                Integer year = Integer.valueOf(dateArray[0]);
                Integer month = Integer.valueOf(dateArray[1]);
                Integer day = Integer.valueOf(dateArray[2]);
                date VisitFormatedDate = date.newInstance(year, month, day);
                System.debug('VisitFormatedDate ==>>'+VisitFormatedDate);
                Id currentUserId = UserInfo.getUserId();
                visitListToShow = [SELECT Id, Name, Status__c, Account__c, Duration__c, Account__r.Name, Account__r.Website, Account__r.Email__c, Account__r.Phone,  Visit_Time__c,Visit_Status__c,Check_In_Time__c,
                                   Planned_Visit_Date__c, Weekly_Beat_Plan__c, KPI_Target__c, KPI_Target__r.KPI_Target_Name__c,Account__r.BillingStreet, Lead__r.FirstName, Account__r.BillingCity, Account__r.BillingState,
                                   Account__r.BillingPostalCode,Account__r.BillingCountry,Geo_Location__latitude__s, Geo_Location__longitude__s, Weekly_Beat_Plan__r.Monthly_Beat_Plan__r.Approval_Status__c,Expected_Start_Time__c,
                                   Lead__c, Lead__r.Name, Lead__r.City, Lead__r.Street,Lead__r.PostalCode,Specifier__c,Specifier__r.Name,Specifier__r.Street_Address__c FROM Visit__c 
                                   WHERE Planned_Visit_Date__c=:VisitFormatedDate 
                                   AND (Lead__r.Street != null OR Account__r.BillingStreet != null OR Specifier__r.Street_Address__c != null) 
                                   AND Assigned_User__c=: currentUserId AND Status__c != 'Completed'];
                System.debug('visitListToShow Size == >>'+visitListToShow.size());
                if(visitListToShow.size()>0){
                    integer compVisitCount=0;
                    integer pendingVisitCount =0;
                    boolean approved = false;
                    for(Visit__c vs : visitListToShow){
                        System.debug('Approval Status-->'+ vs.Weekly_Beat_Plan__r.Monthly_Beat_Plan__r.Approval_Status__c);
                        if(vs.Weekly_Beat_Plan__r.Monthly_Beat_Plan__r.Approval_Status__c != null && vs.Weekly_Beat_Plan__r.Monthly_Beat_Plan__r.Approval_Status__c == 'Approved'){
                            approved = true;
                        }
                        if(vs.Status__c == 'Pending'){
                            compVisitCount =  compVisitCount + 1;
                        }
                        if(vs.Status__c == 'Completed'){
                            pendingVisitCount = pendingVisitCount + 1;
                        }
                    }
                    String userId = userInfo.getUserId();
                    system.debug('userId::'+userId);
                    List<Day_Visit_Plan__c> dayVisitList = [SELECT Id FROM Day_Visit_Plan__c WHERE Start_Date__c=today AND Service_Executive__c =: userId];
                    System.debug('dayVisitList === >'+dayVisitList);
                    System.debug('compVisitCount === >'+compVisitCount);
                    System.debug('pendingVisitCount === >'+pendingVisitCount);
                    todaytaskWrapper wrap = new todaytaskWrapper();
                    wrap.isApproved = approved;
                    wrap.visitList = visitListToShow;
                    wrap.completedVisit = compVisitCount;
                    wrap.pendingVisit = pendingVisitCount;
                    wrap.useApprovalProcess = isApproval;
                    if(!dayVisitList.isEmpty()){
                        wrap.dvpList = dayVisitList;
                    }
                    System.debug('wrap Data === >'+wrap);
                    return wrap;
                }
            }
        }catch(Exception e){
            System.debug('The Error ::'+e.getMessage() +' AND Error Line No :'+e.getLineNumber());
            ExceptionHelper.createExceptionLog(e);
        }
        return null;
    }
    
    @AuraEnabled
    public static todaysCompletedTaskWrapper GetCompletedVisitRecords(String visitDate){
        System.debug('visitDate ==>>'+visitDate);
        List<Visit__c> visitListToShow = new List<Visit__c>();
        try{
            if(String.isNotBlank(visitDate)){
                String[] arrTest = visitDate.split('T');
                string[] dateArray = arrTest[0].split('-');
                Integer year = Integer.valueOf(dateArray[0]);
                Integer month = Integer.valueOf(dateArray[1]);
                Integer day = Integer.valueOf(dateArray[2]);
                date VisitFormatedDate = date.newInstance(year, month, day);
                Id currentUserId = UserInfo.getUserId();
                visitListToShow = [SELECT Id, Name, Status__c, Account__c,Lead__c, Duration__c,District__c,Actual_Visit_Date__c, Visit_Objective__c, Taluk__c, Night_stay__c, Account__r.Name, Account__r.Website, Account__r.Email__c, Account__r.Phone,  Visit_Time__c,Visit_Status__c,Check_In_Time__c,
                                   Planned_Visit_Date__c, Weekly_Beat_Plan__c, KPI_Target__c, KPI_Target__r.KPI_Target_Name__c,Account__r.BillingStreet, Account__r.BillingCity, Account__r.BillingState,
                                   Account__r.BillingPostalCode,Account__r.BillingCountry,Geo_Location__latitude__s, Geo_Location__longitude__s,Lead__r.Name, Lead__r.Phone, Lead__r.Email,Lead__r.Street,
                                   Lead__r.City,Lead__r.PostalCode,/*Lead__r.StateCode,Lead__r.CountryCode,*/ Weekly_Beat_Plan__r.Monthly_Beat_Plan__r.Approval_Status__c 
                                   FROM Visit__c 
                                   WHERE Planned_Visit_Date__c=:VisitFormatedDate 
                                   AND ((Account__r.BillingStreet != null AND Account__r.BillingCity != null) OR (Lead__r.Street != null AND Lead__r.City != null))
                                   AND Assigned_User__c=: currentUserId AND Status__c = 'Completed'];
                
                System.debug('visitListToShow----->'+visitListToShow);
                
                if(visitListToShow.size()>0){
                    integer compVisitCount=0;
                    integer pendingVisitCount =0;
                    boolean approved = false;
                    for(Visit__c vs : visitListToShow){
                        System.debug('Approval Status-->'+ vs.Weekly_Beat_Plan__r.Monthly_Beat_Plan__r.Approval_Status__c);
                        if(vs.Weekly_Beat_Plan__r.Monthly_Beat_Plan__r.Approval_Status__c != null && vs.Weekly_Beat_Plan__r.Monthly_Beat_Plan__r.Approval_Status__c == 'Approved'){
                            approved = true;
                        }
                        if(vs.Status__c == 'Pending'){
                            compVisitCount =  compVisitCount + 1;
                        }
                        if(vs.Status__c == 'Completed'){
                            pendingVisitCount = pendingVisitCount + 1;
                        }
                    }
                    String userId = userInfo.getUserId();
                    system.debug('userId::'+userId);
                    List<Day_Visit_Plan__c> dayVisitList = [SELECT Id, Start_Date__c, End_Date__c FROM Day_Visit_Plan__c WHERE Start_Date__c=today AND Service_Executive__c =: userId];
                    System.debug('dayVisitList === >'+dayVisitList);
                    System.debug('compVisitCount === >'+compVisitCount);
                    System.debug('pendingVisitCount === >'+pendingVisitCount);
                    todaysCompletedTaskWrapper wrap = new todaysCompletedTaskWrapper();
                    wrap.isApproved = approved;
                    wrap.completedVisitList = visitListToShow;
                    wrap.completedVisit = compVisitCount;
                    wrap.pendingVisit = pendingVisitCount;
                    if(!dayVisitList.isEmpty()){
                        wrap.dvpList = dayVisitList;
                    }
                    System.debug('wrap Data === >'+wrap);
                    return wrap;
                }
            }
        }catch(Exception e){
            System.debug('The Error ::'+e.getMessage() +' AND Error Line No :'+e.getLineNumber());
            ExceptionHelper.createExceptionLog(e);
        }
        return null;
    }
    
    public class todaysCompletedTaskWrapper{
        @AuraEnabled
        public Integer completedVisit;
        @AuraEnabled
        public Integer pendingVisit;
        @AuraEnabled
        public List<Visit__c> visitList;
        @AuraEnabled
        public List<Visit__c> completedVisitList;
        @AuraEnabled
        public List<Day_Visit_Plan__c> dvpList;
        @AuraEnabled
        public boolean isApproved;
    }
    
    // ==========================================================================================================================================================================================================
    // Method get Selected Vist Recor Details
    @AuraEnabled
    public static Visit__c getSelectedVisitDetails(String visitId){
        Visit__c visitRec = new Visit__c();
        try{
            if(String.isNotBlank(visitId)){
                visitRec = [SELECT Id, Name, Status__c,Visit_Status__c, Lead__c, Account__c, Duration__c, Lead__r.Name, Lead__r.Website, Lead__r.Email, Lead__r.Phone, Account__r.Name, Account__r.Website, Account__r.Email__c, Account__r.Phone,  Account__r.Customer_Contact__c, Lead__r.Street, Lead__r.City, Lead__r.State,Lead__r.PostalCode,Lead__r.Country,
                            Specifier__c,Specifier__r.Name,Specifier__r.Email,Specifier__r.Phone,Specifier__r.Street_Address__c,Specifier__r.City_Address__c,Specifier__r.Zip_Postal_Code__c,Specifier__r.State_Province__c,Specifier__r.Country__c,Street__c,City__c,Postal_Code__c,State__c,Country__c,
                            CheckIn__Latitude__s, Check_Out__Latitude__s, Visit_Time__c,Expected_Start_Time__c,Expected_End_Time__c,Description__c,Actual_visit_date__c, Planned_visit_date__c, Weekly_Beat_Plan__c,Monthly_Beat_Plan__c, KPI_Target__c, KPI_Target__r.KPI_Target_Name__c,Account__r.BillingStreet, Account__r.BillingCity, Account__r.BillingState,Account__r.BillingPostalCode,Account__r.BillingCountry FROM Visit__c WHERE Id=:visitId LIMIT 1];
                if(visitRec !=null){
                    System.debug('visitRec getSelectedVisitDetails === >'+visitRec);
                    return visitRec;
                }else{
                    return null;
                }
            }
        }catch(Exception e){
            System.debug('The Error ::'+e.getMessage() +' AND Error Line No :'+e.getLineNumber());
            ExceptionHelper.createExceptionLog(e);
        }
        return null;
    }
    
    public class todaytaskWrapper{
        @AuraEnabled
        public Integer completedVisit;
        @AuraEnabled
        public Integer pendingVisit;
        @AuraEnabled
        public List<Visit__c> visitList;
        @AuraEnabled
        public List<Day_Visit_Plan__c> dvpList;
        @AuraEnabled
        public List<Visit__c> completedVisitList;
        @AuraEnabled
        public boolean isApproved;
        @AuraEnabled
        public boolean useApprovalProcess;
    }
    
    // ==========================================================================================================================================================================================================
    // Method for Creating Day Visit Plan on Start Day Button Click
    @AuraEnabled
    public static Day_Visit_Plan__c StartDayVisitForVistitRecord(String startLat,String startLang,List<Visit__c> visitRecList){
        System.debug('startLat == >'+startLat + ' && startLang === >'+startLang + ' && visitRecList === >'+visitRecList);
        List<Visit__c> visitListToUpdate = new List<Visit__c>();
        DateTime todayDate = system.now();
        String monthName = todayDate.format('MMMMM');
        Date todayDate2 = system.today();
        String yearName = String.valueOf(todayDate.Year());
        Id currUserId = UserInfo.getUserId();
        Monthly_Travel_Expense__c mte;
        List<Monthly_Travel_Expense__c> mteList = [select id from Monthly_Travel_Expense__c WHERE Month_Name__c =:monthName AND Year__c =:yearName AND Sales_User__c =:currUserId limit 1];
        System.debug('mteList ==>>' + mteList);
        if(mteList.size()==0){
            mte = new Monthly_Travel_Expense__c();
            String mteName = 'MTE - ' + monthName;
            mte.Name = mteName;
            mte.Sales_User__c = currUserId;
            mte.Start_Date__c = todayDate2.toStartOfMonth();
            mte.End_Date__c = todayDate2.addMonths(1).toStartofMonth().addDays(-1);
            insert mte;
        }
        else{
            mte = mteList[0];
        }
        try{
            if(String.isNotBlank(startLat) && string.isNotBlank(startLang)){
                String dayVisitPlanId = null;
                String userId = Userinfo.getUserId();
                Day_Visit_Plan__c vstPlan = new Day_Visit_Plan__c();
                List<Day_Visit_Plan__c> dayVisitPlanList = [SELECT Id, Start_Location__Latitude__s, Start_Location__Longitude__s, Service_Executive__c, Monthly_Travel_Expense__c, Start_Date__c FROM Day_Visit_Plan__c WHERE DAY_ONLY(Start_Date__c) = TODAY AND Service_Executive__c =: userId AND Monthly_Travel_Expense__c =: mte.Id];
                System.debug('dayVisitPlanList-->'+ dayVisitPlanList);
                if(dayVisitPlanList.size() > 0){
                    dayVisitPlanId = dayVisitPlanList[0].Id;
                    vstPlan = dayVisitPlanList[0];
                }
                else{
                    vstPlan = new Day_Visit_Plan__c();
                    vstPlan.Start_Location__Latitude__s = Decimal.valueOf(startLat);
                    vstPlan.Start_Location__Longitude__s = Decimal.valueOf(startLang);
                    vstPlan.Service_Executive__c = Userinfo.getUserId();
                    vstPlan.Monthly_Travel_Expense__c = mte.Id;
                    vstPlan.Start_Date__c = system.now();
                    insert vstPlan;
                    dayVisitPlanId = vstPlan.Id;
                }
                if(String.isNotBlank(dayVisitPlanId)){
                    for(Visit__c vs : visitRecList){ 
                        vs.Visit_Plan__c = dayVisitPlanId;
                        visitListToUpdate.add(vs);
                    }
                    if(visitListToUpdate.size()>0){
                        update visitListToUpdate;
                        System.debug('Updated Visit Record ==== > ' + visitListToUpdate);
                        if(visitListToUpdate.size()>0){
                            System.debug('Day Visit Plan Record Id ==> '+ dayVisitPlanId);
                            return vstPlan;
                        }
                    }
                }
            }
        }catch(Exception e){
            System.debug('The Error ::'+e.getMessage() +' AND Error Line No :'+e.getLineNumber());
            ExceptionHelper.createExceptionLog(e);
        }
        return null;
    }
    
    
    // ==========================================================================================================================================================================================================
    // Method for End Day Visit / Update End Location Update
    @AuraEnabled
    public static Day_Visit_Plan__c updateEndDayVisitRecord(String endLat,String endLong){
        Day_Visit_Plan__c  vstPlan = new Day_Visit_Plan__c();
        vstPlan = [select id from Day_Visit_Plan__c where Service_Executive__c =:UserInfo.getUserId() and Start_Date__c = today LIMIT 1];
        try{
            if(vstPlan != null){
                vstPlan.Id = vstPlan.Id;
                if(endLat != null)
                    vstPlan.End_Location__Latitude__s = Decimal.valueOf(endLat);
                if(endLong != null)
                    vstPlan.End_Location__Longitude__s = Decimal.valueOf(endLong);
                vstplan.End_Date__c = system.now();
                update vstPlan;
                System.debug('Updated Day Visit Plan Record ==== >'+vstPlan);
                return vstPlan;
            }
        }catch(Exception e){
            System.debug('The Error ::'+e.getMessage() +' AND Error Line No :'+e.getLineNumber());
            ExceptionHelper.createExceptionLog(e);
        }
        return null;
    }
    
    // ==========================================================================================================================================================================================================
    // Method for Ahmed Visit Update
    @AuraEnabled
    public static Visit__c updateAmendVisitRecord(Visit__c visitRec){
        Visit__c vsRec = new Visit__c();
        try{
            if(visitRec != null){
                update visitRec;
            }
            System.debug('visitRec === >'+visitRec);
            return visitRec;
        }catch(Exception e){
            System.debug('The Error ::'+e.getMessage() +' AND Error Line No :'+e.getLineNumber());
            ExceptionHelper.createExceptionLog(e);
        }
        return null;
    }
    
    //==========================================================================================================================================================================================================
    @AuraEnabled
    public static void saveTask(Task taskRec){
        try{
            if(taskRec !=null){
                System.debug('taskRec === >'+taskRec);
                taskRec.OwnerId = userInfo.getUserId();
                taskRec.ActivityDate = System.Today();
                insert taskRec;
            }
        }catch(Exception e){
            System.debug('The Error ::'+e.getMessage() +' AND Error Line No :'+e.getLineNumber());
            ExceptionHelper.createExceptionLog(e);
        }
    }
    
    //==========================================================================================================================================================================================================
    @AuraEnabled
    public static void LogCall(Task taskRec){
        try{
            if(taskRec !=null){
                System.debug('taskRec === >'+taskRec);
                taskRec.OwnerId = userInfo.getUserId();
                insert taskRec;
            }
        }catch(Exception e){
            System.debug('The Error ::'+e.getMessage() +' AND Error Line No :'+e.getLineNumber());
            ExceptionHelper.createExceptionLog(e);
        }
    }
    
    //==========================================================================================================================================================================================================
    @AuraEnabled
    public static void saveOpportunity(Opportunity oppRec){
        try{
            if(oppRec !=null){
                System.debug('oppRec === >'+oppRec);
                insert oppRec;
            }
        }catch(Exception e){
            System.debug('The Error ::'+e.getMessage() +' AND Error Line No :'+e.getLineNumber());
            ExceptionHelper.createExceptionLog(e);
        }
    }
    
    //==========================================================================================================================================================================================================
    @AuraEnabled
    public static void saveCase(Case caseRec){
        String userId = userInfo.getUserId();
        try{
            if(caseRec !=null){
                System.debug('caseRec === >'+caseRec);
                caseRec.OwnerId = userId;
                insert caseRec;
            }
        }catch(Exception e){
            System.debug('The Error ::'+e.getMessage() +' AND Error Line No :'+e.getLineNumber());
            ExceptionHelper.createExceptionLog(e);
        }
    }
    
    //==========================================================================================================================================================================================================
    // Method for Check in on Visit Record
    @AuraEnabled
    public static Visit__c  checkInUpdateVisit(String checkInLat,String checkInLang, String recId){
        System.debug('checkInLat--> ' + checkInLat + 'checkInLang--> '+ checkInLang + 'recId--> '+ recId);
        Visit__c visRec = [SELECT Id,Name,Actual_visit_date__c,CheckIn__Latitude__s,CheckIn__Longitude__s, Check_Out__Latitude__s, Check_Out__Longitude__s, Visit_Status__c FROM Visit__c WHERE Id=:recId];
        System.debug('visRec--> ' + visRec);
        try{
            if(String.isNotBlank(checkInLat) && String.isNotBlank(checkInLang)){
                visRec.CheckIn__Latitude__s = Decimal.valueOf(checkInLat);
                visRec.CheckIn__Longitude__s =  Decimal.valueOf(checkInLang);
                visRec.Visit_Status__c = 'In Progress';
                visRec.Check_In_Time__c = System.now();
                update visRec;
                System.debug('Check In Visit Update Record === >'+visRec);
                return visRec;
            }
        }catch(Exception e){
            System.debug('The Error ::'+e.getMessage() +' AND Error Line No :'+e.getLineNumber());
            ExceptionHelper.createExceptionLog(e);
        }
        return null;
    }
    
    //==========================================================================================================================================================================================================
    // Method for Check Out in Visit Record
    @AuraEnabled
    public static Visit__c checkOutUpdateVisit(String checkOutLat,string checkOutLong, String recId){
        System.debug('checkOutLat--> ' + checkOutLat + 'checkOutLong--> '+ checkOutLong + 'recId--> '+ recId);
        Visit__c visRec =[SELECT Id,Name,Actual_visit_date__c,CheckIn__Latitude__s,CheckIn__Longitude__s, Check_Out__Latitude__s, Check_Out__Longitude__s, Visit_Status__c,Visit_Plan__c FROM Visit__c WHERE Id=:recId];
        System.debug('visRec--> ' + visRec);
        try{
            if(String.isNotBlank(checkOutLat) && String.isNotBlank(checkOutLong)){
                // location visitCheckOut = location.newInstance(Decimal.valueOf(checkOutLat),Decimal.valueOf(checkOutLong));
                Day_Visit_Plan__c updateLocationDis=[SELECT id,Name,Start_Location__c,End_Location__c from Day_Visit_Plan__c WHERE id=:visRec.Visit_Plan__c ];
                visRec.Check_Out__Latitude__s = Decimal.valueOf(checkOutLat);
                visRec.Check_Out__Longitude__s =  Decimal.valueOf(checkOutLong);
                visRec.Visit_Status__c = 'COMPLETED';
                visRec.Check_Out_Time__c = System.now();
                // visRec.Distance_Km__c=Location.getDistance(updateLocationDis.Start_Location__c, visitCheckOut, 'km') != null ? Location.getDistance(updateLocationDis.Start_Location__c, visitCheckOut, 'km') : null;
                // Location.getDistance(updateLocationDis.Start_Location__c, visitCheckOut, 'km');
                update visRec;
                System.debug('Check Out Visit Update Record === >'+visRec);
                
                Day_Visit_Plan__c updatDayVsitStartLocation  = new Day_Visit_Plan__c();
                updatDayVsitStartLocation.Start_Location__Latitude__s=Decimal.valueOf(checkOutLat);
                updatDayVsitStartLocation.Start_Location__Longitude__s=Decimal.valueOf(checkOutLong);
                updatDayVsitStartLocation.id=updateLocationDis.id;
                update updatDayVsitStartLocation;
                System.debug('Day Visit Plan Update Record === >'+updatDayVsitStartLocation);
                return visRec;
            }
        }catch(Exception e){
            System.debug('The Error ::'+e.getMessage() +' AND Error Line No :'+e.getLineNumber());
            ExceptionHelper.createExceptionLog(e);
        }
        return null;
    }
    
    //==========================================================================================================================================================================================================
    // Method for getting Past Visit Records
    @AuraEnabled
    public static List<Visit__c> getPastVisitDetails(String accId){
        String userId = UserInfo.getUserId();
        List<Visit__c> pastVisitList = new List<Visit__c>();
        try{
            if(String.isNotBlank(userId)){
                pastVisitList = [SELECT Id, Name, Status__c, Account__c, Duration__c, Account__r.Name, Account__r.Website, Account__r.Email__c, Account__r.Phone,  
                                 Visit_Time__c, Planned_visit_date__c, Weekly_Beat_Plan__c, KPI_Target__c, KPI_Target__r.KPI_Target_Name__c,Account__r.BillingStreet, 
                                 Account__r.BillingCity, Account__r.BillingState,Account__r.BillingPostalCode, Check_In_Time__c, Visit_Status__c, Account__r.BillingCountry, Actual_visit_date__c,
                                 KPI_Target_Name__c FROM Visit__c WHERE Assigned_User__c=:userId AND Actual_visit_date__c < today AND (Account__c =: accId OR Lead__c =: accId)];
                if(pastVisitList !=null){
                    System.debug('pastVisitList === >'+pastVisitList);
                    return pastVisitList;
                }
            }
        }catch(Exception e){
            System.debug('The Error ::'+e.getMessage() +' AND Error Line No :'+e.getLineNumber());
            ExceptionHelper.createExceptionLog(e);
        }
        return null;
    }
    
    //==========================================================================================================================================================================================================
    // Method for getting Related Opportunities List
    @AuraEnabled
    public static List<Opportunity> getRelOppList(String accId){
        List<Opportunity> oppList = new List<Opportunity>();
        try{
            if(String.isNotBlank(accId)){
                oppList = [SELECT Id, Name, StageName, CloseDate, LeadSource FROM Opportunity WHERE AccountId=:accId order by createdDate desc ];
                if(oppList !=null){
                    System.debug('oppList === >'+oppList);
                    return oppList;
                }
            }
        }catch(Exception e){
            System.debug('The Error ::'+e.getMessage() +' AND Error Line No :'+e.getLineNumber());
            ExceptionHelper.createExceptionLog(e);
        }
        return null;
    }
    
    @AuraEnabled
    public static List<Invoices__c> getRelInvoiceList(String accId){
        List<Invoices__c> invList = new List<Invoices__c>();
        String userId = userInfo.getUserId();
        try{
            if(String.isNotBlank(accId)){
                invList = [SELECT Id, Name, Amount__c, Status__c, Initiated_Amount__c, Realized_Amount__c, Invoice_Date__c, Account__c FROM Invoices__c WHERE Account__c=:accId AND OwnerId=:userId LIMIT 10];
                if(invList !=null){
                    System.debug('invList === >'+invList);
                    return invList;
                }
            }
        }catch(Exception e){
            System.debug('The Error ::'+e.getMessage() +' AND Error Line No :'+e.getLineNumber());
            ExceptionHelper.createExceptionLog(e);
        }
        return null;
    }
    
    @AuraEnabled
    public static List<Case> getRelCaseList(String accId){
        List<Case> caseList = new List<Case>();
        String userId = userInfo.getUserId();
        try{
            if(String.isNotBlank(accId)){
                caseList = [SELECT Id, CaseNumber, Origin, Case_Status__c, Status, Description, Reason, AccountId FROM Case WHERE AccountId=:accId AND OwnerId=:userId LIMIT 10];
                if(caseList !=null){
                    System.debug('caseList === >'+caseList);
                    return caseList;
                }
            }
        }catch(Exception e){
            System.debug('The Error ::'+e.getMessage() +' AND Error Line No :'+e.getLineNumber());
            ExceptionHelper.createExceptionLog(e);
        }
        return null;
    }
    
    @AuraEnabled
    public static List<Task> getRelTaskList(String accId){
        List<Task> taskList = new List<Task>();
        String userId = userInfo.getUserId();
        try{
            if(String.isNotBlank(accId)){
                taskList = [SELECT Id, OwnerId, ActivityDate, Priority, Status, Subject, Type FROM Task WHERE (WhatId=:accId OR WhoId =: accId) AND OwnerId=:userId LIMIT 10];
                if(taskList !=null){
                    System.debug('taskList === >'+taskList);
                    return taskList;
                }
            }
        }catch(Exception e){
            System.debug('The Error ::'+e.getMessage() +' AND Error Line No :'+e.getLineNumber());
            ExceptionHelper.createExceptionLog(e);
        }
        return null;
    }
    
    // ===========================================================================================================================================================================================================
    // Method for Creating Activit Mom Log and Send Email to Enter Stock Email
    @AuraEnabled
    public static String createMomActivityLog(String description, String visitId,String subject,String salesUserId,string stackholderEmail){
        List<Messaging.SingleEmailMessage> mailList = new List<Messaging.SingleEmailMessage>();
        String accId = [Select Id, Account__c from Visit__c where Id = : visitId].Account__c;
        EmailTemplate temp = [SELECT Id,Subject,Body,HTMLValue FROM EmailTemplate WHERE Name ='Mom Activity Created Mail'];
        String htmlBody = temp.HTMLValue;
        String plainTextBody = temp.body;
        Visit__c visitRec = new Visit__c();
        OrgWideEmailAddress owea = [ SELECT Id, Address, DisplayName FROM OrgWideEmailAddress where DisplayName = 'Symega Food Ingredients Limited' ];
        system.debug('owea ==>>'+owea);
        try{
            if(subject !=null && visitId !=null && accId !=null){
                visitRec = [SELECT Id,Name FROM Visit__c WHERE ID=:visitId LIMIT 1];
                system.debug('visitRec === >'+visitRec);
                Task taskRec = new Task();
                taskRec.WhatId	= accId;
                taskRec.Visit__c = visitId;
                taskRec.ActivityDate = System.today();
                if(description !=null){
                    taskRec.Description = description;
                }
                if(salesUserId !=null){
                    taskRec.knowlarity_cti__Second_Agent__c = salesUserId;
                }
                if(stackholderEmail !=null){
                    taskRec.Stakeholder_Email__c = stackholderEmail;
                }
                taskRec.Subject = subject;
                taskRec.Priority = 'Normal';
                taskRec.Status = 'Open';
                taskRec.CurrencyIsoCode = 'INR';
                taskRec.OwnerId = userInfo.getUserId();
                insert taskRec;
                system.debug('Mom Activity record === >'+taskRec);
                if(taskRec !=null){
                    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                    htmlBody = htmlBody.replace('{!Visit__c.Name}', visitRec.Name);
                    htmlBody = htmlBody.replace('{!Subject}', taskRec.Subject);
                    htmlBody = htmlBody.replace('{!Description}', taskRec.Description);
                    
                    plainTextBody = plainTextBody.replace('{!Visit__c.Name}', visitRec.Name);
                    plainTextBody = plainTextBody.replace('{!Subject}', taskRec.Subject);
                    plainTextBody = plainTextBody.replace('{!Description}', taskRec.Description);
                    
                    mail.setHtmlBody(htmlBody);
                    mail.setSubject(temp.Subject);
                    mail.setPlainTextBody(plainTextBody);
                    mail.toAddresses = new String[] {stackholderEmail};
                        mail.setReplyTo(owea.Address);
                    mail.setOrgWideEmailAddressId(owea.Id);
                    mailList.add(mail);
                    if(!mailList.isEmpty()){
                        Messaging.sendEmail(mailList);
                        return 'SUCCESS';
                    }
                }else{
                    return 'Something Went wrong !';
                }
            }
        }catch(Exception e){
            system.debug('Error == >'+e.getMessage()+' && Error Line === >'+e.getLineNumber());
            ExceptionHelper.createExceptionLog(e);
        }
        return null;
    }
    
    // ===========================================================================================================================================================================================================
    @AuraEnabled
    public static String createMomActivityLog1(String description, String visitId,String accId,String subject,String salesUserId,string stackholderEmail){
        List<Messaging.SingleEmailMessage> mailList = new List<Messaging.SingleEmailMessage>();
        EmailTemplate temp = [SELECT Id,Subject,Body,HTMLValue FROM EmailTemplate WHERE Name ='Mom Activity Created Mail'];
        String htmlBody = temp.HTMLValue;
        String plainTextBody = temp.body;
        Id currentuserId = UserInfo.getUserId();
        Visit__c visitRec = new Visit__c();
        OrgWideEmailAddress owea = [ SELECT Id, Address, DisplayName FROM OrgWideEmailAddress where DisplayName = 'Anjali Singh' ];
        system.debug('owea--->'+owea);
        try{
            salesUserId = UserInfo.getUserId();
            system.debug('salesUserId---->'+ salesUserId);
            if(subject !=null && visitId !=null && accId !=null){
                visitRec = [SELECT Id,Name FROM Visit__c WHERE ID=:visitId LIMIT 1];
                system.debug('visitRec === >'+visitRec);
                Task taskRec = new Task();
                taskRec.ActivityDate = System.today();
                if(accId.startsWith('001')){
                    taskRec.WhatId	= accId;
                }
                else{
                    taskRec.WhoId = accId;
                }
                taskRec.Visit__c = visitId;
                if(description !=null){
                    taskRec.Description = description;
                }
                if(salesUserId !=null){
                    taskRec.knowlarity_cti__Second_Agent__c = salesUserId;
                }
                if(stackholderEmail !=null){
                    taskRec.Stakeholder_Email__c = stackholderEmail;
                }
                taskRec.Subject = subject;
                taskRec.Priority = 'Normal';
                taskRec.Status = 'Open';
                taskRec.CurrencyIsoCode = 'INR';
                taskRec.OwnerId = userInfo.getUserId();
                insert taskRec;
                system.debug('Mom Activity record === >'+taskRec);
                if(taskRec !=null){
                    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                    htmlBody = htmlBody.replace('{!Visit__c.Name}', visitRec.Name);
                    htmlBody = htmlBody.replace('{!Subject}', taskRec.Subject);
                    htmlBody = htmlBody.replace('{!Description}', taskRec.Description);
                    
                    plainTextBody = plainTextBody.replace('{!Visit__c.Name}', visitRec.Name);
                    plainTextBody = plainTextBody.replace('{!Subject}', taskRec.Subject);
                    plainTextBody = plainTextBody.replace('{!Description}', taskRec.Description);
                    
                    mail.setHtmlBody(htmlBody);
                    mail.setSubject(temp.Subject);
                    mail.setPlainTextBody(plainTextBody);
                    mail.toAddresses = new String[] {stackholderEmail};
                        User salesUser = [SELECT Id, email FROM User WHERE Id = :salesUserId LIMIT 1];
                    User currentuser = [SELECT Id, Manager.Email FROM User WHERE Id = :currentuserId LIMIT 1];
                    if (salesUser != null && salesUser.email != null) {
                        mail.setCcAddresses(new String[]{salesUser.email});
                    }
                    if(currentuser != null && currentuser.Manager != null && currentuser.Manager.Email != null){
                        mail.setCcAddresses(new String[]{currentuser.Manager.Email});
                    }
                    mailList.add(mail);
                    if(!mailList.isEmpty()){
                        Messaging.sendEmail(mailList);
                        return 'SUCCESS';
                    }
                }else{
                    return 'Something Went wrong !';
                }
            }
        }catch(Exception e){
            system.debug('Error == >'+e.getMessage()+' && Error Line === >'+e.getLineNumber());
            ExceptionHelper.createExceptionLog(e);
        }
        return null;
    }
    
    // ===========================================================================================================================================================================================================
    // Method for Creating Activit Mom Log and Send Email to Enter Stock Email
    @AuraEnabled 
    public static string checkMomActivityBeforeCheckOutVisit(string visitId){
        List<Task> momTaskList = new List<Task>();
        try{
            if(visitId !=null){
                momTaskList = [SELECT  Id,Subject,Visit__c FROM Task WHERE Visit__c=:visitId LIMIT 1];
                if(momTaskList.size()>0){
                    return 'SUCCESS';
                }else{
                    return 'ERROR';
                }
            }
        }catch(Exception e){
            System.debug('The Error ::'+e.getMessage() +' AND Error Line No :'+e.getLineNumber());
            ExceptionHelper.createExceptionLog(e);
        }
        return null;
    }
    
    // ===========================================================================================================================================================================================================
    //Added by Anjali
    @AuraEnabled
    public static Map<String, Object> getAllCustomerAddress(String custId){
        try {
            Map<String, Object> returnWrapperMap = new Map<String, Object>();
            List<CustomerAddressWrapper> customerShippingAddressWrapper = new List<CustomerAddressWrapper>();
            List<CustomerAddressWrapper> customerBillingAddressWrapper = new List<CustomerAddressWrapper>();
            System.debug('--- custId'+custId);
            if(!String.isBlank(custId)) {
                Account customerAcc = [SELECT Id, Name, Customer_Contact__c, CurrencyIsoCode, BillingState, BillingStreet, BillingCountry, BillingPostalCode, BillingCity, GST_Number__c, ShippingState, ShippingStreet, ShippingCountry, ShippingCity, ShippingPostalCode, AccountSource FROM Account WHERE Id = :custId];
                if(customerAcc != null && !String.isBlank(customerAcc.BillingCountry)) {
                    customerBillingAddressWrapper.add(new CustomerAddressWrapper('Billing', customerAcc.BillingStreet, customerAcc.BillingState, customerAcc.BillingCountry, customerAcc.BillingCity, customerAcc.BillingPostalCode, customerAcc.GST_Number__c, 'Billing', true));
                    returnWrapperMap.put('ship_selected_index', 0);
                }
                if(customerAcc != null && !String.isBlank(customerAcc.ShippingCountry)) {
                    customerShippingAddressWrapper.add(new CustomerAddressWrapper('Shipping', customerAcc.ShippingStreet, customerAcc.ShippingState, customerAcc.ShippingCountry, customerAcc.ShippingCity, customerAcc.ShippingPostalCode, customerAcc.GST_Number__c, 'Shipping', true));
                    returnWrapperMap.put('bill_selected_index', 0);
                }
                
                for(Dispatch_Address__c custAddress :[SELECT Id, Address__Street__s, ToLabel(Address__StateCode__s), Address__PostalCode__s, GST_Number__c, ToLabel(Address__CountryCode__s), Address__City__s, Type__c FROM Dispatch_Address__c WHERE Account__c =:custId]) {
                    if(custAddress.Type__c == 'Billing') {
                        customerBillingAddressWrapper.add(new customerAddressWrapper(custAddress.Id, custAddress.Address__Street__s, custAddress.Address__StateCode__s, custAddress.Address__CountryCode__s, custAddress.Address__City__s, custAddress.Address__PostalCode__s, custAddress.GST_Number__c, custAddress.Type__c, false));
                    }else {
                        customerShippingAddressWrapper.add(new customerAddressWrapper(custAddress.Id, custAddress.Address__Street__s, custAddress.Address__StateCode__s, custAddress.Address__CountryCode__s, custAddress.Address__City__s, custAddress.Address__PostalCode__s, custAddress.GST_Number__c, custAddress.Type__c, false));
                    }
                }
                returnWrapperMap.put('account', customerAcc);
                returnWrapperMap.put('customer_ship_addresses', customerShippingAddressWrapper);
                returnWrapperMap.put('customer_bill_addresses', customerBillingAddressWrapper);
                System.debug('--- response Wrapper '+returnWrapperMap);
            }
            return returnWrapperMap;
        } catch (Exception e) {
            ExceptionHelper.createExceptionLog(e);
        }
        return null;
    }
    
    public class CustomerAddressWrapper {
        @auraEnabled
        public String id;
        @auraEnabled
        public String street;
        @auraEnabled
        public String state;
        @auraEnabled
        public String country;
        @auraEnabled
        public String city;
        @auraEnabled
        public String gstNumber;
        @auraEnabled
        public String type;
        @AuraEnabled
        public String postalCode;
        @AuraEnabled
        public Boolean checked;
        
        public CustomerAddressWrapper(String id, String street, String state, String country, String city, String postalCode, String gstNumber, String type, Boolean checked) {
            this.id = id;
            this.street = street;
            this.state = state;
            this.country = country;
            this.city = city;
            this.gstNumber = gstNumber;
            this.postalCode = postalCode;
            this.type = type;
            this.checked = checked;
        }
    }
    
    //========================================================================================================================================
    //Method to get picklist for Route
    @AuraEnabled 
    public static Map<String, List<String>> getDependentPicklist(sObject objDetail, string contrfieldApiName,string depfieldApiName) {
        String controllingField = contrfieldApiName.toLowerCase();
        String dependentField = depfieldApiName.toLowerCase();
        
        Map<String,List<String>> objResults = new Map<String,List<String>>();
        
        Schema.sObjectType objType = objDetail.getSObjectType();
        if (objType==null){
            return objResults;
        }
        
        Map<String, Schema.SObjectField> objFieldMap = objType.getDescribe().fields.getMap();
        
        if (!objFieldMap.containsKey(controllingField) || !objFieldMap.containsKey(dependentField)){
            return objResults;     
        }
        
        Schema.SObjectField theField = objFieldMap.get(dependentField);
        Schema.SObjectField ctrlField = objFieldMap.get(controllingField);
        
        List<Schema.PicklistEntry> contrEntries = ctrlField.getDescribe().getPicklistValues();
        List<PicklistEntryWrapper> depEntries = wrapPicklistEntries(theField.getDescribe().getPicklistValues());
        List<String> controllingValues = new List<String>();
        
        for (Schema.PicklistEntry ple : contrEntries) {
            String label = ple.getLabel();
            objResults.put(label, new List<String>());
            controllingValues.add(label);
        }
        
        for (PicklistEntryWrapper plew : depEntries) {
            String label = plew.label;
            String validForBits = base64ToBits(plew.validFor);
            for (Integer i = 0; i < validForBits.length(); i++) {
                String bit = validForBits.mid(i, 1);
                if (bit == '1') {
                    objResults.get(controllingValues.get(i)).add(label);
                }
            }
        }
        return objResults;
    }
    
    public static String decimalToBinary(Integer val) {
        String bits = '';
        while (val > 0) {
            Integer remainder = Math.mod(val, 2);
            val = Integer.valueOf(Math.floor(val / 2));
            bits = String.valueOf(remainder) + bits;
        }
        return bits;
    }
    
    public static String base64ToBits(String validFor) {
        if (String.isEmpty(validFor)) return '';
        
        String validForBits = '';
        
        for (Integer i = 0; i < validFor.length(); i++) {
            String thisChar = validFor.mid(i, 1);
            Integer val = base64Chars.indexOf(thisChar);
            String bits = decimalToBinary(val).leftPad(6, '0');
            validForBits += bits;
        }
        
        return validForBits;
    }
    
    private static final String base64Chars = '' +
        'ABCDEFGHIJKLMNOPQRSTUVWXYZ' +
        'abcdefghijklmnopqrstuvwxyz' +
        '0123456789+/';
    
    private static List<PicklistEntryWrapper> wrapPicklistEntries(List<Schema.PicklistEntry> PLEs) {
        return (List<PicklistEntryWrapper>)
            JSON.deserialize(JSON.serialize(PLEs), List<PicklistEntryWrapper>.class);
    }
    
    public class PicklistEntryWrapper{
        public String active {get;set;}
        public String defaultValue {get;set;}
        public String label {get;set;}
        public String value {get;set;}
        public String validFor {get;set;}
        public PicklistEntryWrapper(){            
        }   
    }
    
    // ===========================================================================================================================================================================================================
    @AuraEnabled 
    public static Map<String, Map<String, List<Route_Master__c>>> populateRoute(String city1,String state1){
        List<Route_Master__c> routeRecords = [SELECT Id, State__c, City__c,Name FROM Route_Master__c WHERE City__c =:city1 AND State__c =:state1];
        System.debug('city1=>'+city1);
        System.debug('state1=>'+state1);
        Map<String, Map<String, List<Route_Master__c>>> routeMap = new Map<String, Map<String, List<Route_Master__c>>>();
        for(Route_Master__c rc: routeRecords) {
            String state = rc.State__c;
            String city = rc.City__c;
            String routeName = rc.Name;
            if(!routeMap.containsKey(state)) {
                routeMap.put(state, new Map<String, List<Route_Master__c>>());
            }
            Map<String, List<Route_Master__c>> cityRouteMap = routeMap.get(state);
            if(!cityRouteMap.containsKey(city)) {
                cityRouteMap.put(city, new List<Route_Master__c>());
            }
            cityRouteMap.get(city).add(rc);
        }
        return routeMap;
    }
    
    @AuraEnabled
    public static list<User> getSalesUser(){
        Id currUserId = UserInfo.getUserId();
        //List<User> salesUsers = [SELECT Id, Name FROM User WHERE Manager.Id = :currUserId AND Profile.Name = 'Sales User'];
        List<User> salesUsers = [SELECT Id, Name FROM User WHERE Profile.Name = 'Sales User'];
        return salesUsers;   
    }
    
    // ===========================================================================================================================================================================================================
    @AuraEnabled
    public static void saveRoute(String city, String state, String routeName, String salesUser) {
        try {
            System.debug('city==> ' + city);
            System.debug('state==> ' + state);
            System.debug('routeName==> ' + routeName);
            System.debug('salesUser==> ' + salesUser);
            Id currUserId = UserInfo.getUserId();
            Route__c newRoute = new Route__c();
            newRoute.City__c = city;
            newRoute.State__c = state;
            newRoute.Route_Master__c = routeName; 
            newRoute.Sales_User__c = salesUser;
            System.debug('newRoute==> ' + newRoute);
            insert newRoute;
        } catch (Exception e) {
            ExceptionHelper.createExceptionLog(e);
        }
    }
    
    @AuraEnabled
    public static void createRouteMaster(String routeName, String city, String state){
        try{
            Route_Master__c rMaster = new Route_Master__c();
            rMaster.City__c = city;
            rMaster.State__c = state;
            rMaster.Name = routeName;
            insert rMaster;
        }catch(Exception e) {
            ExceptionHelper.createExceptionLog(e);
        }
    }
    
    @AuraEnabled
    public static List<Visit__c> getTodayVisitRecordsListNew(){
        List<Visit__c> visitLst =[select Id, Name, Account__c  from Visit__c  where CreatedDate  = today];
        return visitLst;
    }
    
    // ===========================================================================================================================================================================================================
    @AuraEnabled
    public static void StartDayVisitForNewVisits(String startLat, String startLang, String visitId){
        System.debug('startLat == >'+startLat + ' && startLang === >'+startLang + ' && visitId === >'+visitId);
        List<Visit__c> visitListToUpdate = new List<Visit__c>();
        Visit__c visitRec = [SELECT Id, Visit_Plan__c FROM Visit__c WHERE Id =: visitId];
        if(visitRec.Visit_Plan__c == null){
            DateTime todayDateTime = system.now();
            String monthName = todayDateTime.format('MMMMM');
            Date todayDate2 = system.today();
            String yearName = String.valueOf(todayDateTime.Year());
            Id currUserId = UserInfo.getUserId();
            Monthly_Travel_Expense__c mte;
            List<Monthly_Travel_Expense__c> mteList = [select id from Monthly_Travel_Expense__c WHERE Month_Name__c =:monthName AND Year__c =:yearName AND Sales_User__c =:currUserId limit 1];
            System.debug('mteList-->' + mteList);
            if(mteList.size()==0){
                mte = new Monthly_Travel_Expense__c();
                String mteName = 'MTE - ' + monthName;
                mte.Name = mteName;
                mte.Sales_User__c = currUserId;
                mte.Start_Date__c = todayDate2.toStartOfMonth();
                mte.End_Date__c = todayDate2.addMonths(1).toStartofMonth().addDays(-1);
                insert mte;
            }
            else{
                mte = mteList[0];
            }
            try{
                if(String.isNotBlank(startLat) && string.isNotBlank(startLang)){
                    String dayVisitPlanId = null;
                    String userId = Userinfo.getUserId();
                    Date todayDate = Date.today();
                    
                    System.debug('todayDate-->'+ todayDate);
                    System.debug('userId-->'+ userId);
                    System.debug('mte.Id-->'+ mte.Id);
                    
                    List<Day_Visit_Plan__c> dayVisitPlanList = [SELECT Id FROM Day_Visit_Plan__c WHERE DAY_ONLY(Start_Date__c) = TODAY AND Service_Executive__c =: userId AND Monthly_Travel_Expense__c =: mte.Id];
                    System.debug('dayVisitPlanList-->'+ dayVisitPlanList);
                    if(dayVisitPlanList.size() > 0){
                        dayVisitPlanId = dayVisitPlanList[0].Id;
                    }
                    else{
                        Day_Visit_Plan__c vstPlan = new Day_Visit_Plan__c();
                        vstPlan.Start_Location__Latitude__s = Decimal.valueOf(startLat);
                        vstPlan.Start_Location__Longitude__s = Decimal.valueOf(startLang);
                        vstPlan.Service_Executive__c = Userinfo.getUserId();
                        vstPlan.Monthly_Travel_Expense__c = mte.Id;
                        vstPlan.Start_Date__c = system.now();
                        insert vstPlan;
                        dayVisitPlanId = vstPlan.Id;
                    }
                    System.debug('dayVisitPlanId-->'+ dayVisitPlanId);
                    if(String.isNotBlank(dayVisitPlanId)){
                        visitRec.Visit_Plan__c = dayVisitPlanId;
                        update visitRec;
                        System.debug('Updated Visit Record ==== > ' + visitRec);
                    }
                }
            }
            catch(Exception e){
                System.debug('The Error ::'+e.getMessage() +' AND Error Line No :'+e.getLineNumber());
                ExceptionHelper.createExceptionLog(e);
            }
        }
    }
    
    // ============================================================================================================================================================================================================
    @AuraEnabled
    public Static List<String> getPickListValuesMethod(String ObjectApi_name, String Field_Name){
        try{
            List<String> lstPickvals                        = new List<String>();
            Schema.SObjectType targetType                   = Schema.getGlobalDescribe().get(ObjectApi_name);
            Sobject Object_name                             = targetType.newSObject();
            Schema.sObjectType sobject_type                 = Object_name.getSObjectType(); 
            Schema.DescribeSObjectResult sobject_describe   = sobject_type.getDescribe();
            Map<String, Schema.SObjectField> field_map      = sobject_describe.fields.getMap();
            List<Schema.PicklistEntry> pick_list_values     = field_map.get(Field_Name).getDescribe().getPickListValues();
            
            for (Schema.PicklistEntry a : pick_list_values) {
                lstPickvals.add(String.ValueOf(a.getLabel()).trim());  
            }
            System.debug('lstPickvals>>>> ::'+lstPickvals);
            return lstPickvals;
        }Catch(Exception e){
            System.debug('The Error ::'+e.getMessage() +' AND Error Line No :'+e.getLineNumber());
        }
        return null;
    }
    
    // Coede to Make Standard Funcationlity into Custom - Dinesh
    // GetVisitRecord For Update
    @AuraEnabled 
    public static visit__c updateVisitDetails(String VisitStringToUpdatedata){
        System.debug('VisitStringToUpdatedata JSON === >'+VisitStringToUpdatedata);
        try{
            Map<String, Object> jsonMap = (Map<String, Object>) JSON.deserializeUntyped(VisitStringToUpdatedata);
            Visit__c visitRecUpdate = new Visit__c();
            visitRecUpdate.Id = (String) jsonMap.get('Id') ?? null;
            if((String) jsonMap.get('Visit_Status__c') !=null && (String) jsonMap.get('Visit_Status__c') != ''){
                visitRecUpdate.Visit_Status__c = (String) jsonMap.get('Visit_Status__c');
            }
            visitRecUpdate.Specifier__c = (String) jsonMap.get('Specifier__c') ?? '';
            visitRecUpdate.Street__c = (String) jsonMap.get('Street__c') ?? '';
            visitRecUpdate.City__c = (String) jsonMap.get('City__c') ?? '';
            visitRecUpdate.Postal_Code__c = (String) jsonMap.get('Postal_Code__c') ?? '';
            visitRecUpdate.State__c = (String) jsonMap.get('State__c') ?? '';
            visitRecUpdate.Country__c = (String) jsonMap.get('Country__c') ?? '';
            visitRecUpdate.Description__c = (String) jsonMap.get('Description__c') ?? '';
            visitRecUpdate.Planned_visit_date__c = Date.valueOf((String) jsonMap.get('Planned_visit_date__c') ?? Date.today().format());
            if((String) jsonMap.get('Actual_visit_date__c') !=null & (String) jsonMap.get('Actual_visit_date__c')  !=''){
                System.debug('Yes');
                visitRecUpdate.Actual_visit_date__c = Date.valueOf((String) jsonMap.get('Actual_visit_date__c') ?? Date.today().format());
            }
            String StartTime = (String) jsonMap.get('Expected_Start_Time__c');
            String[] strStartTimeTimeSplit = StartTime.split(':');
            visitRecUpdate.Expected_Start_Time__c=Time.newInstance(Integer.valueOf(strStartTimeTimeSplit[0]),Integer.valueOf(strStartTimeTimeSplit[1]),0 ,0);
            String EndTime = (String) jsonMap.get('Expected_End_Time__c');
            String[] EndTimeTimeSplit = EndTime.split(':');
            visitRecUpdate.Expected_End_Time__c=Time.newInstance(Integer.valueOf(EndTimeTimeSplit[0]),Integer.valueOf(EndTimeTimeSplit[1]),0 ,0);
            
            update visitRecUpdate;
            if(visitRecUpdate !=null){
                System.debug('visitRecUpdate Updated === >'+visitRecUpdate);
                return visitRecUpdate;
            }else{
                return null;
            }
        }catch(Exception e){
            System.debug('The Error ::'+e.getMessage() +' AND Error Line No :'+e.getLineNumber());
        }
        return null;
    }
    
    // Controller to Create New Lead Record
    @AuraEnabled 
    public static Lead specifierNewLeadRecord(Lead LeadRec){
        System.debug('LeadRec === >'+LeadRec);
        try{
            insert LeadRec;
            System.debug('Specifier Related New LeadRec === >'+LeadRec);
            if(LeadRec !=null){
                return LeadRec;
            }
        }catch(Exception e){
            System.debug('The Error ::'+e.getMessage() +' AND Error Line No :'+e.getLineNumber());
        }
        return null;
    }
    
    // Method for Creating Child Viist Record
    @AuraEnabled 
    public static visit__c createChildVisitRecord(visit__c childvisitRec){
        System.debug('childvisitRec == >'+childvisitRec);
        try{
            insert childvisitRec;
            System.debug('Child Visit Record === >'+childvisitRec);
            if(childvisitRec !=null){
                return childvisitRec;
            }
        }catch(Exception e){
            System.debug('The Error ::'+e.getMessage() +' AND Error Line No :'+e.getLineNumber());
        }
        return null;
    }
    
}