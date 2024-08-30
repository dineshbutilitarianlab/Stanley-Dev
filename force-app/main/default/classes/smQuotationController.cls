/*
Author: Banoj
Created Date: 02/07/24
*/

public class smQuotationController {
    
    public List<ProductData> productDatas { get; set; }
    public List<Address> addresslist  { get; set; }
    public String AccountName { get; set; }
    public String Bank { get; set; }
    public String AccountNumber { get; set; }
    public String AaccountType { get; set; }
    public String Branch { get; set; }
    public String IFSCCode { get; set; }

    public smQuotationController() {
        try {
            fetchProductInfo(); 
            fetchCompanyInfo();
            initializeAddressList();
        } catch (Exception e) {
            System.debug('Error in smQuotationController constructor: ' + e.getMessage());
        }
    }

    private void fetchProductInfo() {
        productDatas = new List<ProductData>{
     new ProductData(
            '1', 'AMERICAN COMFORT', 'CHARLOTTE MOTION', '1 STR', ' 1,63200*8= 13,05,600' ,'1,18,200*8= 9,45,600' , '94,500*8= 7,56,000'
        ),

     new ProductData(
            '2', 'EUROPEAN ELEGANCE', 'CHARLOTTE MOTION', '2 STR', '1,63200*8= 13,05,600' ,'1,18,200*8= 9,45,600' , '94,500*8= 7,56,000'
     )};
    }
    
     private void initializeAddressList() {
        addresslist = new List<Address>{
            new Address('Customer details here', 'John Doe', '123 Main St, Anytown, USA', '123-456-7890')
        };
    }

    private void fetchCompanyInfo() {
        try {
            CompanyInfo__mdt companyInfoMDT = [SELECT Account_Name__c, Bank__c, Account_Number__c, Account_Type__c, Branch__c, IFSC_Code__c FROM CompanyInfo__mdt LIMIT 1];
            if (companyInfoMDT != null) {
                AccountName = companyInfoMDT.Account_Name__c;
                Bank = companyInfoMDT.Bank__c;
                AccountNumber = companyInfoMDT.Account_Number__c;
                AaccountType = companyInfoMDT.Account_Type__c;
                Branch = companyInfoMDT.Branch__c;
                IFSCCode = companyInfoMDT.IFSC_Code__c;
            }
        } catch (Exception e) {
            System.debug('Error fetching company info: ' + e.getMessage());
        }
    }
     /* public Decimal getmrp() {
        Decimal totalmrp = 0;
        for (ProductData prod : productDatas) {
            totalmrp += prod.mrp;
        }
        return totalmrp;
    }
    
     public Decimal getofferprice() {
        Decimal totalofferprice = 0;
        for (ProductData prod : productDatas) {
            totalofferprice += prod.offerprice;
        }
        return totalofferprice;
    }
     public Decimal getfinalprice() {
        Decimal totalfinalprice = 0;
        for (ProductData prod : productDatas) {
            totalfinalprice += prod.finalprice;
        }
        return totalfinalprice;
    }*/

    public class ProductData {
        public String slno { get; set; }
        public String product { get; set; }
        public String model { get; set; }
        public String sitter { get; set; }
        public String mrp { get; set; }
        public String offerprice { get; set; }
        public String finalprice { get; set; }

        public ProductData(String slno, String product, String model, String sitter,
                           String mrp, String offerprice, String finalprice) {
            this.slno = slno;
            this.product = product;
            this.model = model;
            this.sitter = sitter;
            this.mrp = mrp;
            this.offerprice = offerprice;
            this.finalprice = finalprice;
        }
    }
    
    public class Address {
        public String customerDetails { get; set; }
        public String name { get; set; }
        public String Address { get; set; }
        public String phone { get; set; }
       

        public Address(String customerDetails, String name, String Address, String phone) {
            this.customerDetails = customerDetails;
            this.name = name;
            this.Address = Address;
            this.phone = phone;
        }
    }

}