global  without sharing class LeadDocumentTempVfController {
    
    
    public String blobData {
        get { 
            try{
                return EncodingUtil.Base64Encode(docWrapperInstance.blobFile);
            }catch(Exception e){
                ExceptionHelper.createExceptionLog(e);
                return '';
            }
            
        }
    }
    public docWrapper docWrapperInstance{get;set;}
    public LeadDocumentTempVfController() {
        viewPDF();
    }
    
    @RemoteAction
    global static List<DocumentTreeWrapper> getDocuments(String contactId ) {
        try{
            if(String.isBlank(contactId))
                return null;
            Map<Id,DocumentTreeWrapper> uiWrapper = new Map<Id,DocumentTreeWrapper>();
            List<Document_Template__c> docList=  [Select id,Name from Document_Template__c where contact__c =:contactId];
            String Obj = '';
            if(docList.size() > 0){
                for(Document_Template__c appDoc : [SELECT Id, Name,(SELECT Id, Name FROM Documents_Attachments__r) FROM Document_Template__c WHERE (contact__c =:contactId ) ORDER BY CreatedDate]) {
                    //Handle First level cat Here
                    DocumentTreeWrapper appDocWrapper;
                    System.debug('appDoc.Documents_Attachments__r::'+appDoc.Documents_Attachments__r);
                    appDocWrapper = new DocumentTreeWrapper(appDoc.Id, appDoc.Name); 
                    if(!appDoc.Documents_Attachments__r.isEmpty()){
                        for(Documents_Attachment__c appAttachment : appDoc.Documents_Attachments__r) {
                            appDocWrapper.childNodes.add(new DocumentTreeWrapper(appAttachment.Id, appAttachment.Name));
                        }
                    }
                    uiWrapper.put(appDoc.Id, appDocWrapper);
                }
            }
            system.debug('uiWrapper'+uiWrapper);
            return uiWrapper.values();
        }catch (Exception e) {
            ExceptionHelper.createExceptionLog(e);
            System.debug('An error occurred: ' + e.getMessage());
            String stackTrace = e.getStackTraceString();
            System.debug('Stack Trace: ' + stackTrace);
            return null;
        }
    }
    
    public void viewPDF(){
        try{
            String appDocId = Apexpages.currentPage().getParameters().get('attachId');
            system.debug('para::'+appDocId);
            docWrapperInstance = new docWrapper();
            Documents_Attachment__c appDocAttach = new Documents_Attachment__c();
            if(appDocId != null){
                appDocAttach = [SELECT id,Name,Attachement_Id__c FROM Documents_Attachment__c WHERE id =: appDocId];
                system.debug('appDocAttach == :'+appDocAttach);
                if(appDocAttach != null && appDocAttach.Attachement_Id__c != null){
                    try{
                        system.debug('appDocAttach.Attachement_Id__c'+appDocAttach.Attachement_Id__c);
                        if(!String.isBlank(appDocAttach.Attachement_Id__c)){
                            System.debug('Attachement ID ::'+appDocAttach.Attachement_Id__c);
                            Attachment att = [select id,name,body,contenttype  from attachment where id =: appDocAttach.Attachement_Id__c limit 1];
                            docWrapperInstance.contentType = att.contenttype;
                            docWrapperInstance.blobFile = att.body;
                        }
                    }catch(Exception e){
                        System.debug('Error :'+e.getMessage() + ' && Error Line :'+e.getLineNumber());
                    }
                }
            }else{
                docWrapperInstance = new docWrapper();
                docWrapperInstance.contentType = 'application/';
                docWrapperInstance.blobFile = blob.valueOf('');
            }
            
        }catch (Exception e) {
            ExceptionHelper.createExceptionLog(e);
            System.debug('An error occurred: ' + e.getMessage());
            String stackTrace = e.getStackTraceString();
            System.debug('Stack Trace: ' + stackTrace);
            
        }
        
    }
    
    global class DocumentTreeWrapper {
        
        public String documentID;
        public String documentName;
        public List<DocumentTreeWrapper> childNodes = new List<DocumentTreeWrapper>();
        
        public DocumentTreeWrapper(String documentID, String documentName) {
            this.documentID = documentID;
            this.documentName = documentName;
        }
    }
    
    global class docWrapper{
        public String contentType{get;set;}
        public blob blobFile{get;set;}
    }
    
    @RemoteAction
    public static string deleteSelectedDocFile(String docAttRecordId){
        System.debug('docAttRecordId === >'+docAttRecordId);
        Documents_Attachment__c DocAttToDelete = new Documents_Attachment__c();
        try{
            if(String.isNotBlank(docAttRecordId)){
                DocAttToDelete = [SELECT Id,Name,Attachement_Id__c FROM Documents_Attachment__c WHERE ID=:docAttRecordId];
                if(String.isNotBlank(DocAttToDelete.Attachement_Id__c)){
                    delete DocAttToDelete;
                    System.debug('DocAttToDelete == >'+DocAttToDelete); 
                    return 'SUCCESS'; 
                }
            }
        }catch(Exception e){
            ExceptionHelper.createExceptionLog(e);
            System.debug('The Error ::'+e.getMessage() +' AND Error Line No :'+e.getLineNumber());
        }
        return 'ERROR';
    }
    
    
}