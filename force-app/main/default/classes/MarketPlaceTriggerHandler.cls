public without sharing class MarketPlaceTriggerHandler {
    
    static MarketPlaceTriggerHandler handlerInstance;
    public static MarketPlaceTriggerHandler getInstance() {
        if(handlerInstance == null) 
            handlerInstance = new MarketPlaceTriggerHandler();
        return handlerInstance;
    }
    
    public Boolean SEND_TO_UNICOMMERCE = TRUE;
    
    public void onAfterInsert(List<Market_Place_Warehouse__c> mpwList) {
        try{
            system.debug('INSERT MarketPlaceTriggerHandler onAfterInsert -->> ');
            Map<Id, Decimal> qtyByMPL = new Map<Id, Decimal>();
            for(Market_Place_Warehouse__c mkl : mpwList){
                if(mkl.Inventory__c > 0 && SEND_TO_UNICOMMERCE){
                    qtyByMPL.put(mkl.Id, mkl.Inventory__c);
                }
            }
            system.debug('INSERT qtyByMPL -->> ' + qtyByMPL);
            
            if(qtyByMPL.keySet().size() > 0)
                UC_HandleInvtAdjustment.prepareBulkRequestPayload(qtyByMPL, APIConstants.ADJUSTMENTTYPE_ADD);
        }
        catch(Exception exp){
            system.debug('MarketPlaceTriggerHandler onAfterInsert Exception Exp : ' + exp.getMessage());
            system.debug('MarketPlaceTriggerHandler onAfterInsert Exception At Line No : ' + exp.getLineNumber());
        }
    }
    
    public void onAfterUpdate(List<Market_Place_Warehouse__c> mpwList, Map<Id, Market_Place_Warehouse__c> oldListingList) {
        try{
            system.debug('UPDATE MarketPlaceTriggerHandler onAfterUpdate -->> ');
            Map<Id, Decimal> addQtyByMPL = new Map<Id, Decimal>();
            Map<Id, Decimal> deductqtyByMPL = new Map<Id, Decimal>();
            
            for(Market_Place_Warehouse__c mkl : mpwList){
                if(SEND_TO_UNICOMMERCE){
                    if(mkl.Inventory__c > 0 && mkl.Inventory__c != oldListingList.get(mkl.Id).Inventory__c && mkl.Inventory__c > oldListingList.get(mkl.Id).Inventory__c){
                        addQtyByMPL.put(mkl.Id, mkl.Inventory__c - oldListingList.get(mkl.Id).Inventory__c);
                    }
                    if(mkl.Inventory__c != oldListingList.get(mkl.Id).Inventory__c && mkl.Inventory__c < oldListingList.get(mkl.Id).Inventory__c){
                        deductqtyByMPL.put(mkl.Id, oldListingList.get(mkl.Id).Inventory__c - mkl.Inventory__c);
                    }
                }
            }
            system.debug('UPDATE addQtyByMPL -->> ' + addQtyByMPL);
            system.debug('UPDATE deductqtyByMPL -->> ' + deductqtyByMPL);
            
            if(addQtyByMPL.keySet().size() > 0)
                UC_HandleInvtAdjustment.prepareBulkRequestPayload(addQtyByMPL, APIConstants.ADJUSTMENTTYPE_ADD);
            if(deductqtyByMPL.keySet().size() > 0)
                UC_HandleInvtAdjustment.prepareBulkRequestPayload(deductqtyByMPL, APIConstants.ADJUSTMENTTYPE_REMOVE);
        }
        catch(Exception exp){
            system.debug('MarketPlaceTriggerHandler onAfterUpdate Exception Exp : ' + exp.getMessage());
            system.debug('MarketPlaceTriggerHandler onAfterUpdate Exception At Line No : ' + exp.getLineNumber());
        }
    }

}