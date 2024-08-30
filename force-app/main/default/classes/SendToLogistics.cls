/*
Author : GC 
*/
// This is b2b Flow and Sathyam is asking For B2C Flow

public without sharing class SendToLogistics{
    
    @AuraEnabled
    public static String sendEmailToLogistics(String recIdStr){
        System.debug('DispatchRequest id---> ' + recIdStr);
        List<OpportunityLineItem> updateOppLineList = new List<OpportunityLineItem>();
        string result ;
        try{
            List<Department__c> depList = [select Id,Name,Active__c from Department__c where Name ='Logistic' and Active__c = true ];
            List<Department_Member__c> depMemList = [Select Id,Active__c,Assigned_Date_Time__c,User__c,User__r.Email, User__r.Name from Department_Member__c where Department__c =:depList[0].Id  and User__c != null and Active__c = true];
            if(depMemList[0] != null){
                
                Id recId = Id.valueOf(recIdStr);
                String sObjName = recId.getSObjectType().getDescribe().getName();
                system.debug('sObjName -- ' + sObjName);
                
                if(sObjName.containsIgnoreCase('Dispatch_Request__c')){
                    Dispatch_Request__c disReq = [SELECT ID, Opportunity__c, Status__c from Dispatch_Request__c WHERE ID =: recIdStr];
                    System.debug('disReq---->'+disReq);
                    
                    Opportunity opp = [SELECT Id, Sub_Stage__c FROM Opportunity WHERE Id =: disReq.Opportunity__c];
                    System.debug('opp---->'+opp);
                    
                    List<OpportunityLineItem> oppLineList = [SELECT ID, Quantity, OpportunityId, Opportunity.Order_Id__c, Product2.Name, Product2.StockKeepingUnit, Opportunity.Total_Quantity__c from OpportunityLineItem WHERE OpportunityId = :disReq.Opportunity__c];
                    if(oppLineList.size()>0){
                        for(OpportunityLineItem opprodRec: oppLineList){
                            opprodRec.Status__c = 'INITIATE LOGISTIC';
                            updateOppLineList.add(opprodRec);
                        }
                        update updateOppLineList ;
                        System.debug('updateOppLineList---->'+updateOppLineList);
                        
                        opp.Sub_Stage__c = 'Intransit';
                        update opp;
                        sendEmailOnDR(depMemList, oppLineList);                    
                    } 
                }
                else if(sObjName.containsIgnoreCase('Warehouse_Transfer_Log__c')){
                    Warehouse_Transfer_Log__c wtLogRecord = [SELECT ID, Project_Line_Item__c, Project_Line_Item__r.Projects__r.Opportunity__c from Warehouse_Transfer_Log__c WHERE ID =: recIdStr];
                    List<Transfered_SKU__c> tSkuList = [SELECT Id, Warehouse_Transfer_Log__r.Project_Line_Item__r.Projects__r.Opportunity__r.Order_Id__c, Product_Warehouse__c, Recieved_Quantity__c, Product_Warehouse__r.Product__r.Name, Product_Warehouse__r.Product__r.StockKeepingUnit 
                                                        FROM Transfered_SKU__c WHERE Warehouse_Transfer_Log__c =: recIdStr];
                    
                    Opportunity opp = [SELECT Id, Sub_Stage__c FROM Opportunity WHERE Id =: wtLogRecord.Project_Line_Item__r.Projects__r.Opportunity__c];
                    System.debug('opp---->'+opp);
                    
                    if(tSkuList.size()>0){
                        opp.Sub_Stage__c = 'Intransit';
                        update opp;
                        sendEmailOnWTL(depMemList, tSkuList);
                    }
                }
                
                result = 'SUCCESS';
            }
            else{
                System.debug('Department List Is Null');
                result = 'Department List Is Null';
            }  
        }
        catch(exception e){
            System.debug('Exception Message--->'+e.getMessage());
            System.debug('Exception Line Number--->'+e.getLineNumber());
        }
        return result;
    }
    
    @AuraEnabled
    public static void sendEmailOnDR(List<Department_Member__c> depMem, List<OpportunityLineItem> oliList){
        List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
        List<String> recipients = new List<String>();
        try{
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.setSaveAsActivity(false);
            mail.setTargetObjectId(depMem[0].User__c);
            mail.setSenderDisplayName('Trevi Furniture');
            mail.setSubject ('Orders to be initiated');
            String htmlBody = 'Dear ' + depMem[0].User__r.Name + ',';
            htmlBody += ' <br> <br> I hope this email finds you well. I am writing to provide you with an important update regarding the logistics of your shipment. We understand the significance of timely and accurate information in ensuring a smooth and efficient delivery process. Please take note of the following details:<br><br>';
            htmlBody += '<table border="1" style="border-collapse: collapse">Shipment Details: <tr><th>Order Number</th><th>Product Details</th><th>Quantity</th></tr>';
            
            for (Integer i = 0; i < oliList.size(); i++) {
                htmlBody += '<tr><td>' + oliList[i].Opportunity.Order_Id__c + '</td><td>' + oliList[i].Product2.Name + '-' + oliList[i].Product2.StockKeepingUnit + '</td><td>' + oliList[i].Quantity + '</td></tr>';
            }
            
            htmlBody += '</table>';
            htmlBody += '<br> Thanks and Regards';
            htmlBody += '<br> Trevi Furniture';
            mail.setHtmlBody(htmlBody);
            mails.add(mail);
            System.debug('Mails----'+mails);
            if(!mails.isEmpty()){
                system.debug('Sending Email');
                Messaging.sendEmail(mails);
            }
        }
        catch(Exception e){
            HandleBusinessException.captureError('SendingEmailToDepartmentMember', 'sendEmail', e);
        }
    }    
    
    public static void sendEmailOnWTL(List<Department_Member__c> depMem, List<Transfered_SKU__c> tSkuList){
        List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
        List<String> recipients = new List<String>();
        try{
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.setSaveAsActivity(false);
            mail.setTargetObjectId(depMem[0].User__c);
            mail.setSenderDisplayName('Trevi Furniture');
            mail.setSubject ('Orders to be initiated');
            String htmlBody = 'Dear ' + depMem[0].User__r.Name + ',';
            htmlBody += ' <br> <br> I hope this email finds you well. I am writing to provide you with an important update regarding the logistics of your shipment. We understand the significance of timely and accurate information in ensuring a smooth and efficient delivery process. Please take note of the following details:<br><br>';
            htmlBody += '<table border="1" style="border-collapse: collapse">Shipment Details: <tr><th>Order Number</th><th>Product Details</th><th>Quantity</th></tr>';
            
            for (Integer i = 0; i < tSkuList.size(); i++) {
                htmlBody += '<tr><td>' + tSkuList[i].Warehouse_Transfer_Log__r.Project_Line_Item__r.Projects__r.Opportunity__r.Order_Id__c + '</td><td>' + tSkuList[i].Product_Warehouse__r.Product__r.Name + '-' + tSkuList[i].Product_Warehouse__r.Product__r.StockKeepingUnit + '</td><td>' + tSkuList[i].Recieved_Quantity__c + '</td></tr>';
            }
            
            htmlBody += '</table>';
            htmlBody += '<br> Thanks and Regards';
            htmlBody += '<br> Trevi Furniture';
            mail.setHtmlBody(htmlBody);
            mails.add(mail);
            System.debug('Mails----'+mails);
            if(!mails.isEmpty()){
                system.debug('Sending Email');
                Messaging.sendEmail(mails);
            }
        }
        catch(Exception e){
            HandleBusinessException.captureError('SendingEmailToDepartmentMember', 'sendEmail', e);
        }
    }    
    
}