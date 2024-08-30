public with sharing class InwardSKUs_Controller {
    
    @AuraEnabled(cacheable=true)
    public static List<Transfered_SKU__c> getTransferredSKUs(String WarehousetansferedlogID){
        System.debug('WarehousetansferedlogID----->'+WarehousetansferedlogID);
        List<Transfered_SKU__c> TransferredSKUs = [SELECT Id, Name, Market_Place_Warehouse__r.Product__c, Warehouse_Transfer_Log__r.Transfer_Type__c, Product_Name__c, Warehouse_Transfer_Log__r.Project__c, Warehouse_Transfer_Log__r.Project_Line_Item__c, Project_Line_Item__c, Project_Line_Item__r.Purchase_Order_Line_Item__r.Product__r.Name, Project_Line_Item__r.Purchase_Order_Line_Item__r.Product__c,
                                                   Product_Warehouse__r.Product__c,Product_Warehouse__r.Product__r.Name, Quantity__c,UOM__c,Warehouse_Transfer_Log__c, Warehouse_Transfer_Log__r.Name , Pending_Quantity__c,Recieved_Quantity__c,
                                                   Warehouse_Transfer_Log__r.Destination_Source__c, Warehouse_Transfer_Log__r.Destination_Source__r.Name, Warehouse_Transfer_Log__r.Source_Warehouse__c,Warehouse_Transfer_Log__r.Source_Warehouse__r.Name,Remarks__c,
                                                   Return_Product__r.OrderProduct__r.Product2Id
                                                   FROM Transfered_SKU__c WHERE Warehouse_Transfer_Log__c =:WarehousetansferedlogID AND Pending_Quantity__c > 0];
        System.debug('TransferredSKUs ===> ' + TransferredSKUs);
        return TransferredSKUs;
    }
    
    @AuraEnabled
    public static string SaveTransferLogDetails(string wtLogId, List<Transfered_SKU__c> TransferredSKUs, String transferType){
        string message = '';
        System.debug('wtLogId -- ' + wtLogId);
        System.debug('TransferredSKUs ====> ' + TransferredSKUs);
        System.debug('transferType ====> ' + transferType);
        
        try{
            Map<Id, Transfered_SKU__c> mapOfQtyByTsku = new Map<Id, Transfered_SKU__c>();
            Map<Id, Decimal> mapOfQtyByProductWH = new Map<Id, Decimal>();
            Map<Id, Decimal> mapOfQtyByProduct = new Map<Id, Decimal>();
            
            for(Transfered_SKU__c tSku : TransferredSKUs){
                if(tSku.Recieved_Quantity__c != null && tSku.Recieved_Quantity__c != 0){
                    if(transferType == 'B2B')
                        mapOfQtyByProductWH.put(tSku.Product_Warehouse__c, tSku.Recieved_Quantity__c);
                    else if (transferType == 'Projection')
                        mapOfQtyByProduct.put(tSku.Project_Line_Item__r.Purchase_Order_Line_Item__r.Product__c, tSku.Recieved_Quantity__c);
                    else if (transferType == 'B2C')
                        mapOfQtyByProduct.put(tSku.Market_Place_Warehouse__r.Product__c, tSku.Recieved_Quantity__c);
                    else if (transferType == 'QC Check')
                        mapOfQtyByProduct.put(tSku.Return_Product__r.OrderProduct__r.Product2Id, tSku.Recieved_Quantity__c);
                    
                    mapOfQtyByTsku.put(tSku.Id, tSku);
                }
            }
            
            System.debug('mapOfQtyByProductWH ====> ' + mapOfQtyByProductWH);
            System.debug('mapOfQtyByProduct ====> ' + mapOfQtyByProduct);
            System.debug('mapOfQtyByTsku ====> ' + mapOfQtyByTsku);
            
            List<Transfered_SKU__c> tSkuLstToBeUpdated = [SELECT Id, Warehouse_Transfer_Log__r.Source_Warehouse__c,Market_Place_Warehouse__c,Warehouse_Transfer_Log__r.Destination_Source__c, Recieved_Quantity__c, 
                                                          Pending_Quantity__c,Market_Place_Warehouse__r.Inventory__c,Market_Place_Warehouse__r.In_Transit_Inventory__c, Remarks__c, Project_Line_Item__r.Purchase_Order_Line_Item__r.Product__c, Warehouse_Transfer_Log__r.Source_Warehouse__r.Is_Factory__c
                                                          FROM Transfered_SKU__c WHERE Id IN: mapOfQtyByTsku.keySet()];
            List<Market_Place_Warehouse__c> mpWareHouse = new List<Market_Place_Warehouse__c>();

            for(Transfered_SKU__c tSku : tSkuLstToBeUpdated){
                if(mapOfQtyByTsku.containsKey(tSku.Id)){
                    tSku.Remarks__c = mapOfQtyByTsku.get(tSku.Id).Remarks__c;
                    tSku.Recieved_Quantity__c = tSku.Recieved_Quantity__c > 0 ? mapOfQtyByTsku.get(tSku.Id).Recieved_Quantity__c + tSku.Recieved_Quantity__c : mapOfQtyByTsku.get(tSku.Id).Recieved_Quantity__c;
                }
                if(tSku.Market_Place_Warehouse__c != null){
                    Market_Place_Warehouse__c mp = new Market_Place_Warehouse__c();
                    mp.Id = tSku.Market_Place_Warehouse__c;
                    mp.Inventory__c = tSku.Market_Place_Warehouse__r.Inventory__c - tSku.Recieved_Quantity__c;
                    mp.In_Transit_Inventory__c = tSku.Market_Place_Warehouse__r.In_Transit_Inventory__c - tSku.Recieved_Quantity__c;
                    mpWareHouse.add(mp);
                }
            } 
            update mpWareHouse;
            update tSkuLstToBeUpdated; 
            
            if(transferType == 'B2B'){
                List<Product_Warehouse__c> prodWarehouse = [SELECT Id, In_Transit_Inventory__c FROM Product_Warehouse__c WHERE Id IN: mapOfQtyByProductWH.keySet()];
                for(Product_Warehouse__c pWh : prodWarehouse){
                    Decimal qty = mapOfQtyByProductWH.get(pWh.Id);
                    if(mapOfQtyByProductWH.containsKey(pWh.Id)){
                        pWh.In_Transit_Inventory__c = pWh.In_Transit_Inventory__c > 0 ? pWh.In_Transit_Inventory__c - qty: 0;
                    }
                }
                update prodWarehouse;
            }
            else{                
                MarketPlaceTriggerHandler handlerInstance = MarketPlaceTriggerHandler.getInstance();
                if(mapOfQtyByProduct.keySet().size()>0 && tSkuLstToBeUpdated[0].Warehouse_Transfer_Log__r.Source_Warehouse__c != null && !tSkuLstToBeUpdated[0].Warehouse_Transfer_Log__r.Source_Warehouse__r.Is_Factory__c){
                    List<Market_Place_Warehouse__c> srcMWarehouseList = [SELECT Id, Product__c, Warehouse_Master__c, Inventory__c,In_Transit_Inventory__c FROM Market_Place_Warehouse__c 
                                                                         WHERE Product__c IN: mapOfQtyByProduct.keySet() AND Warehouse_Master__c =: tSkuLstToBeUpdated[0].Warehouse_Transfer_Log__r.Source_Warehouse__c];
                    system.debug('srcMWarehouseList.size() -->> ' + srcMWarehouseList.size());
                    
                    if(srcMWarehouseList.size() < mapOfQtyByProduct.keySet().size()){ 
                        system.debug('srcMWarehouseList MPL for a Product doesnt exist');
                        
                        Map<Id, Id> mplIdByProds = new Map<Id, Id>();
                        for(Market_Place_Warehouse__c sMpw : srcMWarehouseList){
                            mplIdByProds.put(sMpw.Product__c, sMpw.Id);
                        }
                        system.debug('mplIdByProds -->> ' + mplIdByProds);
                        
                        List<Market_Place_Warehouse__c> mplToInsert = new List<Market_Place_Warehouse__c>();
                        for(Id prodId : mapOfQtyByProduct.keySet()){
                            if(mapOfQtyByProduct.containsKey(prodId)){
                                if(!mplIdByProds.containsKey(prodId)){
                                    Market_Place_Warehouse__c newRec = new Market_Place_Warehouse__c();
                                    newRec.Inventory__c = 0;
                                    newRec.Product__c = prodId;
                                    newRec.Warehouse_Master__c = tSkuLstToBeUpdated[0].Warehouse_Transfer_Log__r.Source_Warehouse__c;
                                    mplToInsert.add(newRec);
                                }
                            }
                        }
                        
                        if(mplToInsert.size()>0){
                            handlerInstance.SEND_TO_UNICOMMERCE = TRUE;
                            insert mplToInsert;
                        }
                    }
                    
                    for(Market_Place_Warehouse__c sMpw : srcMWarehouseList){
                        if(mapOfQtyByProduct.containsKey(sMpw.Product__c)){
                            Decimal inventory = sMpw.Inventory__c > 0 && sMpw.Inventory__c != null ? sMpw.Inventory__c : 0;
                            sMpw.Inventory__c = inventory >= mapOfQtyByProduct.get(sMpw.Product__c) ? inventory - mapOfQtyByProduct.get(sMpw.Product__c) : inventory;
                             if(sMpw.In_Transit_Inventory__c >0){
                                 sMpw.In_Transit_Inventory__c = sMpw.In_Transit_Inventory__c - mapOfQtyByProduct.get(sMpw.Product__c);
                             }
                        }
                    }
                    if(srcMWarehouseList.size()>0){
                        handlerInstance.SEND_TO_UNICOMMERCE = TRUE;
                        update srcMWarehouseList;
                        system.debug('srcMWarehouseList-->'+srcMWarehouseList);
                    }
                }
                
                if(mapOfQtyByProduct.keySet().size()>0 && tSkuLstToBeUpdated[0].Warehouse_Transfer_Log__r.Destination_Source__c != null){
                    List<Market_Place_Warehouse__c> destinationMWarehouseList = [SELECT Id, Product__c, Warehouse_Master__c, Inventory__c FROM Market_Place_Warehouse__c 
                                                                                 WHERE Product__c IN: mapOfQtyByProduct.keySet() AND Warehouse_Master__c =: tSkuLstToBeUpdated[0].Warehouse_Transfer_Log__r.Destination_Source__c];
                    system.debug('destinationMWarehouseList.size() -->> ' + destinationMWarehouseList.size());
                    if(destinationMWarehouseList.size() < mapOfQtyByProduct.keySet().size()){
                        system.debug('destinationMWarehouseList MPL for a Product doesnt exist');
                        
                        Map<Id, Id> mplIdByProds = new Map<Id, Id>();
                        for(Market_Place_Warehouse__c sMpw : destinationMWarehouseList){
                            mplIdByProds.put(sMpw.Product__c, sMpw.Id);
                        }
                        system.debug('mplIdByProds -->> ' + mplIdByProds);
                        
                        List<Market_Place_Warehouse__c> mplToInsert = new List<Market_Place_Warehouse__c>();
                        for(Id prodId : mapOfQtyByProduct.keySet()){
                            if(mapOfQtyByProduct.containsKey(prodId)){
                                if(!mplIdByProds.containsKey(prodId)){
                                    Market_Place_Warehouse__c newRec = new Market_Place_Warehouse__c();
                                    newRec.Inventory__c = mapOfQtyByProduct.get(prodId);
                                    newRec.Product__c = prodId;
                                    newRec.Warehouse_Master__c = tSkuLstToBeUpdated[0].Warehouse_Transfer_Log__r.Destination_Source__c;
                                    mplToInsert.add(newRec);
                                }
                            }
                        }
                        
                        if(mplToInsert.size()>0){
                            handlerInstance.SEND_TO_UNICOMMERCE = TRUE;
                            insert mplToInsert;
                        }
                        
                        //destinationMWarehouseList = [SELECT Id, Product__c, Warehouse_Master__c, Inventory__c FROM Market_Place_Warehouse__c 
                                                    // WHERE Product__c IN: mapOfQtyByProduct.keySet() AND Warehouse_Master__c =: tSkuLstToBeUpdated[0].Warehouse_Transfer_Log__r.Destination_Source__c];
                        //system.debug('destinationMWarehouseList.size() -->> ' + destinationMWarehouseList.size());
                    }
                    
                    for(Market_Place_Warehouse__c dMpw : destinationMWarehouseList){
                        if(mapOfQtyByProduct.containsKey(dMpw.Product__c)){
                            Decimal inventory = dMpw.Inventory__c > 0 && dMpw.Inventory__c != null ? dMpw.Inventory__c : 0;
                            dMpw.Inventory__c = inventory + mapOfQtyByProduct.get(dMpw.Product__c);
                        }
                    }
                    if(destinationMWarehouseList.size()>0){
                        handlerInstance.SEND_TO_UNICOMMERCE = TRUE;
                        update destinationMWarehouseList;
                    }
                    
                }
            }
            message = 'SUCCESS';
        }
        catch(exception e){
            System.debug('the error has occured due to ===> ' + e.getMessage());
            System.debug('the error has occured at ===> ' + e.getLineNumber());
            message = 'FAIL';
        }
        return message;
    }
    
}