public  without sharing class LeadDocumentFileHelper {
    
    // For Lead
    @AuraEnabled
    public static String saveChunkAccount(String parentId, String fileName, String base64Data, String contentType, String fileId) {
        try{
            if(parentId != null){
                Document_Template__c docTemplate = [SELECT Id, Name, Opportunity__c FROM Document_Template__c WHERE Id =: parentId];
                if(docTemplate.Opportunity__c != null){
                    List<Opportunity> oppList = [SELECT Id, Process_Type__c FROM Opportunity WHERE Id =: docTemplate.Opportunity__c];
                    if(oppList[0].Process_Type__c == null && docTemplate.Name == 'CS Enquiry Form'){
                        return 'Please select Approach Type';
                    }
                }
            }
            if (fileId!=null || !string.isBlank(fileId)) {
                System.debug('saveTheFileLead Method Called');
                fileId = saveTheFileLead(parentId, fileName, base64Data, contentType);
            } 
            else {
                //   appendToFileLead(fileId, base64Data);
                System.debug('appendToFileLead Method Called 2');
            } 
            return Id.valueOf(fileId);
            
        }catch (Exception e) {
            ExceptionHelper.createExceptionLog(e);
            System.debug('An error occurred: ' + e.getMessage());
            String stackTrace = e.getStackTraceString();
            System.debug('Stack Trace: ' + stackTrace);
            return null;
        }
    }
    
    // For Lead
    public static Id saveTheFileLead(String parentId, String fileName, String base64Data, String contentType) {
        try{
            System.debug('parentId ==> '+parentId);
            // System.debug('RecordId ==> '+RecordId);
            Documents_Attachment__c doc = new Documents_Attachment__c();
            base64Data = EncodingUtil.urlDecode(base64Data, 'UTF-8');
            Attachment oAttachment = new Attachment();
            oAttachment.parentId = parentId;
            oAttachment.Body = EncodingUtil.base64Decode(base64Data);
            oAttachment.Name = fileName;
            oAttachment.ContentType = contentType;
            insert oAttachment;
            
            System.debug('insert oAttachment ==> '+oAttachment);
            doc.Name = oAttachment.Name;
            doc.Attachement_Id__c = oAttachment.Id;
            doc.Document_Template__c = parentId;
            insert doc;
            System.debug('doc.Id == >'+doc.Id);
            return doc.Id;
            
        }catch (Exception e) {
            ExceptionHelper.createExceptionLog(e);
            System.debug('An error occurred: ' + e.getMessage());
            String stackTrace = e.getStackTraceString();
            System.debug('Stack Trace: ' + stackTrace);
            return null;
        }
        
    }
}