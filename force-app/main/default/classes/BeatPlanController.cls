public class BeatPlanController {


    @AuraEnabled
    Public  static List<Roles_and_KPI__c> AllRolesXKPICurrentUser(){
        Id currentUserId = UserInfo.getUserId();
        List<Roles_and_KPI__c> RKPList=[Select Id,Name From Roles_and_KPI__c Where Sales_User__c=: currentUserId]; //:UserInfo.getUserId()
        return RKPList;
    }
    
    @AuraEnabled
    Public Static String GetAllMonthlyBeatPlanner(String StartDate,String LastDate,List<WrapperClass> WrapperRecList){
         
                /*String[] arrTest = StartDate.split('T');
                string[] dateArray = arrTest[0].split('-');
                Integer year = Integer.valueOf(dateArray[0]);
                Integer startmonth = Integer.valueOf(dateArray[1]);
                Integer day = Integer.valueOf(dateArray[2]);
                date StartFormatedDate = date.newInstance(year, startmonth, day);
        
                date dt=Date.valueOf(StartDate);
               DateTime startDateTime = DateTime.valueOf(dt);
         // Replace with your actual start date

                 String[] arrTestDate = LastDate.split('T');
                string[] EndArray = arrTestDate[0].split('-');
                Integer dateyear = Integer.valueOf(EndArray[0]);
                Integer datemonth = Integer.valueOf(EndArray[1]);
                Integer dateday = Integer.valueOf(EndArray[2]);
                date EndFormatedDate = date.newInstance(dateyear, datemonth, dateday);
                date d=Date.valueOf(LastDate);
                DateTime endDateEndDateTime = DateTime.valueOf(d); // Replace with your actual end date*/
        Integer weeksBetween = 0;
       /* Datetime startDateTime=Date.parse('2023-08-01');
        Datetime endDateEndDateTime=Date.parse(LastDate);*/
       
        System.debug('Weeks between start and end dates: ' + weeksBetween);
 
        Monthly_Beat_Plan__c MBP=new Monthly_Beat_Plan__c();
        List<Weekly_Beat_Plan__c> WBPList=new List<Weekly_Beat_Plan__c>();
        List<KPI_Target__c> ListKPITarget=new List<KPI_Target__c>();

        if(StartDate!=null && LastDate!=null){
            //Creating Monthly Beat Plan
            Map<Integer, String> monthNamebyNumber = new Map<Integer, String>{1=>'January', 2 => 'February', 3 => 'March', 4 => 'April', 5 => 'May', 6 => 'June', 7 => 'July', 8 => 'August'
                , 9 => 'September', 10 => 'October', 11 => 'November', 12 => 'December'};
                    String monthName = monthNamebyNumber.get(Date.valueOf(StartDate).month());
            String year = StartDate.subString(0,4);
            Id userId = UserInfo.getUserId();
            List<Monthly_Beat_Plan__c> existingBeatPlan = [SELECT Id, Name FROM Monthly_Beat_Plan__c WHERE Month_Name__c =: monthName AND Month_year__c=:year AND Sales_User__c =: userId];
            if(existingBeatPlan.size()>0){
                System.debug('Found Exisiting MBP');
                return 'ErrorFound';
            }
            MBP.Start_Date__c=Date.valueOf(StartDate);
            MBP.End_Date__c=Date.valueOf(LastDate);
            MBP.Sales_User__c=UserInfo.getUserId(); 
            insert MBP;
            System.debug('MBP==> ' + MBP);
            if(MBP !=null){
                sendEmailToRSMonMontlyBeatPlanCreation(MBP.id);
            }

             Date SelectedDate=Date.valueOf(StartDate);
             date firstDate = SelectedDate.toStartOfMonth();
             Integer month = SelectedDate.month();
             Integer DaysInMonth=date.daysInMonth(SelectedDate.year(), month) -1;
             Date LastDateOfMonth=firstDate.addDays(DaysInMonth);

        Datetime startDateTime=firstDate;
        Datetime endDateEndDateTime=LastDateOfMonth;

        System.debug('startDateTime ===> ' + startDateTime);
        System.debug('endDateEndDateTime ===> ' + endDateEndDateTime);

            if(MBP.Id!=null){
                Date NextWeekStartDate;
                 //Creating Weekly Beat Plan
                
              
                Date WeekStartDate=firstDate;
                //WBP.Start_Day_of_Week__c=WeekStartDate;
                //system.debug('WBP.Start_Day_of_Week__c==='+WBP.Start_Day_of_Week__c);
                integer i= 0;
                date lastWeekEndDate;
                while (startDateTime <= endDateEndDateTime) {
                    System.debug('startDateTime ====> ' + startDateTime);
                    System.debug('endDateEndDateTime ====> ' + endDateEndDateTime);
                        Weekly_Beat_Plan__c WBP=new Weekly_Beat_Plan__c();
                        WBP.Monthly_Beat_Plan__c=MBP.Id;
                        date previousWeekEnddate;
                    //date lastDateOfMonth = (Date.valueOf(startDateTime)).toStartOfMonth();
                    system.debug('lastDateOfMonth==> ' + LastDateOfMonth);
                    system.debug('Date.valueOf(startDateTime)==> ' + Date.valueOf(startDateTime));
                        // if (WBP.End_Day_of_Week__c != null && previousWeekEnddate > Date.valueOf(startDateTime)) {
                        //     WBP.Start_Day_of_Week__c=Date.valueOf(startDateTime);
                        // }
                                
                        if (string.valueof(startDateTime.format('E')) == 'Sun'){   
                            weeksBetween++;    
                            WBP.End_Day_of_Week__c=Date.valueOf(startDateTime);
                            if (weeksBetween == 1) {

                                WBP.Start_Day_of_Week__c = (Date.valueOf(StartDate)).toStartOfMonth();
                            }
                            else {
                                WBP.Start_Day_of_Week__c = (WBP.End_Day_of_Week__c).addDays(-6);
                            }
                            
                            previousWeekEnddate = WBP.End_Day_of_Week__c;
                            lastWeekEndDate = WBP.End_Day_of_Week__c;
                            system.debug('WBP.Start_Day_of_Week__c==='+WBP.Start_Day_of_Week__c);
                            WBPList.add(WBP);
                            System.debug('WBPList =====> ' + WBPList);
                        } else if(Date.valueOf(startDateTime) == LastDateOfMonth){
                        WBP.Start_Day_of_Week__c = lastWeekEndDate.addDays(1);
                        WBP.End_Day_of_Week__c = Date.valueOf(startDateTime);
                            if(WBP.Start_Day_of_Week__c != WBP.End_Day_of_Week__c){
                                WBPList.add(WBP);
                                lastWeekEndDate = WBP.End_Day_of_Week__c;
                            }
                    }
                        
                     startDateTime = startDateTime.addDays(1);
                    
                }
            }
            system.debug('WBPList---'+WBPList);
            if(!WBPList.isEmpty()){
                Insert WBPList;
            }

            if(!WrapperRecList.isEmpty()){
                  
                for(WrapperClass rec:WrapperRecList){
                     
                    KPI_Target__c KT=new KPI_Target__c();
                    if(rec.targetvalue!=null && rec.targetvalue!=''){
                        KT.Roles_and_KPI__c=rec.Id;
                        KT.Monthly_Beat_Plan__c=MBP.Id;
                        KT.Target_Count__c=Integer.valueOf(rec.targetvalue);
                        ListKPITarget.add(KT);
                    }
                }  
            }
            if(!ListKPITarget.isEmpty()){
                Insert ListKPITarget;
            }
            
        }
         return 'Success';     
    }

    Public Class WrapperClass{
        
        @AuraEnabled
        Public String Id{get;set;}
        @AuraEnabled
        Public String Name{get;set;}
        @AuraEnabled
        Public string targetvalue{get;set;}
    }

    

    
    
   /* public Static Integer weekOfMonth(Date todaysDate){
        Integer weekCount = 0;
        Integer startWeekResidue = 0;
        Integer endWeekResidue = 0;
        
        //Calculating startWeekResidue
        Date dt = todaysDate.toStartOfMonth().addDays(-1);
        Date dtFirstWeekend = dt.toStartOfWeek().addDays(6);
        startWeekResidue = dt.daysBetween(dtFirstWeekend);
        
        //Calculating endWeekResidue
        Date dtLastWeekend = todaysDate.toStartOfWeek().addDays(-1);
        endWeekResidue = dtLastWeekend.daysBetween(todaysDate);
        
        //Counting the weeks
        weekCount = (todaysDate.day() - (startWeekResidue + endWeekResidue))/7;
        weekCount += (startWeekResidue > 0 ? 1:0)+(endWeekResidue > 0 ? 1:0);
        System.Debug('Week Number: ' + weekCount);
        return weekCount;
    }*/
    
    // Method for Sending Email to RSM , On Monthly Beat Plan Creation
    @AuraEnabled 
    public static string sendEmailToRSMonMontlyBeatPlanCreation(string recordId){
        Monthly_Beat_Plan__c MbeatPlanRec = new Monthly_Beat_Plan__c();
        List<Messaging.SingleEmailMessage> mailList = new List<Messaging.SingleEmailMessage>();
        EmailTemplate temp = [SELECT Id,Subject,Body,HTMLValue FROM EmailTemplate WHERE Name ='New Beat Plan Email'];
        Id orgWideEmailAddressId = [SELECT Id FROM OrgWideEmailAddress LIMIT 1 ].Id;
        OrgWideEmailAddress owea = [ SELECT Id, Address, DisplayName FROM OrgWideEmailAddress where DisplayName = 'Anjali Singh' ]; //change DisplayName according your email
                 system.debug('owea--->'+owea);
        User CurrentUserRec = new User();
        try{
            if(recordId !=null){
                String htmlBody = temp.HTMLValue;
                String plainTextBody = temp.body;
                MbeatPlanRec = [SELECT Id,Name,Month_Name__c,OwnerId FROM Monthly_Beat_Plan__c WHERE Id=:recordId];
                system.debug('MbeatPlanRec === >'+MbeatPlanRec);
                String MBPBaseURL = System.label.MontlyBeatPlanURL;
                if(MbeatPlanRec.OwnerId !=null){
                    CurrentUserRec = [select userName,id,manager.name,manager.Email, manager.profile.name from user WHERE Id=:MbeatPlanRec.OwnerId LIMIT 1];
                    system.debug('CurrentUserRec == >'+CurrentUserRec);
                    if(CurrentUserRec.manager.name !=null && CurrentUserRec.manager.Email !=null){
                        if(MbeatPlanRec.Month_Name__c !=null){
                            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                            mail.setOrgWideEmailAddressId(orgWideEmailAddressId);
                                htmlBody = htmlBody.replace('{!Manager.Name}', CurrentUserRec.manager.name);
                                htmlBody = htmlBody.replace('{!Monthly_Beat_Plan__c.Month_Name__c}', MbeatPlanRec.Month_Name__c);
                                htmlBody = htmlBody.replace('{!Monthly_Beat_Plan__c.Id}', MbeatPlanRec.Id);
                                htmlBody = htmlBody.replace('{!RecordURL}', MBPBaseURL+MbeatPlanRec.Id+'/view');

                                plainTextBody = plainTextBody.replace('{!Monthly_Beat_Plan__c.Month_Name__c}', MbeatPlanRec.Month_Name__c);
                                plainTextBody = plainTextBody.replace('{!Monthly_Beat_Plan__c.Id}', MbeatPlanRec.Id);
                                plainTextBody = plainTextBody.replace('{!Manager.Name}', CurrentUserRec.manager.name);
                                plainTextBody = plainTextBody.replace('{!RecordURL}', MBPBaseURL+MbeatPlanRec.Id+'/view');


                            mail.setHtmlBody(htmlBody);
                            mail.setSubject(temp.Subject);
                            mail.setPlainTextBody(plainTextBody);
                            mail.setReplyTo(owea.Address);
                            mail.setOrgWideEmailAddressId(owea.Id);
                            mail.toAddresses = new String[] {CurrentUserRec.manager.Email};
                                mailList.add(mail);
                            if(!mailList.isEmpty()){
                                Messaging.sendEmail(mailList);
                                return 'SUCCESS';
                            }
                           
                        }
                    }
                }
            }
        }catch(Exception e){
            System.debug('The Error ::'+e.getMessage() +' AND Error Line No :'+e.getLineNumber());
        }
        return null;
    }

}