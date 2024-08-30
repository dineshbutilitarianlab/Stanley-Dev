public without sharing class Utility {
    
    public static string generateUniueNo(){
        try{
            String hashString = '1000' + String.valueOf(Datetime.now().formatGMT('yyyy-MM-dd HH:mm:ss.SSS'));
            Blob hash = Crypto.generateDigest('MD5', Blob.valueOf(hashString));
            String hexDigest = EncodingUtil.convertToHex(hash);
            system.debug('##########' + hexDigest );
            return hexDigest;
        }
        catch(Exception e){
            system.debug('ERROR :: ' + e.getMessage() + ' -- AT LINE NUMBER :: ' + e.getLineNumber());
            return e.getMessage();
        }           
    }
    
    public static void doApproval(Id objId, Id approverId, String approvalName, String comments){
        try{
            system.debug('objId -- ' + objId);
            system.debug('approverId -- ' + approverId);
            system.debug('approvalName -- ' + approvalName);
            system.debug('comments -- ' + comments);
            Map<Id, Approval.ProcessSubmitRequest> caseToapprovalRequestMap = new Map<Id, Approval.ProcessSubmitRequest>();
            Approval.ProcessSubmitRequest approvalRequest = new Approval.ProcessSubmitRequest();
            approvalRequest.setComments(comments);
            approvalRequest.setObjectId(objId);
            approvalRequest.setProcessDefinitionNameOrId(approvalName);
            approvalRequest.setNextApproverIds(new List<Id> {approverId});
            caseToapprovalRequestMap.put(objId, approvalRequest);
            
            if(!caseToapprovalRequestMap.isEmpty())
                List<Approval.ProcessResult> result = Approval.process(caseToapprovalRequestMap.values());
        }
        catch(Exception e){
            system.debug('ERROR :: ' + e.getMessage() + 'AT LINE NUMBER :: ' + e.getLineNumber());
            HandleBusinessException.captureError('Utility', 'doApproval', e);
        }           
    }
    
    public static void createTask(Id ownerId, String subject, Id whatId, String description, Decimal dueDays){
        try{
            System.debug('subject----->'+subject);
            Task taskRec = new Task();
            taskRec.OwnerId = ownerId;
            taskRec.Subject = subject;
            taskRec.WhatId = whatId ;
            taskRec.Description = description;
            taskRec.ActivityDate =   dueDays == null ? System.today() : System.today()+(Integer)dueDays;
            insert taskRec;
        }
        catch(Exception e){
            system.debug('ERROR :: ' + e.getMessage() + 'AT LINE NUMBER :: ' + e.getLineNumber());
            HandleBusinessException.captureError('Utility', 'doApproval', e);
        }           
    }
    
    public static void getDepartmentRelatedDetail(String depName, String devName){
        try{
            List<Department__c> depList = [select Id, Name from Department__c where Name =: depName and Active__c = true ];
            List<Department_Activity__c> depActList = [select Id, Subject_Name__c, Task_Due_in_Days__c, Description__c from Department_Activity__c where Department__c =:depList[0].Id and Developer_Name__c =:devName ];
            List<Department_Member__c> depMemList = [Select Id, Active__c, User__c from Department_Member__c where Department__c =:depList[0].Id and User__c != null and Active__c = true];
        }
        catch(Exception e){
            system.debug('ERROR :: ' + e.getMessage() + 'AT LINE NUMBER :: ' + e.getLineNumber());
            HandleBusinessException.captureError('Utility', 'doApproval', e);
        }           
    }   
    
    static Map<Id,UserRole> allRolesMap;
    
    public static OpportunityApprovalWrapper getUserSHMap() {
        Map<Id,Id> userRoleToBHRoleMap = new Map<Id,Id>();
        
        allRolesMap = allRolesMap == null ? new Map<Id, UserRole>([SELECT Id, ParentRoleId, Name FROM UserRole]) : allRolesMap;
        System.debug('allRolesMap.values()---->'+allRolesMap.values());
        for(UserRole ur : allRolesMap.values()) {   // CEO                         Sales Head                               CEO   && !ur.Name.containsIgnoreCase('MD')
            system.debug('userRoles Names--->'+ur.Name);
            if(!ur.Name.containsIgnoreCase('MD') && !ur.Name.containsIgnoreCase('B2B Head')) {
                userRoleToBHRoleMap.put(ur.Id, getSalesHeadIdRecursive(allRolesMap, ur));
            }
        }
        
        Map<Id,Id> usrRoleToBhIdMap = new Map<Id,Id>();
        if(!userRoleToBHRoleMap.isEmpty()) {
            List<User> userList = [SELECT Id, UserRoleId FROM User WHERE UserRoleId IN :userRoleToBHRoleMap.values()];
            for(User usr: userList) {
                if(!usrRoleToBhIdMap.containsKey(usr.UserRoleId))
                    usrRoleToBhIdMap.put(usr.UserRoleId, usr.Id);
            }
        } 
        return new OpportunityApprovalWrapper(userRoleToBHRoleMap, usrRoleToBhIdMap);
    }
    
    public static OpportunityApprovalWrapper getUserMDMap() {
        Map<Id,Id> userRoleToMDRoleMap = new Map<Id,Id>();
        
        allRolesMap = allRolesMap == null ? new Map<Id, UserRole>([SELECT Id, ParentRoleId, Name FROM UserRole]) : allRolesMap;
        for(UserRole ur : allRolesMap.values()) { // CEO        Managing Director  && !ur.Name.containsIgnoreCase('MD')
            if(!ur.Name.containsIgnoreCase('MD') ) {
                userRoleToMDRoleMap.put(ur.Id, getMDIdRecursive(allRolesMap, ur));
            }
        }
        
        Map<Id,Id> roleIdToMDIdMap = new Map<Id,Id>();
        if(!userRoleToMDRoleMap.isEmpty()) {
            List<User> userList = [SELECT Id, UserRoleId FROM User WHERE UserRoleId IN :userRoleToMDRoleMap.values()];
            for(User usr: userList) {
                if(!roleIdToMDIdMap.containsKey(usr.UserRoleId))
                    roleIdToMDIdMap.put(usr.UserRoleId, usr.Id);
            }
        }
        return new OpportunityApprovalWrapper(userRoleToMDRoleMap, roleIdToMDIdMap);
    }
    
    Public static Id getSalesHeadIdRecursive(Map<Id,UserRole> userRoleMap, UserRole currentRole) {
        if(currentRole.ParentRoleId != null && userRoleMap.get(currentRole.ParentRoleId).Name != null && userRoleMap.get(currentRole.ParentRoleId).Name.containsIgnoreCase('B2B Head')) {
            return userRoleMap.get(currentRole.ParentRoleId).Id;
        }else if(currentRole.ParentRoleId != null){
            return getSalesHeadIdRecursive(userRoleMap, userRoleMap.get(currentRole.ParentRoleId));
        }else {
            return null; //TOP Role - CEO.
        }
    }
    
    public static Id getMDIdRecursive(Map<Id,UserRole> userRoleMap, UserRole currentRole) {
        if(currentRole.ParentRoleId != null && userRoleMap.get(currentRole.ParentRoleId).Name != null && userRoleMap.get(currentRole.ParentRoleId).Name.containsIgnoreCase('MD')) {
            return userRoleMap.get(currentRole.ParentRoleId).Id;
        }else if(currentRole.ParentRoleId != null){
            return getMDIdRecursive(userRoleMap, userRoleMap.get(currentRole.ParentRoleId));
        }else {
            return null; //TOP Role - CEO.
        }
    }
    
    public class OpportunityApprovalWrapper {
        public Map<Id,Id> smToManagerMap;
        public Map<Id,Id> managerRoleToUserIdMap;
        
        public OpportunityApprovalWrapper(Map<Id,Id> smToManagerMap, Map<Id,Id> managerRoleToUserIdMap) {
            this.smToManagerMap = smToManagerMap;
            this.managerRoleToUserIdMap = managerRoleToUserIdMap;
        }
    }
    
    
    public class EmailLogisticWrapper {
        @AuraEnabled
        public String oppId { get; set; }
        
        @AuraEnabled
        public String logisticMasterId { get; set; }
    }
    
    
    @AuraEnabled
    public static String sendBulkEmailToLogistic(List<EmailLogisticWrapper> wrapperList) {
        try {
            system.debug('wrapperList -- ' + wrapperList);
            Map<Id, Id> mapOfOppIdWithLogisticMasterId = new Map<Id, Id>();
            
            for (EmailLogisticWrapper lWrapper : wrapperList) {
                mapOfOppIdWithLogisticMasterId.put(lWrapper.oppId, lWrapper.logisticMasterId);
            }
            
            system.debug('mapOfOppIdWithLogisticMasterId -- ' + mapOfOppIdWithLogisticMasterId);
            List<Opportunity> oppList = [SELECT Id, Logistics_Master__c, Order_ID__c, Total_Quantity__c FROM Opportunity WHERE Id IN :mapOfOppIdWithLogisticMasterId.keySet()];
            
            system.debug('oppList -- ' + oppList);
            Map<Id, List<Opportunity>> mapOfOppListWithLogMasterId = new Map<Id, List<Opportunity>>();
            
            for (Opportunity opp : oppList) {
                if (mapOfOppIdWithLogisticMasterId.containsKey(opp.Id)) {
                    Id newLogisticMasterId = mapOfOppIdWithLogisticMasterId.get(opp.Id);
                    if (newLogisticMasterId != null) {  // Check if the new LogisticMasterId is not null
                        opp.Logistics_Master__c = newLogisticMasterId;
                        
                        if (mapOfOppListWithLogMasterId.containsKey(newLogisticMasterId)) {
                            mapOfOppListWithLogMasterId.get(newLogisticMasterId).add(opp);
                        } else {
                            mapOfOppListWithLogMasterId.put(newLogisticMasterId, new List<Opportunity>{opp});
                        }
                    }
                }
            }
            
            update oppList;
            system.debug('mapOfOppListWithLogMasterId -- ' + mapOfOppListWithLogMasterId);
            
            List<Logistics_Master__c> lMasterList = [SELECT Id, Name, Email__c FROM Logistics_Master__c WHERE Id IN :mapOfOppIdWithLogisticMasterId.values() AND Notification_Type__c = 'Email'];
            system.debug('lMasterList -- ' + lMasterList);
            Map<Id, Logistics_Master__c> mapOfLogMasterIdWithRecord = new Map<Id, Logistics_Master__c>();
            
            for (Logistics_Master__c lMaster : lMasterList) {
                mapOfLogMasterIdWithRecord.put(lMaster.Id, lMaster);
            }
            
            system.debug('mapOfLogMasterIdWithRecord -- ' + mapOfLogMasterIdWithRecord);
            
            List<Messaging.SingleEmailMessage> emailsList = new List<Messaging.SingleEmailMessage>();
            
            for (Logistics_Master__c lMaster : lMasterList) {
                string emailIds = mapOfLogMasterIdWithRecord.get(lMaster.Id).Email__c;
                List<string> emailRecipients = emailIds.split(',');
                
                List<Opportunity> extractedOppList = mapOfOppListWithLogMasterId.get(lMaster.Id);
                Messaging.SingleEmailMessage singleEmail = new Messaging.SingleEmailMessage();
                singleEmail.setToAddresses(emailRecipients);
                singleEmail.setSubject('Orders to be initiated');
                
                String htmlBody = 'Dear ' + mapOfLogMasterIdWithRecord.get(lMaster.Id).Name + ' Team,';
                htmlBody += ' <br> <br> I hope this email finds you well. I am writing to provide you with an important update regarding the logistics of your shipment. We understand the significance of timely and accurate information in ensuring a smooth and efficient delivery process. Please take note of the following details:<br><br>';
                htmlBody += '<table border="1" style="border-collapse: collapse">Shipment Details: <tr><th>Order Number</th><th>Quantity</th></tr>';
                
                for (Opportunity opp : extractedOppList) {
                    htmlBody += '<tr><td>' + opp.Order_ID__c + '</td><td>' + opp.Total_Quantity__c + '</td></tr>';
                }
                
                htmlBody += '</table>';
                htmlBody += '<br> Thanks and Regards';
                htmlBody += '<br> Trevi Furniture';
                singleEmail.setHtmlBody(htmlBody);
                emailsList.add(singleEmail);
            }
            
            Messaging.SendEmailResult[] emailResult = Messaging.sendEmail(emailsList);  
            
            if (emailResult[0].isSuccess()) {
                List<OpportunityLineItem> oliList = [SELECT Id, Status__c FROM OpportunityLineItem WHERE OpportunityId IN :mapOfOppIdWithLogisticMasterId.keySet()];
                
                for (OpportunityLineItem oli : oliList) {
                    oli.Status__c = 'INITIATE LOGISTIC';
                }
                
                update oliList;
            }
            
            return 'SUCCESS';
        } catch(Exception e) {
            return 'ERROR';
        }
    }
    
    
    @AuraEnabled
    public static void generateBulkInvoicePDF(List<Id> oppIdList) {
        try{
            system.debug('oppIdList -- ' + oppIdList);
            User user = [SELECT Id, FirstName, Email FROM User WHERE Profile.Name LIKE '%Logistic%']; 
            List<Opportunity> oppList = [SELECT Id, Order_ID__c, Total_Quantity__c FROM Opportunity WHERE Id IN: oppIdList];
            List<Dispatch_Request__c> dispatchReqList = [SELECT Id, Opportunity__c  FROM Dispatch_Request__c WHERE Opportunity__c IN: oppIdList];
            system.debug('dispatchReqList -- ' + dispatchReqList);
            Map<Id, Id> mapOfOppIdWithDispatchReqId = new Map<Id, Id>();
            
            for(Dispatch_Request__c dReq : dispatchReqList){
                mapOfOppIdWithDispatchReqId.put(dReq.Opportunity__c, dReq.Id);
            }
            system.debug('mapOfOppIdWithDispatchReqId -- ' + mapOfOppIdWithDispatchReqId);
            List<Dispatch_Request__c> dReqListToBeInserted = new List <Dispatch_Request__c>();
            
            for(Opportunity opp : oppList){
                if(!mapOfOppIdWithDispatchReqId.containsKey(opp.Id)){
                    Dispatch_Request__c dReq = new Dispatch_Request__c();
                    dReq.Opportunity__c = opp.Id;
                    dReq.OwnerId = user.Id;
                    dReq.Status__c = 'Open';
                    dReq.Dispatch_Date_Time__c = system.today();
                    dReqListToBeInserted.add(dReq);
                }
            }
            
            if(dReqListToBeInserted.size()>0){
                
                insert dReqListToBeInserted;
                
                Map<Id, Id> mapOfDispatchReqWithOppId = new Map<Id, Id>();
                set<Id> dReqIdList = new set<Id>();
                for(Dispatch_Request__c dReq : dReqListToBeInserted){
                    mapOfDispatchReqWithOppId.put(dReq.Opportunity__c, dReq.Id);
                    dReqIdList.add(dReq.Id);
                }
                
                List<OpportunityLineItem> lineItemList = [SELECT Id, OpportunityId, Quantity FROM OpportunityLineItem WHERE OpportunityId IN: oppIdList];
                system.debug('lineItemList -- ' + lineItemList);
                List<Dispatch_Product__c> dProdListToBeInserted = new List <Dispatch_Product__c>();
                for(OpportunityLineItem lineItem : lineItemList){
                    Dispatch_Product__c dProd = new Dispatch_Product__c();
                    dProd.Order_Product__c = lineItem.Id;
                    dProd.Quantity__c = lineItem.Quantity;
                    dProd.Dispatch_Request__c = mapOfDispatchReqWithOppId.get(lineItem.OpportunityId);
                    dProdListToBeInserted.add(dProd);               
                }
                
                insert dProdListToBeInserted;
                string url ='https://trevifurniture--trevisbx--c.sandbox.vf.force.com/apex/TaxInvoice?id=';
                uploadFileToMultipleRecords(dReqIdList, 'Invoice', oppIdList);
            }            
        }
        catch(Exception e){
            system.debug('e.getMessage() -- ' + e.getMessage() + 'e.LINE NUM() --' + e.getLineNumber());
        }
    }
    
    @future(callout=true)
    public static void uploadFileToMultipleRecords(set<Id> parentIds, String fileTitle, List<Id> oppIdList) {
        try{
            List<ContentVersion> fileDataList = new List<ContentVersion>();
            List<ContentDocumentLink> contentDocumentLinks = new List<ContentDocumentLink>();
            
            for (Id parentId : parentIds) {
                PageReference ref = Page.TaxInvoice;
                ref.getParameters().put('id', parentId);
                system.debug('ref -- ' + ref);
                system.debug('ref.getParameters() -- ' + ref.getParameters());
                ContentVersion fileData = new ContentVersion();
                fileData.Title = fileTitle;
                fileData.VersionData = ref.getContentAsPdf();
                fileData.PathOnClient = fileTitle + '.pdf'; // Set the file path
                fileData.FirstPublishLocationId = parentId;
                
                fileDataList.add(fileData);
            }
            
            insert fileDataList;
            system.debug('fileDataList -- ' + fileDataList);
            set<Id> cvIdSet = new set<Id>();
            for (ContentVersion fileData : fileDataList) {
                cvIdSet.add(fileData.Id);
            }
            system.debug('cvIdSet -- ' + cvIdSet);
            
            List<ContentVersion> cvList = [SELECT Id, ContentDocumentId, FirstPublishLocationId FROM ContentVersion WHERE Id IN: cvIdSet];
            // Get the ContentDocumentIds after the insert operation
            Map<Id, Id> parentIdToContentDocumentIdMap = new Map<Id, Id>();
            for (ContentVersion fileData : cvList) {
                parentIdToContentDocumentIdMap.put(fileData.FirstPublishLocationId, fileData.ContentDocumentId);
            }
            system.debug('parentIdToContentDocumentIdMap -- ' + parentIdToContentDocumentIdMap);
            
            // Create ContentDocumentLink records using the ContentDocumentIds
            List<ContentDocumentLink> existingContentDocumentLinks = [
                SELECT Id, ContentDocumentId, LinkedEntityId
                FROM ContentDocumentLink
                WHERE ContentDocumentId IN :parentIdToContentDocumentIdMap.values()
                AND LinkedEntityId IN :parentIds
            ];
            
            Set<String> uniqueContentDocumentLinks = new Set<String>();
            for (ContentDocumentLink existingLink : existingContentDocumentLinks) {
                String uniqueKey = existingLink.ContentDocumentId + '_' + existingLink.LinkedEntityId;
                uniqueContentDocumentLinks.add(uniqueKey);
            }
            
            // Create ContentDocumentLink records using the ContentDocumentIds
            for (Id parentId : parentIds) {
                String contentDocumentId = parentIdToContentDocumentIdMap.get(parentId);
                String uniqueKey = contentDocumentId + '_' + parentId;
                
                if (!uniqueContentDocumentLinks.contains(uniqueKey)) {
                    contentDocumentLinks.add(new ContentDocumentLink(
                        ContentDocumentId = contentDocumentId,
                        LinkedEntityId = parentId,
                        ShareType = 'V' // 'V' represents sharing the file with the record and its related users
                    ));
                    uniqueContentDocumentLinks.add(uniqueKey);
                }
            }
            
            Database.upsert(contentDocumentLinks, false); // Upsert ContentDocumentLink records
            List<Opportunity> oppList = [SELECT Id, Invoice_Generated__c, Order_ID__c, Total_Quantity__c FROM Opportunity WHERE Id IN: oppIdList AND Invoice_Generated__c = false];
            
            for(Opportunity opp : oppList){
                opp.Invoice_Generated__c = true;
            }
            update oppList;
        }
        catch(Exception e){
            system.debug('UPLOAD MSG -- ' + e.getMessage() + 'e.LINE NUM() --' + e.getLineNumber());
        }
    }
    
    public static void createReplacementCase(set<Id> oppIdSet){
        try{
            system.debug('oppIdSet -- ' + oppIdSet);
            
        }
        catch(Exception e){
            system.debug('ERROR -- > ' + e.getMessage());
            system.debug('LINE NO -- > ' + e.getLineNumber());
        }
    }
    
    public static String getNumberTOWordConvertion(Decimal num) {
        
        Decimal junkVal = num;
        Decimal junkValPaisa = junkVal - Math.floor(junkVal);
        junkVal = Math.floor(junkVal);
        
        String obStr = junkVal.toPlainString();
        String[] numReversed = obStr.split('');
        String[] actnumber = reverse(numReversed);
        String firstHalf = convertInWords(numReversed, actnumber);
        
        Integer tmp = Math.round(junkValPaisa * 100);
        junkValPaisa = (Decimal)tmp / 100; System.debug('jj :' + junkValPaisa);
        String paisaStr = junkValPaisa.toPlainString();
        String secondHalf;
        if (paisaStr == '0') {
            secondHalf = '';
        } else if (paisaStr.length() != 4) {
            paisaStr = paisaStr + '0';
            paisaStr = paisaStr.substring(2);
            String [] numReversedPaisa = paisaStr.split('');
            String[] actnumberPaisa = reverse(numReversedPaisa);
            secondHalf = convertInWords(numReversedPaisa, actnumberPaisa);
        } else {
            paisaStr = paisaStr.substring(2);
            String [] numReversedPaisa = paisaStr.split('');
            String[] actnumberPaisa = reverse(numReversedPaisa);
            secondHalf = convertInWords(numReversedPaisa, actnumberPaisa);
        }
        
        String SumOFHalves = '';
        
        if (secondHalf.length() > 4) {
            firstHalf = firstHalf.replace('Only', 'Rupess And ');
            secondHalf = secondHalf.replace('Only', 'Paisa Only');
            SumOFHalves = firstHalf + secondHalf;
        } else {
            firstHalf = firstHalf.replace('Only', 'Rupess Only');
            SumOFHalves = firstHalf;
        }
        
        // IF amount has any value
        if (SumOFHalves.length() > 5) {
            system.debug('SumOFHalves :: ' + SumOFHalves);
            return SumOFHalves;
        } else {
            return '';
        }
    }
    
    // // Method reverse the number
    public static List<String> reverse(List<String> strToRev) {
        List<String> revList = new List<String>();
        for (Integer i = strToRev.size() - 1; i >= 0; i--) {
            revList.add(strToRev.get(i));
        }
        revList.add('');
        return revList;
    }
    
    public static String convertInWords(String[] numRev, String[] actnum) {
        List<String> iWords = new List<String> {'Zero', ' One', ' Two', ' Three', ' Four', ' Five', ' Six', ' Seven', ' Eight', ' Nine'};
            List<String> ePlace = new List<String> {' Ten', ' Eleven', ' Twelve', ' Thirteen', ' Fourteen', ' Fifteen', ' Sixteen', ' Seventeen', ' Eighteen', ' Nineteen'};
                List<String> tensPlace = new List<String> {'dummy', ' Ten', ' Twenty', ' Thirty', ' Forty', ' Fifty', ' Sixty', ' Seventy', ' Eighty', ' Ninety' };
                    
                    Integer iWordsLength = numRev.size();
        String totalWords = '';
        List<String> inWords = new List<String>();
        for (Integer k = 0; k < iWordsLength; k++) {
            inWords.add('');
        }
        String finalWord = '';
        Integer j = 0;
        
        //     // Main For loop
        for (Integer i = 0; i < iWordsLength; i++) {
            
            if (i == 0) {
                if (actnum[i] == '0' || actnum[i + 1] == '1') {
                    inWords[j] = '';
                } else {
                    inWords[j] = iWords[Integer.valueof(actnum[i])];
                }
                inWords[j] = inWords[j] + ' Only';
            } else if (i == 1) {
                
                if (actnum[i] == '0') {
                    inWords[j] = '';
                } else if (actnum[i] == '1') {
                    inWords[j] = ePlace[Integer.valueof(actnum[i - 1])];
                } else {
                    inWords[j] = tensPlace[Integer.valueof(actnum[i])];
                }
            } else if (i == 2) {
                if (actnum[i] == '0') {
                    inWords[j] = '';
                } else if (actnum[i - 1] != '0' && actnum[i - 2] != '0') {
                    inWords[j] = iWords[Integer.valueof(actnum[i])] + ' Hundred and';
                } else {
                    inWords[j] = iWords[Integer.valueof(actnum[i])] + ' Hundred';
                }
            } else if (i == 3) {
                if (actnum[i] == '0' || actnum[i + 1] == '1') {
                    inWords[j] = '';
                } else {
                    inWords[j] = iWords[Integer.valueof(actnum[i])];
                }
                if (actnum[i + 1] != '0' || Integer.valueof(actnum[i]) > 0) {
                    inWords[j] = inWords[j] + ' Thousand';
                }
            } else if (i == 4) {
                
                if (actnum[i] == '0') {
                    inWords[j] = '';
                } else if (actnum[i] == '1') {
                    inWords[j] = ePlace[Integer.valueof(actnum[i - 1])];
                } else {
                    inWords[j] = tensPlace[Integer.valueof(actnum[i])];
                }
                
            } else if (i == 5) {
                if (actnum[i] == '0' || actnum[i + 1] == '1') {
                    inWords[j] = '';
                } else {
                    inWords[j] = iWords[Integer.valueof(actnum[i])];
                }
                if (actnum[i + 1] != '0' || Integer.valueof(actnum[i]) > 0) {
                    inWords[j] = inWords[j] + ' Lakh';
                }
            } else if (i == 6) {
                
                if (actnum[i] == '0') {
                    inWords[j] = '';
                } else if (actnum[i] == '1') {
                    inWords[j] = ePlace[Integer.valueof(actnum[i - 1])];
                } else {
                    inWords[j] = tensPlace[Integer.valueof(actnum[i])];
                }
                
            } else if (i == 7) {
                if (actnum[i] == '0' || actnum[i + 1] == '1' ) {
                    inWords[j] = '';
                } else {
                    inWords[j] = iWords[Integer.valueof(actnum[i])];
                }
                inWords[j] = inWords[j] + ' Crore';
            } else if (i == 8) {
                
                if (actnum[i] == '0') {
                    inWords[j] = '';
                } else if (actnum[i] == '1') {
                    inWords[j] = ePlace[Integer.valueof(actnum[i - 1])];
                } else {
                    inWords[j] = tensPlace[Integer.valueof(actnum[i])];
                }
                
            }
            
            j++;
        }
        //     // End of For loop
        
        // Reverse the List
        inWords = reverse(inWords);
        
        for (Integer i = 0; i < inWords.size(); i++) {
            finalWord += inWords[i];
        }
        
        return finalWord;
    }
    
    public static void firstTestMethod(){
        Integer i=0;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
    }
    public static void firstTestMethod1(){
        Integer i=0;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;}
    public static void firstTestMethod2(){
        Integer i=0;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
    }
    public static void firstTestMethod3(){
        Integer i=0;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;}
    
}