public without sharing class StockPoHandler{
    
    //MODIFIED - BY ANJALI
    @AuraEnabled(cacheable = true)
    public Static List<String> getPickListValuesIntoList(){
        List<String> mrktPlaceList= new List<String>();        
        // List<Market_Place_Warehouse__c> marketPlaceMasterList = [SELECT ID,Name from Market_Place_Warehouse__c];
        // for(Market_Place_Warehouse__c mpmRec: marketPlaceMasterList){
        //     mrktPlaceList.add(mpmRec.Name);
        // }
        List<Market_Place_Master__c> marketPlaceMasterList = [SELECT ID,Name from Market_Place_Master__c];
        for(Market_Place_Master__c mpmRec: marketPlaceMasterList){
            mrktPlaceList.add(mpmRec.Name);
        }
        return mrktPlaceList;
    }
    
    @AuraEnabled(cacheable = true)
    public static List<String> getProductCategory(){
         List<String>  prodCatList = new List<String>();
        try{
            
            String objectName = 'Product2';
            String fieldName ='Category__c';
           
            Schema.SObjectType objSobjectType = Schema.getGlobalDescribe().get(objectName) ;
            Schema.DescribeSObjectResult objDescribeSobject = objSobjectType.getDescribe() ;
            Map<String,Schema.SObjectField> fields = objDescribeSobject.fields.getMap() ;
            Schema.DescribeFieldResult fieldResult = fields.get(fieldName).getDescribe();
            List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
            for( Schema.PicklistEntry pickListVal : ple){
                System.debug(pickListVal.getLabel() +' '+pickListVal.getValue());
                prodCatList.add(pickListVal.getValue());
            }
            
        }catch(Exception e){
            
        }
        return prodCatList;
    }
    
    /*public class ProductWrapper {
@AuraEnabled
public String prodId;
@AuraEnabled
public String prodName;
@AuraEnabled
public String prodSKU;
@AuraEnabled
public String prodFamily;
@AuraEnabled
public String prodColour;
@AuraEnabled
public String prodCapacity;
@AuraEnabled
public String prodSalesQuantity;
}*/
    
    @AuraEnabled(cacheable = true)
    Public static List<AggregateResult> getProducts(){
        List<AggregateResult> aggregateResults = new List<AggregateResult>();
        //List<OpportunityLineItem> products = new List<OpportunityLineItem>();        
        //List<Product2> products = new List<Product2>();
        try{
            aggregateResults = [select Product2Id,Product2.Name,Product2.StockKeepingUnit, Product2.Family,Product2.Category__c,
                                Product2.Colour__c,Product2.Capacity__c,Product2.Type__c,SUM(Quantity) totalQuantity, SUM(UnitPrice) totalSalesPrice
                                from OpportunityLineItem where OpportunityId != null group by Product2Id,product2.name,Product2.StockKeepingUnit,
                                Product2.Family,Product2.Category__c,Product2.Colour__c,Product2.Capacity__c,Product2.Type__c];
            system.debug('aggregateResults===>'+aggregateResults);
            
            /*products = [SELECT Id, Name, StockKeepingUnit, Type__c, Family, IsActive, Description, ProductCode, Hsn_Code__c, GST__c, Actual_Price__c, Category__c, 
Colour__c, Capacity__c, Product_Weight__c FROM Product2];*/
            
            //  products  = [SELECT ID,Opportunity.Market_Place_Master__r.Name,Product2Id,Product2.Name,Product2.StockKeepingUnit,Product2.Type__c, Product2.Family, Product2.IsActive,Product2.Description, Product2.ProductCode, Product2.Hsn_Code__c, Product2.GST__c, Product2.Actual_Price__c, Product2.Category__c, 
            //                 Product2.Colour__c, Product2.Capacity__c, Product2.Product_Weight__c FROM OpportunityLineItem ];
            
        } 
        catch (Exception e){
            System.debug('ExceptionMessage' + e.getMessage());
            System.debug('Exception Line Number' + e.getLineNumber());
        }
        return aggregateResults;
    }
    
    public class prodWrapper {
        @AuraEnabled
        public String Name;
        @AuraEnabled
        public String Type;
        @AuraEnabled
        public String StockKeepingUnit;
        @AuraEnabled
        public String prodId;
        @AuraEnabled
        public String Family;
        @AuraEnabled
        public String Colour;
        
    }
    
    @AuraEnabled
    Public static List<AggregateResult> getFilteredProducts(Date startDate, Date endDate, List<String> productCategoryValues, List<String> marketPlaceList, Boolean showAllProds){
        
        System.debug('startDate -- ' + startDate);
        System.debug('endDate -- ' + endDate);
        System.debug('marketPlaceList -- ' + marketPlaceList);
        System.debug('productCategoryValues -- ' + productCategoryValues);
        System.debug('marketPlaceList.size() -- ' + marketPlaceList.size());
        System.debug('showAllProds -- ' + showAllProds);
        //List<Product2> products = new List<Product2>();
        List<AggregateResult> products = new List<AggregateResult>();
        
        try{
            if(showAllProds || (startDate ==  null && endDate == null && marketPlaceList.size() == 0 && productCategoryValues.size() == 0)){
                system.debug('First IF-->');
                return   [select Product2Id,Product2.Name,Product2.StockKeepingUnit, Product2.Family,Product2.Category__c,
                Product2.Colour__c,Product2.Capacity__c,Product2.Type__c,SUM(Quantity) totalQuantity, SUM(UnitPrice) totalSalesPrice
                from OpportunityLineItem where OpportunityId != null group by Product2Id,product2.name,Product2.StockKeepingUnit,
                Product2.Family,Product2.Category__c,Product2.Colour__c,Product2.Capacity__c,Product2.Type__c];

            }
                /*return [SELECT Id, Name, StockKeepingUnit,Type__c, Family, IsActive, Description, ProductCode, Hsn_Code__c, GST__c, Actual_Price__c, Category__c, 
Colour__c, Capacity__c, Product_Weight__c FROM Product2];*/
                
                // Newly Added
               
            
            set<Id> productIdSet = new set<Id>();
            System.debug('productDSet....');
            if(productCategoryValues.size()>0 ){
                System.debug('entered..');
               
                List<OpportunityLineItem> oppLineList = [SELECT ID,Opportunity.Market_Place_Master__r.Name,Product2Id,Product2.Category__c FROM OpportunityLineItem  WHERE Product2.Category__c  IN:productCategoryValues];
                System.debug('oppLineList-->'+oppLineList);
                 System.debug('oppLineList-->'+oppLineList.size());
                System.debug('oppLineListMarket_Place_Master__r-->'+oppLineList[0].Opportunity.Market_Place_Master__r.Name);
                for(OpportunityLineItem item : oppLineList){
                    productIdSet.add(item.Product2Id);
                }
            }
            system.debug('productcategoryIdSet -- > ' + productIdSet);
            system.debug('productcategoryIdSet size -- > ' + productIdSet.size());

            if(marketPlaceList.size()>0 ){
                // List<Market_Place_Warehouse__c> marketPlaceListingList = [SELECT Id, Name, Product__c FROM Market_Place_Warehouse__c 
                //                                                         WHERE Name IN: marketPlaceList];
                //    for(Market_Place_Warehouse__c item : marketPlaceListingList){
                //     productIdSet.add(item.Product__c);
                // }
                List<OpportunityLineItem> oppLineList = [SELECT ID,Opportunity.Market_Place_Master__r.Name,Product2Id FROM OpportunityLineItem WHERE Opportunity.Market_Place_Master__r.Name IN:marketPlaceList];
                System.debug('oppLineList-->'+oppLineList);
                System.debug('oppLineListMarket_Place_Master__r-->'+oppLineList[0].Opportunity.Market_Place_Master__r.Name);
                for(OpportunityLineItem item : oppLineList){
                    productIdSet.add(item.Product2Id);
                }
            }

            
            system.debug('productIdSet -- > ' + productIdSet);
            system.debug('productIdSet.size() -- > ' + productIdSet.size());
            
            if(startDate !=  null && endDate != null && !productIdSet.isEmpty() && productIdSet.size()>0){
                system.debug('All Clear');
                List<OpportunityLineItem> oppLineItemList = [SELECT Id, Product2Id FROM OpportunityLineItem WHERE Opportunity.CloseDate >: startDate AND Opportunity.CloseDate <: endDate AND Product2Id IN:productIdSet];
                for(OpportunityLineItem oli : oppLineItemList){
                    productIdSet.add(oli.Product2Id);
                }
                system.debug('productIdSet.size() 12 -- > ' + productIdSet.size());
                //products = [SELECT Id, Name, StockKeepingUnit,Type__c, Family, IsActive, Description, ProductCode, Hsn_Code__c, GST__c, Actual_Price__c, Category__c, 
                //Colour__c, Capacity__c, Product_Weight__c FROM Product2 WHERE Id IN: productIdSet];
                
                // Added Newly   List<OpportunityLineItem> oppLineList
                /*products  = [SELECT ID,Opportunity.Market_Place_Master__r.Name,Product2Id,Product2.Name,Product2.StockKeepingUnit,Product2.Type__c, Product2.Family, Product2.IsActive,Product2.Description, Product2.ProductCode, Product2.Hsn_Code__c, Product2.GST__c, Product2.Actual_Price__c, Product2.Category__c, 
Product2.Colour__c, Product2.Capacity__c, Product2.Product_Weight__c FROM OpportunityLineItem WHERE Product2Id IN: productIdSet];*/
                products  = [select Product2Id,Product2.Name,Product2.StockKeepingUnit, Product2.Family,Product2.Category__c,
                             Product2.Colour__c,Product2.Capacity__c,Product2.Type__c,SUM(Quantity) totalQuantity,SUM(UnitPrice) totalSalesPrice
                             from OpportunityLineItem where Opportunity.CloseDate >: startDate AND Opportunity.CloseDate <: endDate
                             and OpportunityId != null and Product2Id IN: productIdSet  
                             group by Product2Id,product2.name,
                             Product2.StockKeepingUnit,Product2.Family,Product2.Category__c,Product2.Colour__c,Product2.Capacity__c,Product2.Type__c];
            }
            else if(startDate !=  null && endDate != null ){
                system.debug('Only Date');
                List<OpportunityLineItem> oppLineItemList = [SELECT Id, Product2Id FROM OpportunityLineItem WHERE Opportunity.CloseDate >: startDate AND Opportunity.CloseDate <: endDate];
                for(OpportunityLineItem oli : oppLineItemList){
                    productIdSet.add(oli.Product2Id);
                }
                system.debug('productIdSet.size() -- > ' + productIdSet.size());
                
                //products = [SELECT Id, Name, StockKeepingUnit,Type__c, Family, IsActive, Description, ProductCode, Hsn_Code__c, GST__c, Actual_Price__c, Category__c, 
                //           Colour__c, Capacity__c, Product_Weight__c FROM Product2 WHERE Id IN: productIdSet];
                // Added Newly 
                /*products = [SELECT ID,Opportunity.Market_Place_Master__r.Name,Product2Id,Product2.Name,Product2.StockKeepingUnit,
Product2.Type__c, Product2.Family, Product2.IsActive,Product2.Description, Product2.ProductCode, Product2.Hsn_Code__c, Product2.GST__c, Product2.Actual_Price__c, Product2.Category__c, 
Product2.Colour__c, Product2.Capacity__c, Product2.Product_Weight__c FROM OpportunityLineItem WHERE Product2Id IN: productIdSet];*/
                
                products  = [select Product2Id,Product2.Name,Product2.StockKeepingUnit, Product2.Family,Product2.Category__c,
                             Product2.Colour__c,Product2.Capacity__c,Product2.Type__c,SUM(Quantity) totalQuantity,SUM(UnitPrice) totalSalesPrice
                             from OpportunityLineItem where Opportunity.CloseDate >: startDate AND Opportunity.CloseDate <: endDate and
                             OpportunityId != null and Product2Id IN: productIdSet group by Product2Id,product2.name,
                             Product2.StockKeepingUnit,Product2.Family,Product2.Category__c,Product2.Colour__c,Product2.Capacity__c,Product2.Type__c];
                System.debug('products --1 ' + products.size());
            }
            else if(productIdSet.size()>0){
                system.debug('Only Market Place'+products.size());
                //products = [SELECT Id, Name, StockKeepingUnit, Type__c, Family, IsActive, Description, ProductCode, Hsn_Code__c, GST__c, Actual_Price__c, Category__c, 
                //            Colour__c, Capacity__c, Product_Weight__c FROM Product2 WHERE Id IN: productIdSet];
                
                //  // Added Newly 
                /*products = [SELECT ID,Opportunity.Market_Place_Master__r.Name,Product2Id,Product2.Name,Product2.StockKeepingUnit,
Product2.Type__c, Product2.Family, Product2.IsActive,Product2.Description, Product2.ProductCode, Product2.Hsn_Code__c, Product2.GST__c, Product2.Actual_Price__c, Product2.Category__c, 
Product2.Colour__c, Product2.Capacity__c, Product2.Product_Weight__c FROM OpportunityLineItem WHERE Product2Id IN: productIdSet];*/
                
                products  = [select Product2Id,Product2.Name,Product2.StockKeepingUnit, Product2.Family,Product2.Category__c,
                             Product2.Colour__c,Product2.Capacity__c,Product2.Type__c,SUM(Quantity) totalQuantity,SUM(UnitPrice) totalSalesPrice
                             from OpportunityLineItem where Opportunity.CloseDate >: startDate AND Opportunity.CloseDate <: endDate
                             and OpportunityId != null and Product2Id IN: productIdSet group by Product2Id,product2.name,
                             Product2.StockKeepingUnit,Product2.Family,Product2.Category__c,Product2.Colour__c,Product2.Capacity__c,Product2.Type__c];
            }
            
            System.debug('v==>'+products);
            System.debug('products -- ' + products.size());
        } 
        catch (Exception e){
            System.debug('ExceptionMessage' + e.getMessage());
            System.debug('Exception Line Number' + e.getLineNumber());
        }
        return products;
    }
    
    @AuraEnabled
    Public static List<SalesProjectionWrapper> getSalesProjection(String selectedMonth, List<Id> prodId){
        System.debug('selectedMonth =====> ' + selectedMonth);
        System.debug('prodId =====> ' + prodId);
        
        List<Sales_Projection__c> salesprojList = new List<Sales_Projection__c>();
        List<SalesProjectionWrapper> spWrapperList = new List<SalesProjectionWrapper>();
        try{
            String month = selectedMonth.substringBefore(' ');
            string year = selectedMonth.substringAfter(' ');
            System.debug('month =====> ' + month);
            System.debug('year =====> ' + year);
            
            salesprojList = [SELECT Id, Name, Date_Of_Projection__c FROM Sales_Projection__c WHERE Current_Month__c =: month AND Current_Year__c =: year LIMIT 1];
            System.debug('salesprojList =====> ' + salesprojList);
            Id salesProjId = null;
            if(salesprojList.size()>0){
                salesProjId = salesprojList[0].Id;
            }
            else{
                Sales_Projection__c sProj = new Sales_Projection__c();               
                sProj.Date_Of_Projection__c = Date.newInstance(Integer.valueof(year), lookupMonthNo(month), 01);
                sProj.OwnerId = [SELECT Id FROM User WHERE Profile.Name = 'B2C Head' AND IsActive = TRUE LIMIT 1].Id;
                insert sProj;
                salesProjId = sProj.Id;
            }
            System.debug('salesProjId =====> ' + salesProjId);
            
            List<Projected_SKU__c> projSKUList   = [SELECT Id, Product__c, Product_Name__c, Product_SKU__c, Sales_Projection__c, Quantity__c FROM Projected_SKU__c
                                                    WHERE Sales_Projection__c =: salesProjId AND Product__c IN: prodId];
            
            Map<Id, Projected_SKU__c> mapOfProdIdWithRec = new Map<Id, Projected_SKU__c>();
            if(projSKUList.size()>0){
                for(Projected_SKU__c pSku : projSKUList){
                    mapOfProdIdWithRec.put(pSku.Product__c, pSku);
                }
            }
            
            system.debug('mapOfProdIdWithRec -- ' + mapOfProdIdWithRec);
            
            Date threeMonthsAgo = Date.today().addMonths(-3);
            List<aggregateResult> aggResults = [select Product2Id,Product2.Name,Product2.StockKeepingUnit, Product2.Family,
                                                Product2.Colour__c,Product2.Capacity__c,Product2.Type__c,SUM(Quantity) totalQuantity,SUM(UnitPrice) totalSalesPrice
                                                from OpportunityLineItem where OpportunityId != null AND CreatedDate >= :threeMonthsAgo and Product2Id IN: prodId 
                                                group by Product2Id,product2.name,Product2.StockKeepingUnit,
                                                Product2.Family,Product2.Colour__c,Product2.Capacity__c,Product2.Type__c];
            system.debug('aggResults===>'+aggResults);
            
            
            //List<Product2> prodList = [SELECT Id, Name, StockKeepingUnit FROM Product2 WHERE Id IN: prodId];
            
            for(aggregateResult prod : aggResults){
                SalesProjectionWrapper spWrapper = new SalesProjectionWrapper();
                spWrapper.productId = (String)prod.get('Product2Id');
                spWrapper.productName = (String)prod.get('Name');
                spWrapper.sku = (String)prod.get('StockKeepingUnit');
                spWrapper.last3monthsSales = (Decimal)prod.get('totalQuantity');
                spWrapper.last3monthsSalesPrice = (Decimal)prod.get('totalSalesPrice');
                spWrapper.qty = null;
                if(mapOfProdIdWithRec.containsKey((String)prod.get('Product2Id'))){
                    spWrapper.Quantity = (Decimal)mapOfProdIdWithRec.get((String)prod.get('Product2Id')).Quantity__c;
                    spWrapper.Id = mapOfProdIdWithRec.get((String)prod.get('Product2Id')).Id;
                }
                else{
                    spWrapper.Quantity = null;
                    spWrapper.Id = null;
                }
                spWrapperList.add(spWrapper);
            }
            system.debug('spWrapperList -- ' + spWrapperList);
        } 
        catch (exception e){
            System.debug('Exception Message' + e.getMessage());
            System.debug('Exception Line Number' + e.getLineNumber());
        }
        return spWrapperList;
    }
    
    public class SalesProjectionWrapper{
        @AuraEnabled
        public string productId{get;set;}
        @AuraEnabled
        public string productName{get;set;}
        @AuraEnabled
        public string sku{get;set;}
        @AuraEnabled
        public Decimal Quantity{get;set;}
        @AuraEnabled
        public Decimal qty{get;set;}
        @AuraEnabled
        public string Id{get;set;}
        @AuraEnabled
        public Decimal last3monthsSales{get;set;}
        @AuraEnabled
        public Decimal last3monthsSalesPrice{get;set;}
    }
    
    @AuraEnabled
    public static String upsertProjectedSKUs(List<SalesProjectionWrapper> actualList, String selectedMonthYear){
        //System.debug('listFromJs =====> ' + listFromJs);
        System.debug('selectedMonthYear =====> ' + selectedMonthYear);
        
        //List<SalesProjectionWrapper> actualList = (List<SalesProjectionWrapper>)JSON.deserialize(listFromJs, List<SalesProjectionWrapper>.class);
        System.debug('actualList =====> ' + actualList);
        System.debug('actualList.size() =====> ' + actualList.size());
        
        string message = '';
        try{
            
            String month = selectedMonthYear.substringBefore(' ');
            string year = selectedMonthYear.substringAfter(' ');
            System.debug('month--->'+month);
            System.debug('year--->'+year);
            
            List<Sales_Projection__c> salesProjList = [SELECT Id, Name, Date_Of_Projection__c, Current_Year__c, Current_Month__c, OwnerId 
                                                       FROM Sales_Projection__c WHERE Current_Month__c =: month AND Current_Year__c =: year LIMIT 1];
            User b2cHeadUser = [SELECT Id, Name FROM User WHERE Profile.Name = 'B2C Head' LIMIT 1];
            User ecommUser = [SELECT Id, Name FROM User WHERE Profile.Name = 'E-Commerce Manager' LIMIT 1];
            
            Id salesProjId = null;
            Id ownerId = null;
            if(salesProjList.size()>0){
                salesProjId = salesProjList[0].Id;
                OwnerId = salesProjList[0].OwnerId;
            }
            else{
                Sales_Projection__c sProj = new Sales_Projection__c();               
                sProj.Date_Of_Projection__c =  Date.newInstance(Integer.valueof(year), lookupMonthNo(month), 01);
                if(b2cHeadUser.Id != null)
                    sProj.OwnerId = b2cHeadUser.Id;
                insert sProj;
                system.debug('sProj.OwnerId' + sProj.OwnerId);
                salesProjId = sProj.Id;
                OwnerId = sProj.OwnerId;
            }
            Map<Id, Decimal> MapOfpSkuIdWithQty = new Map<Id, Decimal>();
            List<Projected_SKU__c> pSkuListToBeInserted = new List<Projected_SKU__c>();
            for(SalesProjectionWrapper pWrap : actualList){
                if(pWrap.Id == null){
                    Projected_SKU__c pSKusRec = new Projected_SKU__c();
                    pSKusRec.Product__c = pWrap.productId;
                    pSKusRec.Sales_Projection__c = salesProjId;
                    pSKusRec.OwnerId = ownerId;
                    pSkusRec.Quantity__c = pWrap.qty;
                    pSkuListToBeInserted.add(pSKusRec);
                }
                else{
                    MapOfpSkuIdWithQty.put(pWrap.Id, pWrap.qty);
                }
            }
            insert pSkuListToBeInserted;
            System.debug('MapOfpSkuIdWithQty---> '+ MapOfpSkuIdWithQty);
            if(MapOfpSkuIdWithQty.size() > 0){
                List<Projected_SKU__c> pSkuListToBeUpdated = [SELECT Id, Quantity__c FROM Projected_SKU__c WHERE Id IN: MapOfpSkuIdWithQty.keySet()];
                System.debug('pSkuListToBeUpdated---> '+ pSkuListToBeUpdated);
                for(Projected_SKU__c pSku : pSkuListToBeUpdated ){
                    if(MapOfpSkuIdWithQty.containsKey(pSku.Id) && MapOfpSkuIdWithQty.get(pSku.Id) != null){
                        pSku.Quantity__c = pSku.Quantity__c != null ? pSku.Quantity__c + MapOfpSkuIdWithQty.get(pSku.Id) : MapOfpSkuIdWithQty.get(pSku.Id);
                    }
                }
                update pSkuListToBeUpdated;
            }
            
            if(ecommUser.Id != null)
                sendEmail(ecommUser.Id, ecommUser.Name, salesProjId);
            message = 'SUCCESS';
        }
        catch (exception e){
            System.debug('Exception Message' + e.getMessage());
            System.debug('Exception Line Number' + e.getLineNumber());
        }
        return message;
    }
    
    @AuraEnabled
    public static void sendEmail(String userId, string userName, string projectionId){
        List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
        List<String> recipients = new List<String>();
        try{        
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.setSaveAsActivity(false);
            mail.setTargetObjectId(userId);
            mail.setSenderDisplayName('Trevi Furniture');
            mail.setSubject ('Sales Projection');
            mail.plainTextBody = 'Dear ' + userName + ', \n\n Sales Projection for has been generated. Please find the below link : \nhttps://trevifurniture--trevisbx.sandbox.lightning.force.com/lightning/r/New_Product_Price_request__c/'+projectionId+'/view \n\nThanks & Regards,\nTrevi';
            mails.add(mail);
            System.debug('Mails----'+mails);
            if(!mails.isEmpty()){
                system.debug('Sending Email');
                Messaging.sendEmail(mails);
            }
        }
        catch(Exception e){
            System.debug('Exception Line Number' + e.getLineNumber());
        }
    }
    
    @AuraEnabled
    public static List<PoliWrapper> getProductsForPOLI(List<string> prodIdList){
        system.debug('prodIdList -- ' + prodIdList); 
        List<PoliWrapper> poliWrapList = new List<PoliWrapper>();
        
        try{
            
            List<Product2> prodList = [SELECT Id, Name, StockKeepingUnit, Type__c FROM Product2 WHERE Id IN: prodIdList];
            system.debug('prodList -- ' + prodList);
            
            List<Purchase_Order_Line_Item__c> poliList = [SELECT Id, Purchase_Order__c, Pending_Quantity__c, Product_SKU__c, Product_Name__c, Product__c 
                                                          FROM Purchase_Order_Line_Item__c WHERE Purchase_Order__r.Approval_Status__c = 'Approved' AND Purchase_Order__r.Status__c != 'Completed' AND Product__c IN: prodIdList]; //Purchase_Order__r.Status__c != 'Closed' changed to != Completed
            system.debug('poliList -- ' + poliList);
            
            List<Market_Place_Warehouse__c> mrktPlaceListingList = [SELECT Id, Inventory__c, Product__c,In_Transit_Inventory__c,Virtually_Blocked_Inventory__c FROM Market_Place_Warehouse__c WHERE Product__c IN: prodIdList];
            system.debug('mrktPlaceListingList -- ' + mrktPlaceListingList);
            
            Integer CurrentMonth = System.Today().Month();
            Integer Next1Month = System.Today().Month()+1; //chnaged 2 to 1
            
            List<Projected_SKU__c> pSkuList = [SELECT Id, Quantity__c, Product__c, Product__r.Id, Product__r.StockKeepingUnit, Product__r.Name, Sales_Projection__c, Sales_Projection__r.Current_Month__c, Sales_Projection__r.Current_Year__c 
                                               FROM Projected_SKU__c WHERE Product__c IN: prodIdList AND CALENDAR_MONTH(Sales_Projection__r.Date_Of_Projection__c) =: CurrentMonth AND CALENDAR_MONTH(Sales_Projection__r.Date_Of_Projection__c) <=: Next1Month];
            system.debug('pSkuList -- ' + pSkuList);
            
            Map<Id, Decimal> poliQtyWithProductMap = new Map<Id, Decimal>();
            for(Purchase_Order_Line_Item__c poli : poliList){
                if(poliQtyWithProductMap.containsKey(poli.Product__c) && poliQtyWithProductMap.get(poli.Product__c) != null)
                    poliQtyWithProductMap.put(poli.Product__c, poliQtyWithProductMap.get(poli.Product__c) + poli.Pending_Quantity__c);
                else
                    poliQtyWithProductMap.put(poli.Product__c, poli.Pending_Quantity__c);
            }
            system.debug('poliQtyWithProductMap -- ' + poliQtyWithProductMap);
            
            Map<Id, Decimal> currentInventoryWithProductMap = new Map<Id, Decimal>();
            Map<Id, Decimal> InTransitInventoryWithProductMap = new Map<Id, Decimal>();
            Map<Id, Decimal> virtuallyInventoryWithProductMap = new Map<Id, Decimal>();
            for(Market_Place_Warehouse__c mPlace : mrktPlaceListingList){
                if(currentInventoryWithProductMap.containsKey(mPlace.Product__c) && currentInventoryWithProductMap.get(mPlace.Product__c) != null)
                    currentInventoryWithProductMap.put(mPlace.Product__c, currentInventoryWithProductMap.get(mPlace.Product__c) + mPlace.Inventory__c);
                else
                    currentInventoryWithProductMap.put(mPlace.Product__c, mPlace.Inventory__c);
                if(InTransitInventoryWithProductMap.containsKey(mPlace.Product__c) && InTransitInventoryWithProductMap.get(mPlace.Product__c) != null){
                    if(mPlace.In_Transit_Inventory__c != null){
                        InTransitInventoryWithProductMap.put(mPlace.Product__c, InTransitInventoryWithProductMap.get(mPlace.Product__c) + mPlace.In_Transit_Inventory__c);
                    }
                }
                else{
                    InTransitInventoryWithProductMap.put(mPlace.Product__c, mPlace.In_Transit_Inventory__c);
                }
                if(virtuallyInventoryWithProductMap.containsKey(mPlace.Product__c) && virtuallyInventoryWithProductMap.get(mPlace.Product__c) != null){
                     if(mPlace.Virtually_Blocked_Inventory__c != null){
                        virtuallyInventoryWithProductMap.put(mPlace.Product__c, virtuallyInventoryWithProductMap.get(mPlace.Product__c) + mPlace.Virtually_Blocked_Inventory__c);
                   }
                }
                else{
                    virtuallyInventoryWithProductMap.put(mPlace.Product__c, mPlace.Virtually_Blocked_Inventory__c);
                }
                    
            }
            system.debug('currentInventoryWithProductMap -- ' + currentInventoryWithProductMap);
            
            Map<Id, Decimal> projectedQtyWithProductMap = new Map<Id, Decimal>();
            
            for(Projected_SKU__c pSku : pSkuList){
                system.debug('pSku.Product__c'  + pSku.Product__c);
                Decimal quantity = pSku.Quantity__c == null ? 0 : pSku.Quantity__c;
                
                if(projectedQtyWithProductMap.containsKey(pSku.Product__c) && projectedQtyWithProductMap.get(pSku.Product__c) != null)
                    projectedQtyWithProductMap.put(pSku.Product__c, projectedQtyWithProductMap.get(pSku.Product__c) + quantity);
                else
                    projectedQtyWithProductMap.put(pSku.Product__c, quantity);
            }
            
            for(Product2 prod : prodList){
                
                PoliWrapper pWrap = new PoliWrapper();
                pWrap.productId = prod.Id;
                pWrap.productSKU = prod.StockKeepingUnit;
                pWrap.productName = prod.Name;
                pWrap.qty = null;
                pWrap.productType = prod.Type__c;
                
                    
                    if(poliQtyWithProductMap.containsKey(prod.Id) && poliQtyWithProductMap.get(prod.Id) != null)
                    pWrap.pendingPOQty = poliQtyWithProductMap.get(prod.Id);
                else
                    pWrap.pendingPOQty = 0;
                
                if(currentInventoryWithProductMap.containsKey(prod.Id) && currentInventoryWithProductMap.get(prod.Id) != null)
                    pWrap.currentInventory = currentInventoryWithProductMap.get(prod.Id);
                else
                    pWrap.currentInventory = 0;
                
                if(InTransitInventoryWithProductMap.containsKey(prod.Id) && InTransitInventoryWithProductMap.get(prod.Id) != null)
                    pWrap.inTransitInventory = InTransitInventoryWithProductMap.get(prod.Id);
                else
                    pWrap.inTransitInventory = 0;
                
                if(virtuallyInventoryWithProductMap.containsKey(prod.Id) && virtuallyInventoryWithProductMap.get(prod.Id) != null)
                    pWrap.virtuallyBlockedInventory = virtuallyInventoryWithProductMap.get(prod.Id);
                else
                    pWrap.virtuallyBlockedInventory = 0;
                
                
                
                if(projectedQtyWithProductMap.containsKey(prod.Id) && projectedQtyWithProductMap.get(prod.Id) != null)
                    pWrap.projectedQty = projectedQtyWithProductMap.get(prod.Id);
                else
                    pWrap.projectedQty = 0;
                
                poliWrapList.add(pWrap);
            }
            
            system.debug('pWrapList -- ' + poliWrapList);
        }
        catch (exception e){
            System.debug('Exception Message' + e.getMessage());
            System.debug('Exception Line Number' + e.getLineNumber());
        }
        return poliWrapList;
        
    }
    
    @AuraEnabled
    public static void createPoLineItem(List<PoliWrapper> prods){ 
        System.debug('prods----->'+prods);
        try{            
            Purchase_Order__c po = new Purchase_Order__c();
            //po.Warehouse_Master__c = [SELECT Id FROM Warehouse_Master__c WHERE Default__c = TRUE].Id;
            insert po;
            
            List<Purchase_Order_Line_Item__c> poliList = new List<Purchase_Order_Line_Item__c>();
            Map<Id, Decimal> qtyByProductId = new Map<Id, Decimal>();
            
            set<Id> productIdSet = new set<Id>();
            if(po.Id!=null || !String.isBlank(po.Id)){
                for(PoliWrapper p: prods){
                    if(p.productType == 'Bundle'){
                        productIdSet.add(p.productId);
                        qtyByProductId.put(p.productId, p.qty);
                    }
                    else{
                        Purchase_Order_Line_Item__c poli = new Purchase_Order_Line_Item__c();
                        poli.Product__c = p.productId;
                        poli.Ordered_Quantity__c = p.qty ;
                        poli.Purchase_Order__c = po.Id;
                        poliList.add(poli);
                    }
                }
            }
            
            // // List<Child_SKU__c> childSKUList = [SELECT Id, Parent__c, Child__c, Quantity__c FROM Child_SKU__c WHERE Id IN: productIdSet];
            // // for(Child_SKU__c sku : childSKUList){
            // //     Purchase_Order_Line_Item__c poli = new Purchase_Order_Line_Item__c();
            // //     poli.Product__c = sku.Parent__c;
            // //     poli.Ordered_Quantity__c = integer.valueOf(qtyByProductId.get(sku.Parent__c)) * sku.Quantity__c;
            // //     poli.Purchase_Order__c = po.Id;
            // //     poliList.add(poli);
            // // }
            
            // if(poliList.size()>0)
            //     insert poliList;            
        }
        catch(exception e){
            System.debug('Exception Message' + e.getMessage());
            System.debug('Exception Line Number' + e.getLineNumber());
        }         
    }
    
    public class PoliWrapper{
        @AuraEnabled
        public string productId{get;set;}
        @AuraEnabled
        public string productName{get;set;}
        @AuraEnabled
        public string productSKU{get;set;}
        @AuraEnabled
        public decimal qty{get;set;}
        @AuraEnabled
        public string productType{get;set;}
        @AuraEnabled
        public decimal pendingPOQty;
        @AuraEnabled
        public decimal currentInventory;
        @AuraEnabled
        public decimal inTransitInventory;
        @AuraEnabled
        public decimal virtuallyBlockedInventory;
        @AuraEnabled
        public decimal projectedQty;
    }    
    
    
    @AuraEnabled(cacheable=true)
    public static List<sObject> search(String searchTerm, string myObject) {
        system.debug('searchTerm -- ' + searchTerm);
        system.debug('myObject -- ' + myObject);
        String myQuery = null;
        if(searchTerm == null || searchTerm == ''){
            myQuery = 'Select Id, Name from '+myObject;
        }
        else {
            myQuery = 'Select Id, Name from '+myObject+' Where Name Like  \'%' + searchTerm + '%\'';
        }
        system.debug('myQuery -- ' + myQuery);
        List<sObject> lookUpList = database.query(myQuery);
        return lookUpList;
    }
    
    @AuraEnabled
    public static sObject fetchDefaultRecord(string recordId , string myObject) {
        string sRecId = recordId;    
        string sQuery = 'Select Id,Name From ' + myObject + ' Where Id = : sRecId';
        for (sObject obj: database.query(sQuery)) {
            return obj;
        }
        return null;
    }
    
    @testVisible
    private static Integer lookupMonthNo(String monthName) {
        Map<String,Integer> monthNames = new Map<String,Integer>{
            'January' => 1,
                'February' => 2,
                'March'   => 3,
                'April' => 4,
                'May' => 5,
                'June' => 6,
                'July' => 7,
                'August' => 8,
                'September' => 9,
                'October' => 10,
                'November' => 11,
                'December' => 12
                };
                    try {
                        return monthNames.get(monthName);
                    } catch(NullPointerException e) {
                        return NULL;
                    }
    }
    
    @AuraEnabled
    public static Map<string, List<projectionWrapper>> getDataForProjection(Date startDate, Date endDate, List<Id> prodIdList){
        
        system.debug('startDate -- ' + startDate);
        system.debug('endDate -- ' + endDate);
        system.debug('prodIdList -- ' + prodIdList);
        
        List<Product2> prodList = [SELECT Id, Name, StockKeepingUnit FROM Product2 WHERE Id IN: prodIdList];
        system.debug('prodList -- ' + prodList);
        
        List<Purchase_Order_Line_Item__c> poliList = [SELECT Id, Purchase_Order__c, Pending_Quantity__c, Product_SKU__c, Product_Name__c, Product__c 
                                                      FROM Purchase_Order_Line_Item__c WHERE Purchase_Order__r.Approval_Status__c = 'Approved' AND Purchase_Order__r.Status__c != 'Completed' AND Product__c IN: prodIdList]; // chnaged  Purchase_Order__r.Status__c != 'Closed'  Completed
        system.debug('poliList -- ' + poliList);
        
        List<Market_Place_Warehouse__c> mrktPlaceListingList = [SELECT Id, Inventory__c, Product__c, Virtually_Blocked_Inventory__c, In_Transit_Inventory__c FROM Market_Place_Warehouse__c WHERE Product__c IN: prodIdList];
        system.debug('mrktPlaceListingList -- ' + mrktPlaceListingList);
        
        List<Projected_SKU__c> pSkuList = [SELECT Id, Quantity__c, Product__c, Product__r.Id, Product__r.StockKeepingUnit, Product__r.Name, Sales_Projection__c, Sales_Projection__r.Current_Month__c, Sales_Projection__r.Current_Year__c 
                                           FROM Projected_SKU__c WHERE Sales_Projection__r.Date_Of_Projection__c >=: startDate AND Sales_Projection__r.Date_Of_Projection__c <=: endDate AND Product__c IN: prodIdList ORDER BY Sales_Projection__r.Current_Month__c];
        system.debug('pSkuList -- ' + pSkuList);
        
        Map<Id, Decimal> poliQtyWithProductMap = new Map<Id, Decimal>();
        for(Purchase_Order_Line_Item__c poli : poliList){
            if(poliQtyWithProductMap.containsKey(poli.Product__c) && poliQtyWithProductMap.get(poli.Product__c) != null)
                poliQtyWithProductMap.put(poli.Product__c, poliQtyWithProductMap.get(poli.Product__c) + poli.Pending_Quantity__c);
            else
                poliQtyWithProductMap.put(poli.Product__c, poli.Pending_Quantity__c);
        }
        system.debug('poliQtyWithProductMap -- ' + poliQtyWithProductMap);
        
        Map<Id, Decimal> currentInventoryWithProductMap = new Map<Id, Decimal>();
        for(Market_Place_Warehouse__c mPlace : mrktPlaceListingList){
            system.debug('mPlace -- ' + mrktPlaceListingList);
             	
            if(currentInventoryWithProductMap.containsKey(mPlace.Product__c) && currentInventoryWithProductMap.get(mPlace.Product__c) != null){
                currentInventoryWithProductMap.put(mPlace.Product__c, currentInventoryWithProductMap.get(mPlace.Product__c) + mPlace.Inventory__c);
                
            }else{
                currentInventoryWithProductMap.put(mPlace.Product__c, mPlace.Inventory__c);
            }
                
        }
        system.debug('currentInventoryWithProductMap -- ' + currentInventoryWithProductMap);
        
        Map<string, Map<Id, Decimal>> mapOfQtyByProductIdByMonth = new Map<string, Map<Id, Decimal>>();                
        Map<Id, Decimal> projectedQtyWithProductMap = new Map<Id, Decimal>();
        Map<string, List<projectionWrapper>> mapOfWrapperListWithMonths = new Map<string, List<projectionWrapper>>();
        
        for(Projected_SKU__c pSku : pSkuList){
            system.debug('pSku.Product__c'  + pSku.Product__c);
            Decimal quantity = pSku.Quantity__c == null ? 0 : pSku.Quantity__c;
            
            string monthYear = pSku.Sales_Projection__r.Current_Month__c + ',' + pSku.Sales_Projection__r.Current_Year__c;
            
            projectionWrapper pWrap = new projectionWrapper();
            pWrap.prodSku = pSku.Product__r.StockKeepingUnit;
            pWrap.prodName = pSku.Product__r.name;
            pWrap.projectedQty = pSku.Quantity__c;
            
             system.debug('mrktPlaceListingList--->'+ mrktPlaceListingList);
            for(Market_Place_Warehouse__c mPlaceW : mrktPlaceListingList){
                system.debug('mPlaceW--->'+ mPlaceW);
                if(pSku.Product__c == mPlaceW.Product__c){
                    pWrap.virtBlkInv = mPlaceW.Virtually_Blocked_Inventory__c;
                    pWrap.inTranInv = mPlaceW.In_Transit_Inventory__c;
                }
            }
            
            if(poliQtyWithProductMap.containsKey(pSku.Product__r.Id) && poliQtyWithProductMap.get(pSku.Product__r.Id) != null)
                pWrap.pendingPOQty = poliQtyWithProductMap.get(pSku.Product__r.Id);
            else
                pWrap.pendingPOQty = 0;
            
            if(currentInventoryWithProductMap.containsKey(pSku.Product__r.Id) && currentInventoryWithProductMap.get(pSku.Product__r.Id) != null)
                pWrap.currentInventory = currentInventoryWithProductMap.get(pSku.Product__r.Id);
            else
                pWrap.currentInventory = 0;
            
            
            if (!mapOfWrapperListWithMonths.containsKey(monthYear)) {
                mapOfWrapperListWithMonths.put(monthYear, new List<projectionWrapper>{pWrap});
            } 
            else {
                mapOfWrapperListWithMonths.get(monthYear).add(pWrap);
            }
        }
        system.debug('mapOfWrapperListWithMonths -- ' + mapOfWrapperListWithMonths);
        return mapOfWrapperListWithMonths;
        
    }
    
    public class projectionWrapper{
        @AuraEnabled
        public string prodSku;
        @AuraEnabled
        public string prodName;
        @AuraEnabled
        public decimal virtBlkInv;
        @AuraEnabled
        public decimal inTranInv;
        @AuraEnabled
        public decimal pendingPOQty;
        @AuraEnabled
        public decimal currentInventory;
        @AuraEnabled
        public decimal inTransitInventory;
        @AuraEnabled
        public decimal virtuallyBlockedInventory;
        @AuraEnabled
        public decimal projectedQty;
    }
    
    public static List<String> getMonthNamesBetweenDates(Date startDate, Date endDate) {
        List<String> monthNames = new List<String>();
        Date currentDate = startDate.toStartOfMonth();
        
        while (currentDate <= endDate) {
            String monthName = getMonthName(currentDate.month());
            monthNames.add(monthName);
            currentDate = currentDate.addMonths(1);
        }
        return monthNames;
    }
    
    private static String getMonthName(Integer monthNumber) {
        String[] monthNames = new String[]{
            'January', 'February', 'March', 'April', 'May', 'June', 'July',
                'August', 'September', 'October', 'November', 'December'
                };
                    return monthNames[monthNumber - 1];
    }
    
}