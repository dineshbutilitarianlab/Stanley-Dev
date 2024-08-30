/**
* @description       : 
* @author            : Guru Charan
* @group             : 
* @last modified on  : 04-28-2023
* @last modified by  : Guru Charan
**/
public without sharing class TransferWareHouseController {
    
    @AuraEnabled // (Cacheable=true)
    public Static List<Product_Warehouse__c> getproductWarehouseRecords(String recid,String selectedOption) {
        
        List<Product_Warehouse__c> prodWareRecs = new List<Product_Warehouse__c>();
        if(recid != null && selectedOption =='B2B'){
            system.debug('Inside B2B--->');
            prodWareRecs = [Select Id, Name, Current_Inventory__c, Unique__c, Warehouse__c, Product__c,Product__r.Name, Product__r.StockKeepingUnit,In_Transit_Inventory__c
                            from Product_Warehouse__c where Warehouse__c=:recid and Current_Inventory__c >=1];
        }
        
        System.debug('prodWareRecs=>'+prodWareRecs);
        return prodWareRecs;
    }
    
    @AuraEnabled //(cacheable=true)
    public static List<Market_Place_Warehouse__c> getMarketPlaceWarehouseRecords(String recid,String selectedOption){
        
        List<Market_Place_Warehouse__c> marketWareRecs = new List<Market_Place_Warehouse__c>();
        if(recid != null && selectedOption =='B2C'){
            system.debug('Inside B2C--->');
            marketWareRecs = [SELECT id,Name,Inventory__c,Product__c,Product__r.Name,Product__r.StockKeepingUnit,Warehouse_Master__c,Virtually_Blocked_Inventory__c,In_Transit_Inventory__c
 FROM Market_Place_Warehouse__c WHERE Warehouse_Master__c =:recid and Inventory__c >=1];
        }
        
        System.debug('marketWareRecs=>'+marketWareRecs);
        return marketWareRecs;
    }
    
    @AuraEnabled
    public static String insertWarehouseTransferLog(List<Product_Warehouse__c> prodList , String warehouseMasterId,string SelectedWareHouseId) {
        System.debug('prodList===>'+prodList);
        System.debug('prodList.size()===>'+prodList.size());
        System.debug('warehouseMasterId--->'+warehouseMasterId);
        System.debug('SelectedWareHouseId--->'+SelectedWareHouseId);
        
        //update prodList;
        
        List<Department__c> logisticDepList = [select Id from Department__c where Name = 'Logistic'];
        List<Department_Member__c> logisticDepMemList = [Select Id, User__c from Department_Member__c where Department__c =: logisticDepList[0].Id  and User__c != null and Active__c = true];
        
        Warehouse_Transfer_Log__c wtlRec = new Warehouse_Transfer_Log__c();
        wtlRec.Transfer_Type__c = 'B2B';
        wtlRec.Source_Warehouse__c = warehouseMasterId; //Current recordId
        wtlRec.Destination_Source__c = SelectedWareHouseId; //Selected Record
        wtlRec.Transfered_DateTime__c = System.today();
        wtlRec.OwnerId = logisticDepMemList[0].user__c;
        insert wtlRec;
        
        System.debug('wtlRec--->'+wtlRec.Id);
        
        if(wtlRec.ID != null){
            System.debug('Hi, WtlRec is created -- ');
            List<Transfered_SKU__c> TrafSKUList = new List<Transfered_SKU__c>();
            for(Product_Warehouse__c prodwh : prodList){
                Transfered_SKU__c tranfRec = new Transfered_SKU__c();
                tranfRec.Warehouse_Transfer_Log__c = wtlRec.Id;
                tranfRec.Quantity__c = prodwh.In_Transit_Inventory__c;
                tranfRec.UOM__c= 'NOS';
                tranfRec.Product_Warehouse__c=prodwh.Id;
                tranfRec.OwnerId = logisticDepMemList[0].Id;
                TrafSKUList.add(tranfRec);
            }
            insert TrafSKUList;
            //update prodList;
        }
        return 'success';
    }
    
   
    @AuraEnabled
public static String insertMarketPlaceWarehouseTransferLog(List<Market_Place_Warehouse__c> prodList, String warehouseMasterId, String SelectedWareHouseId) {
    System.debug('prodList===>' + prodList);
    System.debug('prodList.size()===>' + prodList.size());
    System.debug('warehouseMasterId--->' + warehouseMasterId);
    System.debug('SelectedWareHouseId--->' + SelectedWareHouseId);
    String msg;
    try {
        List<Department__c> logisticDepList = [SELECT Id FROM Department__c WHERE Name = 'Logistic'];
        List<Department_Member__c> logisticDepMemList = [SELECT Id, User__c FROM Department_Member__c WHERE Department__c = :logisticDepList[0].Id AND User__c != null AND Active__c = true];
        List<Market_Place_Warehouse__c> marketList = [SELECT Id, Inventory__c, Warehouse_Master__c, Product__c, In_Transit_Inventory__c, Name FROM Market_Place_Warehouse__c WHERE Id IN :prodList];
        System.debug('marketList--->' + marketList);

        // Create a map for quick lookup of marketList records by Id
        Map<Id, Market_Place_Warehouse__c> marketMap = new Map<Id, Market_Place_Warehouse__c>();
        for (Market_Place_Warehouse__c marketwh : marketList) {
            marketMap.put(marketwh.Id, marketwh);
        }
        
        // Create Warehouse Transfer Log record
        Warehouse_Transfer_Log__c wtlRec = new Warehouse_Transfer_Log__c();
        wtlRec.Transfer_Type__c = 'B2C';
        wtlRec.Source_Warehouse__c = warehouseMasterId; //Current recordId
        wtlRec.Destination_Source__c = SelectedWareHouseId; //Selected Record
        wtlRec.Transfered_DateTime__c = System.today();
        wtlRec.OwnerId = logisticDepMemList[0].User__c;
        insert wtlRec;
        
        System.debug('wtlRec--->' + wtlRec.Id);
        
        if (wtlRec.Id != null) {
            System.debug('Hi, WtlRec is created -- ');
            List<Transfered_SKU__c> TrafSKUList = new List<Transfered_SKU__c>();
            Integer marketwh1;


            List<Market_Place_Warehouse__c> prodListUpdate = new List<Market_Place_Warehouse__c>();
            for (Market_Place_Warehouse__c prodwh : prodList) {
                if (marketMap.containsKey(prodwh.Id)) {
                   
                    System.debug('prodwh.In_Transit_Inventory__c--->' + prodwh.In_Transit_Inventory__c);
                    Transfered_SKU__c tranfRec = new Transfered_SKU__c();
                    tranfRec.Warehouse_Transfer_Log__c = wtlRec.Id;
                    tranfRec.Quantity__c = prodwh.In_Transit_Inventory__c;
                    tranfRec.UOM__c = 'NOS';
                    tranfRec.Market_Place_Warehouse__c = prodwh.Id;
                    tranfRec.OwnerId = logisticDepMemList[0].User__c;
                    TrafSKUList.add(tranfRec);

                    Market_Place_Warehouse__c marketwh = marketMap.get(prodwh.Id);
                    marketwh1 = Integer.valueOf(marketwh.In_Transit_Inventory__c);
                    if(marketwh1 == null){
                        marketwh1 = 0;
                    }
                    prodwh.Inventory__c = marketMap.get(prodwh.Id).Inventory__c;
                    prodwh.In_Transit_Inventory__c += marketwh1;
                    prodListUpdate.add(prodwh);
                } else {
                    System.debug('Market_Place_Warehouse__c not found for Id: ' + prodwh.Id);
                }
            }
            update prodListUpdate;
            System.debug('prodListUpdate--->' + prodListUpdate);
            insert TrafSKUList;
            System.debug('TrafSKUList--->' + TrafSKUList);
        }
        msg = 'success';
    } catch (Exception e) {
        System.debug('Exception Line Number-->' + e.getLineNumber());
        System.debug('Exception Message-->' + e.getMessage());
        msg = e.getMessage() + '' + e.getLineNumber();
    }
    return msg;
}

    
    @AuraEnabled(cacheable=true)
    public static List<sObject> getWarehouseMasterRecords(string searchKey,string recordId){
        List <sObject> returnList = new List <sObject> ();
        List<Warehouse_Master__c> WareHouseRecodrd=new List<Warehouse_Master__c>();
        string sQuery;
        system.Debug('searchKey--'+searchKey);
        try{
            string sWildCardText = '%'+searchKey+'%'  ;
            system.Debug('sWildCardText--'+sWildCardText);
            if(searchKey==null){
                system.debug('First Query');
                WareHouseRecodrd=[Select Id,Name,Active__c From Warehouse_Master__c Where Id!=:recordId];
            }
            else{
                system.debug(' Second Query');
                WareHouseRecodrd=[Select Id,Name,Active__c From Warehouse_Master__c Where Name LIKE:sWildCardText AND Id!=:recordId];  
            }
            System.debug('returnList---->'+returnList);
            System.debug('WareHouseRecodrd---->'+WareHouseRecodrd);
            return WareHouseRecodrd;
        }
        catch(Exception e){
            System.debug('Exception--->'+e.getMessage());
            System.debug('Exception--->'+e.getLineNumber());
            return WareHouseRecodrd;
        }
    } 
}