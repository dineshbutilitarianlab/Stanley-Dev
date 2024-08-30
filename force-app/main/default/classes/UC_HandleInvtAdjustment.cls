public without sharing class UC_HandleInvtAdjustment {
    
    public static void prepareSingleRequestPayload(string itemSku){
        system.debug('itemSku -- ' + itemSku);
        try{
            List<Market_Place_Warehouse__c> listingList = [SELECT Id, Inventory__c, Product__c, Product__r.StockKeepingUnit 
                                                    FROM Market_Place_Warehouse__c WHERE Product__r.StockKeepingUnit =: itemSku LIMIT 1];
            system.debug('prepareSingleRequestPayload listingList -->> ' + listingList);
            
            UniWare_APIs_Configurations__c uniwareAPIConfig = UniWare_APIs_Configurations__c.getInstance();
            Uniware_SingleInventoryAdjustmentWrapper UC_InvWrapper = new Uniware_SingleInventoryAdjustmentWrapper();
            Uniware_SingleInventoryAdjustmentWrapper.cls_inventoryAdjustment cls_wrapper = new Uniware_SingleInventoryAdjustmentWrapper.cls_inventoryAdjustment();
            
            cls_wrapper.itemSKU = listingList[0].Product__r.StockKeepingUnit;
            cls_wrapper.quantity = Integer.valueOf(listingList[0].Inventory__c);
            cls_wrapper.shelfCode = uniwareAPIConfig.Shelf_Code__c;
            cls_wrapper.adjustmentType = APIConstants.ADJUSTMENTTYPE_ADD;
            UC_InvWrapper.inventoryAdjustment = cls_wrapper;
            
            String requestPayload = JSON.serialize(UC_InvWrapper);
            system.debug('prepareSingleRequestPayload requestPayload -->> ' + requestPayload);
            
            UniWareAPIs getInstance = UniWareAPIs.getInstance();
            getInstance.handle_SingleInventoryAdjustment(requestPayload);
        }
        catch(Exception ex){
            system.debug('prepareSingleRequestPayload Exception Ex : ' + ex.getMessage());
            system.debug('prepareSingleRequestPayload Exception At Line No : ' + ex.getLineNumber());
        }
    }
    
    @future(callout=true)
    public static void prepareBulkRequestPayload(Map<Id, Decimal> marketPlaceListingIdWithQtyMap, String ADJUSTMENTTYPE){
        system.debug('marketPlaceListingIdWithQtyMap -- ' + marketPlaceListingIdWithQtyMap);
        try{
            List<Market_Place_Warehouse__c> listingList = [SELECT Id, Inventory__c, Product__r.StockKeepingUnit, Product__c, Warehouse_Master__r.Facility_Code__c
                                                    FROM Market_Place_Warehouse__c WHERE Id IN: marketPlaceListingIdWithQtyMap.keySet()];
            system.debug('prepareBulkRequestPayload listingList -->> ' + listingList);

            UniWare_APIs_Configurations__c uniwareAPIConfig = UniWare_APIs_Configurations__c.getInstance();
            Uniware_BulkInventoryAdjustmentWrapper UC_InvWrapper = new Uniware_BulkInventoryAdjustmentWrapper();
            List<Uniware_BulkInventoryAdjustmentWrapper.cls_inventoryAdjustments> cls_wrapperList = new List<Uniware_BulkInventoryAdjustmentWrapper.cls_inventoryAdjustments>();
            
            for(Market_Place_Warehouse__c lst : listingList){
                if(marketPlaceListingIdWithQtyMap.containsKey(lst.Id)){
                    Uniware_BulkInventoryAdjustmentWrapper.cls_inventoryAdjustments cls_wrapper = new Uniware_BulkInventoryAdjustmentWrapper.cls_inventoryAdjustments();
                    cls_wrapper.itemSKU = lst.Product__r.StockKeepingUnit;
                    cls_wrapper.quantity = Integer.valueOf(marketPlaceListingIdWithQtyMap.get(lst.Id));
                    cls_wrapper.shelfCode = uniwareAPIConfig.Shelf_Code__c;
                    cls_wrapper.adjustmentType = ADJUSTMENTTYPE; //APIConstants.ADJUSTMENTTYPE_ADD;
                    cls_wrapper.facilityCode = 'trevi'; //lst.Warehouse_Master__r.Facility_Code__c;
                    cls_wrapperList.add(cls_wrapper);
                }
            }
            UC_InvWrapper.inventoryAdjustments = cls_wrapperList;
            
            String requestPayload = JSON.serialize(UC_InvWrapper);
            system.debug('prepareBulkRequestPayload requestPayload -->> ' + requestPayload);
            
            UniWareAPIs getInstance = UniWareAPIs.getInstance();
            getInstance.handle_BulkInventoryAdjustment(requestPayload);
        }
        catch(Exception ex){
            system.debug('prepareBulkRequestPayload Exception Ex : ' + ex.getMessage());
            system.debug('prepareBulkRequestPayload Exception At Line No : ' + ex.getLineNumber());
        }
    }
    
}