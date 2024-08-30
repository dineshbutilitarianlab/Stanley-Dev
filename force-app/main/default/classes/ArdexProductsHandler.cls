public class ArdexProductsHandler {
    
    /*@RemoteAction
    public static ProductWrapper getroyalokProducts(string productId) {
        system.debug('productId-->'+ productId);
        if (!String.isBlank(productId)) {
            system.debug('productId-->'+ productId);
            Product2 getprod= [SELECT Id, Name, Product_Link_1__c, Product_Link_2__c FROM Product2 WHERE Id = :productId LIMIT 1];
            system.debug('getprod-->'+ getprod);
            ProductWrapper proWrap = new ProductWrapper();
            proWrap.public_prod = getprod;
            
            system.debug('getprod-->'+ getprod);
            return proWrap;
        }
        return null;
    }
    
    public class ProductWrapper {
        public Product2 public_prod {get; set;}
    }*/
    
    @RemoteAction
    public static productFamiliesWrapper getProductFamiliesDetails(){
        try{
            List<Product_Type__c> listOfProductType = [SELECT Id,Name,Aedex__c FROM Product_Type__c where Aedex__c = true];
            Lead leadRecord = [SELECT Id, Name, LastModifiedDate FROM Lead ORDER BY LastModifiedDate DESC LIMIT 1];
            productFamiliesWrapper wrapInstance = New productFamiliesWrapper();
            wrapInstance.productTypeDetails = listOfProductType;
            wrapInstance.leadRecord = leadRecord;
            
            return wrapInstance;
        }catch(Exception e){
            system.debug('Error ====> '+e.getMessage()+e.getLineNumber());
            return null;
        }
    }

    @RemoteAction
    public static productFamiliesWrapper getRelatedFamilies(String productTypeId){
        try{
           List<Product_Category__c> listOfProductCategory = [SELECT Id,Name,Product_Type__c,Product_Type__r.Name,Ardex__c FROM Product_Category__c WHERE Product_Type__c =: productTypeId And Ardex__c = true ];
           Lead leadRecord = [SELECT Id, Name, LastModifiedDate FROM Lead ORDER BY LastModifiedDate DESC LIMIT 1];
           productFamiliesWrapper wrapInstance = New productFamiliesWrapper();
            wrapInstance.productCategoryDetails = listOfProductCategory;
            wrapInstance.leadRecord = leadRecord;
            return wrapInstance;
        }catch(Exception e){
            system.debug('Error ====> '+e.getMessage()+e.getLineNumber());
            return null;
        }
    }

    @RemoteAction
    public static productFamiliesWrapper getRelatedSubCategories(String ProdCategoryId){
        try{
            List<Product_Sub_Category__c> listOfProdSubCategory = [SELECT Id,Name,Image_URL__c FROM Product_Sub_Category__c WHERE Product_Category__c =: ProdCategoryId AND Stanley__c = true ];
            Lead leadRecord = [SELECT Id, Name, LastModifiedDate FROM Lead ORDER BY LastModifiedDate DESC LIMIT 1];
            productFamiliesWrapper wrapInstance = New productFamiliesWrapper();
            wrapInstance.productSubCategoryDetails = listOfProdSubCategory;
            wrapInstance.leadRecord = leadRecord;
            return wrapInstance;
        }catch(Exception e){
            system.debug('Error ====> '+e.getMessage()+e.getLineNumber());
            return null;
        }
    }

    @RemoteAction
    public static productFamiliesWrapper getAllRelatedProducts(string prodSubCatId){
        try{
            List<Product2> listOfAllProducts = [SELECT Id,Name,Product_Link_1__c,Product_Link_2__c,Price__c,Allowed_Discount__c,Discount_Price__c,Ardex__c FROM Product2 WHERE Product_Category__c =: prodSubCatId AND Ardex__c = true ];
            Lead leadRecord = [SELECT Id, Name, LastModifiedDate FROM Lead ORDER BY LastModifiedDate DESC LIMIT 1];
            productFamiliesWrapper wrapInstance = New productFamiliesWrapper();
            wrapInstance.productAllDetails = listOfAllProducts;
            wrapInstance.leadRecord = leadRecord;
            return wrapInstance;
        }catch(Exception e){
            system.debug('Error ====> '+e.getMessage()+e.getLineNumber());
            return null;
        }
    }

    @RemoteAction
    public static productFamiliesWrapper getProductDetail(string productId){
        try{
            Product2 productRecord = [SELECT Id,Name,Product_Link_1__c,Product_Link_2__c,Price__c,Allowed_Discount__c,Discount_Price__c,Description, Product_Feature__c,Ardex__c, More_Information__c, Ratings_Reviews__c, Product_Availability__c FROM Product2 WHERE Id =: productId AND Ardex__c = true ];
            Lead leadRecord = [SELECT Id, Name, LastModifiedDate FROM Lead ORDER BY LastModifiedDate DESC LIMIT 1];
            productFamiliesWrapper wrapInstance = New productFamiliesWrapper();
            wrapInstance.singleProductDetail = productRecord;
            wrapInstance.leadRecord = leadRecord;
            return wrapInstance;
        }catch(Exception e){
            system.debug('Error ====> '+e.getMessage()+e.getLineNumber());
            return null;
        }
    }

    @RemoteAction
    public static String addToCart(string productId, integer quantity){
        try{
            List<Lead> leadRecords = [SELECT Id, Name, LastModifiedDate FROM Lead ORDER BY LastModifiedDate DESC];
            	Product_Interested_In__c pi = New 	Product_Interested_In__c();
            pi.Lead__C = leadRecords[0].Id;
            pi.Product__c = productId;
            pi.Quantity__c = Integer.valueOf(quantity);
            pi.Account__c = '0010T00000k9rg3QAA';
            insert pi;
            
            String opporb2bId ='0060T000007irrQQAQ';
            String opporb2cId ='0060T000007irrfQAA';
            List<OpportunityLineItem> recordsToInsert = new List<OpportunityLineItem>();
            
            OpportunityLineItem oli = new OpportunityLineItem();
            oli.Product2Id = productId;
            oli.Quantity = quantity;
            oli.OpportunityId = opporb2bId;
            oli.TotalPrice = Decimal.valueOf('1');
            recordsToInsert.add(oli);
            
            OpportunityLineItem olt = new OpportunityLineItem();
            olt.Product2Id = productId;
            olt.Quantity = quantity;
            olt.OpportunityId = opporb2cId;
            olt.TotalPrice = Decimal.valueOf('1');
            recordsToInsert.add(olt);

           

            
            insert recordsToInsert;
            
            return 'Success';
        }catch(Exception e){
            return e.getMessage();
        }
    }
    
    public class productFamiliesWrapper{
        public List<Product_Type__c> productTypeDetails;
        public List<Product_Category__c> productCategoryDetails;
        public List<Product_Sub_Category__c> productSubCategoryDetails;
        public List<Product2> productAllDetails;
        public Product2 singleProductDetail;
        public Lead leadRecord;
    }

}