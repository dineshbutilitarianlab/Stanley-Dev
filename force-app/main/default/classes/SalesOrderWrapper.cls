/*
 * Author : Umesh Dadhaniya 
 * Created Date: 01/07/2024
*/

public class SalesOrderWrapper {
    public String salesOrderNo { get; set; }
    public String orderDate { get; set; }
    public String customerRef { get; set; }
    public List<OrderItem> orderItems { get; set; }
    public Decimal totalQuantity { get; set; }
    public Decimal totalNetValue { get; set; }
    public Decimal cgst { get; set; }
    public Decimal sgst { get; set; }
    public Decimal rounding { get; set; }
    public Decimal totalAmount { get; set; }
    public String totalAmountInWords { get; set; }
    public String errorMessage { get; set; }

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
    
    public String billTo { get; set; }
    public String shipTo { get; set; }

    public SalesOrderWrapper() {
        try {
            // Initialize variables
            salesOrderNo = '';
            orderDate = '';
            customerRef = '';
            orderItems = new List<OrderItem>();
            totalQuantity = 0;
            totalNetValue = 0;
            cgst = 0;
            sgst = 0;
            rounding = 0;
            totalAmount = 0;
            totalAmountInWords = '';
            billTo = '';
            shipTo = '';

            // Fetch company info from custom metadata
            fetchCompanyInfo();

            // Replace the sample data with actual data retrieval logic
            salesOrderNo = '240201979';
            orderDate = '27/06/2024';
            customerRef = 'IND-406';

            orderItems.add(new OrderItem(1, 'SRLHOMEYCT and 10010', 'OP and I', 'OPandI-COTBXG-06-N Console Table', 'NA', 'NA', 'NA', 'Centre Table', 1.00, 'NOS', 38135.59, 38135.59));
            orderItems.add(new OrderItem(2, 'SRLHOMEYCT and 10011', 'OP and II', 'OPandII-COTBXG-07-N Dining Table', 'NA', 'NA', 'NA', 'Dining Table', 2.00, 'NOS', 45123.45, 90246.90));

            // Calculate totals
            calculateTotals();

            // Convert total amount to words using NumberToText class
            totalAmountInWords = NumberToText.convert(totalAmount.intValue()) + ' only';
            
            // Set Bill To and Ship To information
            billTo = '2005819<br/>Yogesh R Puranik<br/>Mall Whitefield,<br/>Flat No C1206 Inor Carmel Hieghts Next To Nexus Foram,<br/>Bangalore - 560066<br/>Contact No.: 8600998906<br/>GSTIN/UIN:<br/>State Name: Karnataka Code: 29';
            shipTo = 'Yogesh R Puranik<br/>Mall Whitefield,<br/>Flat No C1206 Inor Carmel Hieghts Next To Nexus Foram,<br/>Bangalore - 560066<br/>GSTIN/UIN:<br/>State Name: Karnataka Code: 29';
        } catch (Exception e) {
            errorMessage = 'An error occurred while initializing the sales order data: ' + e.getMessage();
        }
    }

    private void fetchCompanyInfo() {
        try {
            // Fetch the first record. Customize if needed to fetch specific records.
            CompanyInfo__mdt companyInfoMDT = [SELECT MasterLabel, Street__c, City__c, Zip_Postal_Code__c, State_Province__c, Country__c, CIN__c, GSTIN__c, PAN__c, Code__c FROM CompanyInfo__mdt LIMIT 1];
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
        } catch (Exception e) {
            errorMessage = 'Error fetching company info: ' + e.getMessage();
        }
    }

    private void calculateTotals() {
        try {
            totalQuantity = 0;
            totalNetValue = 0;
            for (OrderItem item : orderItems) {
                if (item != null) {
                    totalQuantity += item.quantity != null ? item.quantity : 0;
                    totalNetValue += item.netValue != null ? item.netValue : 0;
                }
            }
            // Calculate CGST and SGST
            cgst = totalNetValue * 0.09;
            sgst = totalNetValue * 0.09;
            
            // Calculate rounding if necessary
            rounding = totalNetValue + cgst + sgst - Math.floor(totalNetValue + cgst + sgst);
            
            // Calculate total amount
            totalAmount = totalNetValue + cgst + sgst + rounding;
        } catch (Exception e) {
            errorMessage = 'An error occurred while calculating totals: ' + e.getMessage();
        }
    }

    public class OrderItem {
        public Integer siNo { get; set; }
        public String itemCode { get; set; }
        public String classification { get; set; }
        public String model { get; set; }
        public String specialCase { get; set; }
        public String range { get; set; }
        public String colour { get; set; }
        public String seater { get; set; }
        public Decimal quantity { get; set; }
        public String uom { get; set; }
        public Decimal rate { get; set; }
        public Decimal netValue { get; set; }

        public OrderItem(Integer siNo, String itemCode, String classification, String model, String specialCase, String range, String colour, String seater, Decimal quantity, String uom, Decimal rate, Decimal netValue) {
            this.siNo = siNo;
            this.itemCode = itemCode;
            this.classification = classification;
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