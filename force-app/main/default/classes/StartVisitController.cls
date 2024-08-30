global class StartVisitController {
    
    public  string accId {get;set;}
    public  string visitId {get;set;}
    public string accDetails{get;set;}
    public String userId{get;set;}
    public String visitRecord{get;set;}
    public String userName {get;set;}
    public Static visit__c visitLookup{get;set;}
    
    public class visitDetailWrapper{
        public String accId;
        public Case caseRec;
        public String userId;
        public List<orderitem> orderLineItem;
    }
    
    global StartVisitController(){
        accId = apexpages.currentpage().getparameters().get('id');
        visitId = apexpages.currentpage().getparameters().get('vistId');
        userId = UserInfo.getUserId();
        system.debug('accId::'+accId);
        userName=UserInfo.getName();
        visitLookup = new Visit__c();
        getDealerDetails(accId);
        getVisitRecord(visitId);
    }
    
    global void getVisitRecord(String vstId){
        Visit__c visit = [Select Id, City__c, Country__c, State__c, Street__c, Postal_Code__c, Geo_Location__latitude__s, Geo_Location__longitude__s, Name,CheckIn__c,Check_Out__c,Visit_Plan__c,Planned_visit_date__c,Actual_visit_date__c,Status__c From Visit__c Where Id=:vstId];
        visitRecord = JSON.serialize(visit);
    }
    
    global  void getDealerDetails(String accId){
        try{
            Account acc = [SELECT id,Name,Billingcity,Phone,Industry,Website,/*Account_Type__c,Outstanding_Balance__c*/Email__c FROM Account WHERE id =: accId];
            accDetails = JSON.serialize(acc);
        }catch(Exception e){
            Lead acc = [SELECT Id,Name,Website,Industry,City,Phone,Email FROM Lead WHERE id =: accId];
            accDetails = JSON.serialize(acc);
        }
    }
    
    @RemoteAction
    global static String checkInDealerShop(Decimal checkinLat,Decimal checkinLang,String vstId,String accId){
        Location loc1 = Location.newInstance(12.8576,77.7864);
        Location loc2 = Location.newInstance(12.8576,77.7866);
        Double dist = Location.getDistance(loc1, loc2, 'km');
        
        try{
            if((dist * 1000) < 50){
                Visit__c vstRec = new Visit__c();
                vstRec.CheckIn__Latitude__s = checkinLat;
                vstRec.CheckIn__Longitude__s = checkinLang;
                vstRec.Id = vstId;
                UPDATE vstRec;
                RETURN 'Your check-in has been updated.';
            }else{
                RETURN 'Your location found far away from destination location. Please make sure that you are within 50 meter from destination location.';
            }
        }catch(Exception e){
            system.debug('Exception::'+e.getStackTraceString());
            RETURN 'Something went wrong.';
        }
    }
    
    @RemoteAction
    global static String checkOutDealerShop(Decimal checkoutLat,Decimal checkoutLang,String vstId,String accId){
        try{
            Visit__c vstRec = new Visit__c();
            vstRec.Check_Out__Latitude__s = checkoutLat;
            vstRec.Check_Out__Longitude__s = checkoutLang;
            vstRec.Id = vstId;
            UPDATE vstRec;
            RETURN 'Your check-out has been done successfully.';
            
        }catch(Exception e){
            system.debug('Exception::'+e.getStackTraceString());
            RETURN 'Something went wrong.';
        }
    }
    
    @RemoteAction
    global static List<Product2> getChannelSalesProducts(){
        return [SELECT Id,Name,ProductCode,Family,IsActive,QuantityUnitOfMeasure FROM Product2 /*WHERE Product_Used_By__c ='CHANNEL SALES'*/];
    }
    
    @RemoteAction
    global Static String createNewCase(String visitWrapInstanceString){
        system.debug('visitWrapInstance::'+visitWrapInstanceString);
        visitDetailWrapper visitWrapInstance = new visitDetailWrapper();
        try{
            visitWrapInstance = (visitDetailWrapper)System.JSON.deserialize(visitWrapInstanceString, visitDetailWrapper.class);
            Case caseRec = visitWrapInstance.caseRec;
            caseRec.OwnerId = visitWrapInstance.userId;
            INSERT caseRec;
            String caseNumber = [SELECT id,CaseNumber FROM case WHERE id =: caseRec.Id].CaseNumber;
            RETURN caseNumber;
        }catch(Exception e){
            system.debug('Exception::'+e.getStackTraceString());
            System.debug(e.getMessage());
            System.debug(e.getCause());
            RETURN 'SOmething went wrong.';
        }
    }
    
    @RemoteAction
    global static List<Orderitem> getOrderItems(String orderNumber){
        order orderRec = [SELECT id FROM order WHERE OrderNumber =: orderNumber];
        List<Orderitem> orderItemList = new List<Orderitem>();
        orderItemList = [SELECT id,Product2.Name,ListPrice,UnitPrice,Quantity FROM Orderitem WHERE OrderId =: orderRec.Id];
        RETURN orderItemList;
    }
    
    @RemoteAction
    global Static String onboardDealer(Account acc,String planVisitDate,String userId){
        try{
            if(acc.Name == null || acc.Name == '')
            {
                RETURN 'Dealer name is required for onboarding dealer.';
            }
            System.debug(acc);
            INSERT acc;
            system.debug('planVisitDate::'+planVisitDate);
            if(planVisitDate != null && planVisitDate != ''){
                system.debug('inside visit');
                Visit__c newVisit = new visit__C();
                newVisit.Account__c = acc.id;
                newVisit.Assigned_User__c = userId;
                newVisit.Planned_visit_date__c = Date.valueOf(planVisitDate);
                INSERT newVisit;
                system.debug('newVisit::'+newVisit.Id);
            }
            
            RETURN 'Dealer onboarding successfully.';
        }catch(Exception e){
            system.debug('Exception trace::'+e.getStackTraceString());
            System.debug(e.getCause());
            RETURN 'Something went wrong.';
        }
        
    }
    
    @RemoteAction
    global static String createNewvisit(String accId,string planDate,String userId){
        visit__c vstRec = new visit__c();
        vstRec.Account__c = accId;
        vstRec.Planned_visit_date__c = date.valueOf(planDate);
        vstRec.Assigned_User__c = userId;
        system.debug('vstRec::'+vstRec);
        INSERT vstRec;
        RETURN 'New visit has been created succesfully.';
    }
}