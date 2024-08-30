public class CreditNoteWrapper {

    public String documentNo { get; set; }
    public String documentDate { get; set; }
    public String customerRef { get; set; }
    public String modelTermPay { get; set; }
    public String destination { get; set; }
    public String branch { get; set; }
    public List<CreditNoteItem> creditNoteItems { get; set; }
    public List<HSNDetail> hsnDetails { get; set; }
    
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

    public Decimal totalQuantity { get; set; }
    public Decimal totalNetValue { get; set; }
    public Decimal totalTaxableValue { get; set; }
    public Decimal totalCentralTaxAmount { get; set; }
    public Decimal totalStateTaxAmount { get; set; }
    public Decimal totalIntegratedTaxAmount { get; set; }
    public Decimal totalHSNTotal { get; set; }
    public Decimal cgst { get; set; }
    public Decimal sgst { get; set; }
    public Decimal total { get; set; }
    public Decimal rounding { get; set; }
    public Decimal totalRounded { get; set; }

    public CreditNoteWrapper() {
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
            creditNoteItems = new List<CreditNoteItem>();
            hsnDetails = new List<HSNDetail>();

            // Fetch company info from custom metadata
            fetchCompanyInfo();
            
            // Replace the sample data with actual data retrieval logic
            documentNo = '2402068';
            documentDate = '27/06/2024';
            customerRef = '230223253/29/03/24';
            modelTermPay = 'Net-30';
            destination = 'Bangalore';
            branch = 'E-CITY WAREHOUSE';
            
            // Sample credit note items
            creditNoteItems.add(new CreditNoteItem(1, 'GIT223OP&I161D1', 'OP & I', 'HO 161 DINING TABLE', 'NA', 'NA', 'NA', 'Dining Table', 1, 'NOS', 139427.12, 139427.12));
            creditNoteItems.add(new CreditNoteItem(2, 'FGITTONELLI0004', 'Tonelli', 'Tonelli-Pulse CT-Magazine Rack Smoked Top', 'NA', 'NA', 'NA', 'Centre Table', 1, 'NOS', 136661.02, 136661.02));
            creditNoteItems.add(new CreditNoteItem(3, '111DG36SOF1STR', 'Design Glamour', 'Sofitel', 'Scandinavia Max', 'NA', 'NA', 'Dining Chair', 3, 'No.', 45370.34, 136111.02));
            creditNoteItems.add(new CreditNoteItem(4, '11SBAVERYSM1S', 'BOUTIQUE', 'AVERY', 'Scandinavia Max', 'NA', 'NA', '1Str', 2, 'No.', 67587.29, 135174.58));
            creditNoteItems.add(new CreditNoteItem(5, 'FGGLECHRI00109', 'Christopher Guy', 'COFFCE TABLE HARPER', 'NA', 'NA', 'NA', 'Centre Table', 1, 'NOS', 135055.93, 135055.93));
            creditNoteItems.add(new CreditNoteItem(6, '51305BEDSHEETQI', 'Accessories', 'Bed Sheet Queen', 'NA', 'NA', 'NA', 'NA', 15, 'No.', 8994.01, 134910.17));
            creditNoteItems.add(new CreditNoteItem(7, '1ACMS02CA2STRM', 'American Comfort', 'Carter', 'Scandinavia', 'NA', 'NA', '2Str', 1, 'Seater', 132016.10, 132016.10));
            creditNoteItems.add(new CreditNoteItem(8, 'CALACATTAMAGNII', 'Design Attitude', 'Pear Calacatta Magnifico', 'NA', 'NA', 'NA', 'Dining Table', 1, 'Pair', 130714.41, 130714.41));
            creditNoteItems.add(new CreditNoteItem(9, '1DEATDISTABLE14', 'Design Attitude', 'Discussion Table 14 Feet', 'NA', 'NA', 'NA', 'Dining Table', 1, 'NOS', 127572.03, 127572.03));
            creditNoteItems.add(new CreditNoteItem(10, 'FG118KITHAFSPAZ', 'Accessories', 'Spazio Body Sample 537.81.203', 'NA', 'NA', 'NA', 'Accessories', 1, 'NOS', 126238.14, 126238.14));
            creditNoteItems.add(new CreditNoteItem(11, 'FGGLECHRI01065', 'Christopher Guy', 'Mirrors 50-1686 20th Century Silver', 'NA', 'NA', 'NA', 'Mirror', 1, 'NOS', 122676.27, 122676.27));
            creditNoteItems.add(new CreditNoteItem(12, 'GLEQUACARPE00', 'Qaleen', 'Tuscany 1001134', 'NA', 'NA', 'NA', 'Carpet', 1, 'NOS', 124614.41, 124614.41));
            creditNoteItems.add(new CreditNoteItem(13, 'RLITCATT2020128', 'Cattelan Italia', 'Otto', 'NA', 'NA', 'NA', 'Centre Table', 1, 'NOS', 126009.32, 126009.32));
            creditNoteItems.add(new CreditNoteItem(14, 'SRLITCOND202217', 'Conde House', 'NA', 'NA', 'NA', 'NA', 'Rocker', 1, 'NOS', 129100.00, 129100.00));

            // Sample HSN details
            hsnDetails.add(new HSNDetail('64031920', 522423.74, 0.00, 9.00, 47018.14, 9.00, 47018.14, 0, 0.00, 94036.27));
            hsnDetails.add(new HSNDetail('94016100', 925744.07, 0.00, 9.00, 83316.97, 9.00, 83316.97, 0, 0.00, 166633.93));
            hsnDetails.add(new HSNDetail('9403600', 126009.32, 0.00, 9.00, 11340.84, 9.00, 11340.84, 0, 0.00, 22681.68));
            hsnDetails.add(new HSNDetail('94036000', 262103.39, 0.00, 9.00, 23589.31, 9.00, 23589.31, 0, 0.00, 47178.61));

            // Calculate totals
            totalQuantity = 0;
            totalNetValue = 0;
            for (CreditNoteItem item : creditNoteItems) {
                totalQuantity += item.quantity;
                totalNetValue += item.netValue;
            }
            totalTaxableValue = 0;
            totalCentralTaxAmount = 0;
            totalStateTaxAmount = 0;
            totalIntegratedTaxAmount = 0;
            totalHSNTotal = 0;
            for (HSNDetail hsn : hsnDetails) {
                totalTaxableValue += hsn.taxableValue;
                totalCentralTaxAmount += hsn.centralTaxAmount;
                totalStateTaxAmount += hsn.stateTaxAmount;
                totalIntegratedTaxAmount += hsn.integratedTaxAmount;
                totalHSNTotal += hsn.total;
            }

            // Calculate CGST and SGST
            cgst = (totalTaxableValue * 9) / 100;
            sgst = (totalTaxableValue * 9) / 100;

            // Total is the sum of subTotal, CGST, and SGST
            total = totalTaxableValue + cgst + sgst;

            // Calculate rounding
            totalRounded = Math.round(total);
            rounding = totalRounded - total;

            // Set Bill To and Ship To information
            billTo = '5, Richmond Road Flyover, Bengaluru,<br/>Bengaluru - 560025';
            shipTo = 'Near Ashoka Pillar Bangalore,<br/>House No. 15, Gopalan Nilayam, 5Th Cross, 1St <br/>Block, Jayanagar,<br/>Bengaluru - 560011';
          
        } catch (Exception e) {
            errorMessage = 'An error occurred while initializing the credit note data: ' + e.getMessage();
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

    // CreditNoteItem class to hold credit note item details
    public class CreditNoteItem {
        public Integer slNo { get; set; }
        public String itemNo { get; set; }
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
        
        public CreditNoteItem(Integer slNo, String itemNo, String classification, String model, String specialCase, String range, String colour, String seater, Decimal quantity, String uom, Decimal rate, Decimal netValue) {
            this.slNo = slNo;
            this.itemNo = itemNo;
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

    // HSNDetail class to hold HSN/SAC details
    public class HSNDetail {
        public String hsnSac { get; set; }
        public Decimal taxableValue { get; set; }
        public Decimal freight { get; set; }
        public Decimal centralTaxRate { get; set; }
        public Decimal centralTaxAmount { get; set; }
        public Decimal stateTaxRate { get; set; }
        public Decimal stateTaxAmount { get; set; }
        public Decimal integratedTaxRate { get; set; }
        public Decimal integratedTaxAmount { get; set; }
        public Decimal total { get; set; }
        
        public HSNDetail(String hsnSac, Decimal taxableValue, Decimal freight, Decimal centralTaxRate, Decimal centralTaxAmount, Decimal stateTaxRate, Decimal stateTaxAmount, Decimal integratedTaxRate, Decimal integratedTaxAmount, Decimal total) {
            this.hsnSac = hsnSac;
            this.taxableValue = taxableValue;
            this.freight = freight;
            this.centralTaxRate = centralTaxRate;
            this.centralTaxAmount = centralTaxAmount;
            this.stateTaxRate = stateTaxRate;
            this.stateTaxAmount = stateTaxAmount;
            this.integratedTaxRate = integratedTaxRate;
            this.integratedTaxAmount = integratedTaxAmount;
            this.total = total;
        }
    }
}