public class StockTransferWrapper {
    public String dcNo { get; set; }
    public String dcDate { get; set; }
    public String vehicleNo { get; set; }
    public String dueDate { get; set; }
    public String eWayBillNo { get; set; }
    public String fromWarehouse { get; set; }
    public String toWarehouse { get; set; }
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

    public Address shipFrom { get; set; }
    public Address shipTo { get; set; }
    public List<Item> items { get; set; }

    public StockTransferWrapper() {
        try {
            fetchCompanyInfo();
            
            // Initialize variables
            dcNo = '240201067';
            dcDate = '26-06-2024';
            vehicleNo = '-';
            dueDate = '26-06-2024';
            eWayBillNo = '-';
            fromWarehouse = 'SRWHEITY';
            toWarehouse = 'SRWHEITY';

            shipFrom = new Address('Stanley Retail Ltd. -', 'Old Sy.No. 38/2,2041/38/1A and 2035/38/1', 'Electronic City Phase-2', 'Bangalore-560100', 'Karnataka', '29', '29AAMCS0959F1ZY');
            shipTo = new Address('Stanley Retail Ltd. - SOSL (SRL) WARE HOUSE', '52,66 & 67', 'BOMMASANDRA JIGANI LINK RD, INDUSTRIAL AREA, JIGANI, ANEKAL TALUK', 'Bangalore - 562106', 'Karnataka', '29', '29AAMCS0959F1ZY');

            items = new List<Item>{
                new Item(1, 'NL Miami WO Backrest Mechanism 3Str Bed Berlin Fabric', 'Now Living', '#906', '9403.50.10', '3Str Bed', 'NO', 1.00, 33460.00, 33460.00),
                    new Item(2, 'NL Miami WO Backrest Mechanism 3Str Bed Berlin Fabric', 'Now Living', '#906', '9403.50.10', '3Str Bed', 'NO', 1.00, 33460.00, 33460.00)
            };
        } catch (Exception e) {
            System.debug('An error occurred while initializing the stock transfer data: ' + e.getMessage());
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

    public Decimal getTotalQuantity() {
        Decimal totalQty = 0;
        for (Item item : items) {
            totalQty += item.qty;
        }
        return totalQty;
    }

    public Decimal getTotalValue() {
        Decimal totalValue = 0;
        for (Item item : items) {
            totalValue += item.value;
        }
        return totalValue;
    }

    public class Address {
        public String name { get; set; }
        public String address1 { get; set; }
        public String address2 { get; set; }
        public String city { get; set; }
        public String state { get; set; }
        public String stateCode { get; set; }
        public String gstin { get; set; }

        public Address(String name, String address1, String address2, String city, String state, String stateCode, String gstin) {
            this.name = name;
            this.address1 = address1;
            this.address2 = address2;
            this.city = city;
            this.state = state;
            this.stateCode = stateCode;
            this.gstin = gstin;
        }
    }

    public class Item {
        public Integer siNo { get; set; }
        public String description { get; set; }
        public String brand { get; set; }
        public String colour { get; set; }
        public String hsn { get; set; }
        public String seater { get; set; }
        public String uom { get; set; }
        public Decimal qty { get; set; }
        public Decimal rate { get; set; }
        public Decimal value { get; set; }

        public Item(Integer siNo, String description, String brand, String colour, String hsn, String seater, String uom, Decimal qty, Decimal rate, Decimal value) {
            this.siNo = siNo;
            this.description = description;
            this.brand = brand;
            this.colour = colour;
            this.hsn = hsn;
            this.seater = seater;
            this.uom = uom;
            this.qty = qty;
            this.rate = rate;
            this.value = value;
        }
    }
}