@isTest
public class ProductControllerTest {

    @isTest
    static void testProductControllerInitialization() {
        Account testAccount = new Account(Name = 'Test Account');
        insert testAccount;
        
        Opportunity testOpportunity = new Opportunity(
            Name = 'Test Opportunity',
            AccountId = testAccount.Id,
            CloseDate = Date.today().addMonths(1),
            StageName = 'Prospecting'
        );
        insert testOpportunity;

       /* Product2 testProduct = new Product2(
            Name = 'MaxTestProduct',
            ProductCode = 'MTP001'
        );
        insert testProduct;*/
        
        Product2 testProduct = new Product2();
        testProduct.Name = 'MaxTestProduct';
        insert testProduct;

       /* Id standardPricebookId = Test.getStandardPricebookId();
        Pricebook2 standardPricebook;
        if (standardPricebookId == null) {
            standardPricebook = new Pricebook2(
                Name = 'Standard Pricebook',
                IsActive = true
            );
            insert standardPricebook;
        }*/
        
        Id pricebookId = Test.getStandardPricebookId();
        Pricebook2 standardPricebook = new Pricebook2(
            Id = pricebookId,
            IsActive = true
        );
        update standardPricebook;

        PricebookEntry testPbe = new PricebookEntry(
            Pricebook2Id = standardPricebook.Id,
            Product2Id = testProduct.Id,
            UnitPrice = 100,
            IsActive = true
        );
        insert testPbe;

        Quote testQuote = new Quote(
            Name = 'Test Quote',
            OpportunityId = testOpportunity.Id,
            Status = 'Draft',
            Pricebook2Id = standardPricebook.Id
        );
        insert testQuote;

        QuoteLineItem testQli = new QuoteLineItem(
            QuoteId = testQuote.Id,
            Product2Id = testProduct.Id,
            UnitPrice = 100.00,
            Quantity = 2,
            PricebookEntryId = testPbe.Id
        );
        insert testQli;

        Terms_Condition__c testTermsConditions = new Terms_Condition__c(
            Warranty__c = '1 Year',
            Transit_Insurance_New__c = 'Yes',
            Tax_and_Duties_new__c = 'Included',
            Installation_New__c = 'Yes',
            Unloading_New__c = 'Yes',
            Supply_New__c = 'Yes'
        );
        insert testTermsConditions;

        ApexPages.StandardController sc = new ApexPages.StandardController(testQuote);
        ProductController controller = new ProductController(sc);

      
        Test.startTest();
        List<Product2> productList = ProductController.getProductList(10, 1);
        Test.stopTest();
        
       
    }
}