public without sharing class DeliveryChallanVFController {
    
    
    public string recordId = System.currentPageReference().getParameters().get('id');
    Public List<OpportunityLineItem> getOppLineItemList {get;set;}
    public List<Product2> getProductListItem {get;set;}
    Public List<String> oppLineItemIdSet {get;set;}
    public DeliveryChallanDetails__mdt getCompanyDetails {get;set;}
    public List<Transfered_SKU__c> ListTSKUData {get;set;}
    public Integer totalQuantity {get;set;}
    public String productName {get;set;}
    public String HSNNumber {get;set;}
    public Integer Totalvalue {get;set;}
    public Decimal gstWithTotalValue {get;set;}
    public String totalValueAmountInWords {get;set;}
    
    public Warehouse_Transfer_Log__c getWareTraLogData {get;set;}
    public Warehouse_Master__c getWareHouseDestinationAddress {get;set;}
    
    public DeliveryChallanVFController() {
        try{
            if(!String.isBlank(recordId)){
                Totalvalue = 0;
                gstWithTotalValue = 0;
                
                System.debug('recordId === >'+recordId);
                getWareTraLogData = [SELECT Id, Name, Destination_Source__c,EWBN__c,Carrier_Name__c,Vehicle_No__c,Project_Line_Item__c,Project_Line_Item__r.Projects__r.Name,Project__r.Name FROM Warehouse_Transfer_Log__c WHERE Id =:recordId LIMIT 1];
                system.debug('getWareTraLogData--->'+getWareTraLogData);
                
                
                if(!String.isBlank(getWareTraLogData.Destination_Source__c)){
                    getWareHouseDestinationAddress = [SELECT Id, Name, Address__Street__s, Address__City__s, Address__PostalCode__s, Address__StateCode__s, Address__CountryCode__s, Address__c FROM Warehouse_Master__c WHERE Id=:getWareTraLogData.Destination_Source__c]; 
                    System.debug('getWareHouseDestinationAddress == >'+getWareHouseDestinationAddress);
                }
                
                Set<Id> ProductIdSet = new Set<Id>();
                List<String> Quantityy = new List<String>();
                ListTSKUData = [SELECT Id, Name, Product_Name__c, Unit_Price__c, GST__c, UOM__c,Project_Line_Item__c,Project_Line_Item__r.Product_Name__c,Project_Line_Item__r.Product_SKU__c, Product_Warehouse__r.Product__c, Product_Warehouse__r.Product__r.name, Product_Warehouse__r.Product__r.GST__c, Product_Warehouse__r.Product__r.ProductCode, Product_Warehouse__r.Product__r.Hsn_Code__c, Quantity__c, Recieved_Quantity__c,
                                Project_Line_Item__r.Projects__r.Name, Warehouse_Transfer_Log__c, Product_Warehouse__r.Current_Inventory__c FROM Transfered_SKU__c WHERE Warehouse_Transfer_Log__c =:recordId];
                system.debug('ListTSKUData-->'+ListTSKUData);
                system.debug('ListTSKUData.size()-->'+ListTSKUData.size());
                totalQuantity = 0;
                if(ListTSKUData.size() > 0){
                    for(Transfered_SKU__c sku : ListTSKUData){
                        if(sku.Product_Warehouse__r.Product__c != null){
                            ProductIdSet.add(sku.Product_Warehouse__r.Product__c);
                            system.debug('sku.Product_Warehouse__r.Product__c-->'+sku.Product_Warehouse__r.Product__c);
                        }
                        
                        if(sku.Recieved_Quantity__c != null){
                            totalQuantity += Integer.valueOf(sku.Recieved_Quantity__c);
                        }
                        integer qty = 0 ;
                        system.debug('tSku--->'+sku);
                        Decimal value = sku.Unit_Price__c;
                        if(value == null){
                            value = 0;
                        }
                        Totalvalue += Integer.valueOf(value * sku.Recieved_Quantity__c);
                        decimal  gst  = (Totalvalue * sku.GST__c) / 100 ;
                        gstWithTotalValue = gst+Totalvalue;
                        System.debug('gstWithTotalValue---->'+gstWithTotalValue);
                    }
                    totalValueAmountInWords = Utility.getNumberTOWordConvertion(gstWithTotalValue);
                    System.debug(totalValueAmountInWords);
                }
                getCompanyDetails = [SELECT Id, MasterLabel, CIN_No__c, GSTIN__c, PAN_No__c, StateAddress__c, StreetAddress__c, StreetAddress1__c, DC_No__c FROM DeliveryChallanDetails__mdt LIMIT 1];
                System.debug('ProductIdSet---->'+ProductIdSet.size());
                
                if(ProductIdSet.size() > 0){
                    getProductListItem = [SELECT Id, Name, ProductCode, Hsn_Code__c, GST__c, (SELECT Id,UnitPrice FROM PricebookEntries) FROM Product2 WHERE ID IN:ProductIdSet];                    
                    for(Transfered_SKU__c tSku : ListTSKUData){                          
                        integer qty = 0 ;
                        system.debug('tSku--->'+tSku);
                        Decimal value = tSku.Unit_Price__c;
                        if(value == null){
                            value = 0;
                        }
                        Totalvalue += Integer.valueOf(value * tSku.Recieved_Quantity__c);
                        decimal  gst  = (Totalvalue * tSku.GST__c) / 100 ;
                        gstWithTotalValue = gst+Totalvalue;
                        System.debug('gstWithTotalValue---->'+gstWithTotalValue);
                    }
                    totalValueAmountInWords = Utility.getNumberTOWordConvertion(gstWithTotalValue);
                    System.debug(totalValueAmountInWords);
                }
            }
        }catch(Exception e){
            System.debug('The Error ::'+e.getMessage() +' AND Error Line No :'+e.getLineNumber());
        }
    }
    
    @AuraEnabled
    Public Static String checkData(String recordId){
        if(!String.isBlank(recordId)){
            Transfered_SKU__c TSKU =  [SELECT Id,Name,Warehouse_Transfer_Log__c FROM Transfered_SKU__c WHERE Warehouse_Transfer_Log__c =:recordId LIMIT 1];
            return 'SUCCESS';
        }
        return null;
    }
    
    @AuraEnabled
    public static string savePDF(String url,String id,String fileName){
        try {
            
            PageReference ref = new PageReference(url);
            ContentVersion cont = new ContentVersion();
            
            cont.Title = fileName;
            cont.PathOnClient = fileName+'.pdf';
            if(Test.isRunningTest()){
                System.debug('For Running Test');
                cont.VersionData =Blob.valueOf('Test Data');
            }else{
                cont.VersionData = ref.getContentAsPdf();
            }
            
            cont.Origin = 'H';
            
            insert cont;    
            ContentDocumentLink cdl = createContentLink(cont.Id, id);
            return 'Success';
            
        } catch (Exception e) {
            System.debug('The Error ::'+e.getMessage() +' AND Error Line No :'+e.getLineNumber());
            return null;
        }
    }
    
    @TestVisible
    private static ContentDocumentLink createContentLink(String contentVersionId, String recordId) {
        if (contentVersionId == null || recordId == null) { return null; }
        ContentDocumentLink cdl = new ContentDocumentLink();
        cdl.ContentDocumentId = [ SELECT ContentDocumentId FROM ContentVersion WHERE Id =: contentVersionId ].ContentDocumentId;
        cdl.LinkedEntityId = recordId;
        cdl.ShareType = 'V';
        try {
            insert cdl;
            return cdl;
        } catch(DMLException e) {
            System.debug(e);
            return null;
        }
    }
}