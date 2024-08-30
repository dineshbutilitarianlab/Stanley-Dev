/*
 * Author : Umesh Dadhaniya 
 * Created Date: 02/07/2024
*/

public class InvoiceWrapper {

    public String documentNo { get; set; }
    public String documentDate { get; set; }
    public String customerRef { get; set; }
    public String modelTermPay { get; set; }
    public String destination { get; set; }
    public String branch { get; set; }
    public List<OrderItem> orderItems { get; set; }
    
    public String companyName { get; set; }
    public String street { get; set; }
    public String city { get; set; }
    public String zipCode { get; set; }
    public String stateName { get; set; }
    public String countryName { get; set; }
    public String CIN { get; set; }
    public String GSTIN { get; set; }
    public String PAN { get; set; }
    public String state { get; set; }
    public String code { get; set; }
    
    public String accountName { get; set; }
    public String bankName { get; set; }
    public String accountNo { get; set; }
    public String branchName { get; set; }
    public String ifscCode { get; set; }
    
    public String errorMessage { get; set; }
    
    public String billTo { get; set; }
    public String shipTo { get; set; }
    public Decimal subTotal { get; set; }
    public Decimal totalQuantity { get; set; }
    public Decimal total { get; set; }
    public Decimal cgst { get; set; }
    public Decimal sgst { get; set; }
    public Decimal rounding { get; set; }
    public Decimal totalRounded { get; set; }
    
    public InvoiceWrapper() {
        try {
            // Initialize variables
            documentNo = '';
            documentDate = '';
            customerRef = '';
            modelTermPay = '';
            destination = '';
            branch = '';
            billTo = '';
            shipTo = '';
            orderItems = new List<OrderItem>();
            subTotal = 0;
            totalQuantity = 0;
            total = 0;
            cgst = 0;
            sgst = 0;
            rounding = 0;
            totalRounded = 0;

            // Fetch company info from custom metadata
            fetchCompanyInfo();
            
            // Replace the sample data with actual data retrieval logic
            documentNo = '240232489';
            documentDate = '27/06/2024';
            customerRef = 'GLE 15963';
            modelTermPay = 'Net-30';
            destination = 'Bengaluru';
            branch = 'SRL-Bangalore';
            
            // Sample order items
            orderItems.add(new OrderItem(1, 'Re-upholstery Customised', 'Sofa', 'Customer Fabric', 'Customer Fabric', '1 SEATER', 1, 'No.', 132338.00, 132338.00));
            orderItems.add(new OrderItem(2, 'Re-upholstery Customised', 'Sofa', 'Customer Fabric', 'Customer Fabric', 'Puffee', 1, 'No.', 41626.00, 41626.00));
            orderItems.add(new OrderItem(3, 'Re-upholstery Customised', 'Sofa', 'Tuscana Nova', 'Wild Berry', '2 STR', 1, 'No.', 570135.00, 570135.00));

            // Calculate subTotal and totalQuantity
            for (OrderItem item : orderItems) {
                subTotal += item.netValue;
                totalQuantity += item.quantity;
            }

            // Calculate CGST and SGST
            cgst = (subTotal * 9) / 100;
            sgst = (subTotal * 9) / 100;

            // Total is the sum of subTotal, CGST, and SGST
            total = subTotal + cgst + sgst;
            
            // Calculate rounding
            totalRounded = Math.round(total);
            rounding = totalRounded - total;

            // Set Bill To and Ship To information
            billTo = '5, Richmond Road Flyover, Bengaluru,<br/>Bengaluru - 560025';
            shipTo = 'Near Ashoka Pillar Bangalore,<br/>House No. 15, Gopalan Nilayam, 5Th Cross, 1St <br/>Block, Jayanagar,<br/>Bengaluru - 560011';
          
        } catch (Exception e) {
            errorMessage = 'An error occurred while initializing the sales order data: ' + e.getMessage();
        }
    }
    
    private void fetchCompanyInfo() {
        try {
            // Fetch the first record. Customize if needed to fetch specific records.
            CompanyInfo__mdt companyInfoMDT = [SELECT MasterLabel, Street__c, City__c, Zip_Postal_Code__c, State_Province__c, Country__c, CIN__c, GSTIN__c, PAN__c, Code__c,Account_Name__c, Bank__c, Account_Number__c, Account_Type__c, Branch__c, IFSC_Code__c FROM CompanyInfo__mdt LIMIT 1];
            companyName = companyInfoMDT.MasterLabel;
            street = companyInfoMDT.Street__c;
            city = companyInfoMDT.City__c;
            zipCode = companyInfoMDT.Zip_Postal_Code__c;
            stateName = companyInfoMDT.State_Province__c;
            countryName = companyInfoMDT.Country__c;
            CIN = companyInfoMDT.CIN__c;
            GSTIN = companyInfoMDT.GSTIN__c;
            PAN = companyInfoMDT.PAN__c;
            state = companyInfoMDT.State_Province__c;
            code = companyInfoMDT.Code__c;
            accountName = companyInfoMDT.Account_Name__c;
            bankName = companyInfoMDT.Bank__c;
            accountNo = companyInfoMDT.Account_Number__c;
            branchName = companyInfoMDT.Branch__c;
            ifscCode = companyInfoMDT.IFSC_Code__c;
        } catch (Exception e) {
            errorMessage = 'Error fetching company info: ' + e.getMessage();
        }
    }

    // OrderItem class to hold order item details
    public class OrderItem {
        public Integer slNo { get; set; }
        public String model { get; set; }
        public String specialCase { get; set; }
        public String range { get; set; }
        public String colour { get; set; }
        public String seater { get; set; }
        public Decimal quantity { get; set; }
        public String uom { get; set; }
        public Decimal rate { get; set; }
        public Decimal netValue { get; set; }
        
        public OrderItem(Integer slNo, String model, String specialCase, String range, String colour, String seater, Decimal quantity, String uom, Decimal rate, Decimal netValue) {
            this.slNo = slNo;
            this.model = model;
            this.specialCase = specialCase;
            this.range = range;
            this.colour = colour;
            this.seater = seater;
            this.quantity = quantity;
            this.uom = uom;
            this.rate = rate;
            this.netValue = netValue;
        }
    }
}