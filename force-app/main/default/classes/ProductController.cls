public class ProductController {

    public String recordId {get;set;}
    public  Quote quotesList {set;get;}
    public List<QuoteLineItem> quoteLineItems {set;get;}
    public Product2 products {set;get;}
    public Decimal subTotal {set;get;}
    public Decimal gst {set;get;}
    public Decimal grandTotal {set;get;}
    public Contentversion cvtestidset {set;get;}
    public String ContentversionId {set;get;}
    public DateTime todayDate {set;get;}
    public DateTime myDateTime  {set;get;}
    public string currentDate {set;get;}
    public String validityDate {set;get;}
    public Terms_Condition__c termsConditions {set;get;}
    public List<OpportunityLineItem> oppLI {set;get;}
    public Decimal TotalPrice {set;get;}
    public Decimal FinalPrice {set;get;}
    // public decimal transportPrice {set;get;}
    
    public ProductController(ApexPages.StandardController controller){
        try{
            todayDate =   system.today() ;
            myDateTime = DateTime.newInstance(todayDate.year(), todayDate.month(), todayDate.day()); 
            currentDate = myDateTime.format('dd MMM yyyy');
            System.debug(currentDate);
            
            myDateTime = DateTime.newInstance(todayDate.year(), todayDate.month()+1, todayDate.day()); 
            validityDate = myDateTime.format('dd MMM yyyy');
            System.debug(validityDate);
            
            recordId = controller.getId();
            System.debug('recordId == >'+recordId);
            
            quotesList = [SELECT Id, Status, Name, ShippingHandling, TotalPrice FROM Quote WHERE id = :recordId];
            system.debug('quotesList===>'+quotesList);
            
            // transportPrice = quotesList.Transport_price__c + quotesList.Installation_Price__c ;
            // System.debug('transportPrice---->'+transportPrice);
             
             
            
            if(!String.isBlank(quotesList.id)){
                subTotal = 0;
                gst = 0;
                grandTotal = 0;
                quoteLineItems = [select Id, TotalPrice, Subtotal, UnitPrice, Quantity, Description, Discount, ListPrice, QuoteId, Product2Id, Product2.Name, Product2.Brand__c, Product2.Description, product2.Image__c, product2.Dimension__c, Quote.OpportunityId from QuoteLineItem where QuoteId =:quotesList.Id];
                oppLI = [SELECT Id, OpportunityId, Opportunity.Account.Name from OpportunityLineItem where OpportunityId= : quoteLineItems[0].Quote.OpportunityId];
                System.debug('oppLI---->'+oppLI);
                
                 
                termsConditions = [SELECT Id,Warranty__c,Transit_Insurance_New__c,Tax_and_Duties_new__c,Installation_New__c,Unloading_New__c,Supply_New__c FROM Terms_Condition__c];
                
                // smsList = [SELECT ID, OrderProduct__c,Specification_Header__c,Specification_Value__c,Specification_Header__r.Header__c,Specification_Value__r.Value__c FROM Sales_Material_Specification__c WHERE OrderProduct__c =:oppLI[0].ID];
                // system.debug('smsList---->'+smsList);
               
                // for(QuoteLineItem qli : quoteLineItems){
                //         TotalPrice =  qli.ListPrice + transportPrice ;
                //                gst    = TotalPrice * qli.Product2.Gst__c / 100;
                //          FinalPrice = TotalPrice + gst;
                 
                // }
            }   //System.debug('quoteLineItems----->'+quoteLineItems);
        } 
        catch(exception e){
            system.debug('exception Message=====>'+e.getMessage());
            system.debug('exception Line Number=====>'+e.getLineNumber());
        }
        
    }


	@AuraEnabled
    public static List<Product2> getProductList(Integer pageSize, Integer pageNumber){
        Integer offset = (pageNumber - 1) * pageSize;
        List<Product2> prodList = new List<Product2>();
        prodList = [SELECT Id, Name,ProductCode FROM Product2 WHERE Name LIKE 'Max%'  ];
       // SELECT Product_Id__r.Name, Product_Id__r.ProductCode, is_Item_Available__c, Available_Quantity__c, Store__r.Name FROM Store_Inventory__c WHERE Product_Id__r.Name LIKE 'Max%'
        return prodList;
    }

}