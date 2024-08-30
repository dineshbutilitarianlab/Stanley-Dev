public class PurchaseOrderWrapper {
    public String supplier { get; set; }
    public String shipTo { get; set; }
    public String purchaseOrderNo { get; set; }
    public String orderDate { get; set; }
    public String purchaseType { get; set; }
    public String purchaseTerms { get; set; }
    public String supplierRefNo { get; set; }
    public String deliveryDate { get; set; }
    public List<OrderItem> orderItems { get; set; }
    public Decimal subTotalQuantity { get; set; }
    public Decimal subTotalValue { get; set; }
    public Decimal cgst { get; set; }
    public Decimal sgst { get; set; }
    public Decimal rounding { get; set; }
    public Decimal totalAmount { get; set; }
    public String totalAmountInWords { get; set; }
    public String remarks { get; set; }
    public CustomerDetails customerDetails { get; set; }
    public CustomerDetails franchiseDetails { get; set; }

    public PurchaseOrderWrapper() {
        try {
            // Initialize variables with sample data
            supplier = 'ICVSLL<br/>Stanley Lifestyles Limited-CR<br/>Bangalore-Hosur Main Road, Bangalore South,<br/>Unit-V, No #16/2/16/3, Veerasandra Village,<br/>Bangalore - 560100<br/>Contact No.:<br/>GSTIN/UIN: 29AALCS3769P1ZB<br/>State Name : Karnataka Code : 29';
            shipTo = 'Yogesh R Puranik<br/>Mall Whitefield,<br/>Flat No C1206 Inor Carmel Hieghts Next To Nexus Foram,<br/>Bangalore - 560066<br/>GSTIN/UIN:<br/>State Name: Karnataka Code: 29';
            purchaseOrderNo = '240201979';
            orderDate = '27/06/2024';
            purchaseType = '';
            purchaseTerms = 'Net-30';
            supplierRefNo = 'K3N Unit 2 - 012';
            deliveryDate = '15-7-2024';
            orderItems = new List<OrderItem>{
                new OrderItem(1, 'FG111UDENSMSS4STR', 'Denver', 'Stationery Sofa', 'Scandinavia Max', 'Ice Age', '', '', 'SS', '45str', 1, 'Seater', 231697.00, 231697.00),
                new OrderItem(2, 'FG111LUXDENVERSSM3STR', 'Denver', 'Stationery Sofa', 'Scandinavia Max', 'Ice Age', '', '', 'SS', '35str', 1, 'Seater', 196608.00, 196608.00),
                new OrderItem(3, 'FG111LUXROLLORCM25TR', 'ROLLO', 'Stationery Sofa', 'Cashmere', 'New Cognac', '', '', 'Brass', '2.5str', 1, 'Seater', 204701.00, 204701.00),
                new OrderItem(4, 'FG111LUXNICOROBRCM25TR', 'NICO', 'Stationery Sofa', 'Cashmere', 'Gallimo', '', '', 'Brass', '2.5str', 1, 'Seater', 118696.00, 118696.00),
                new OrderItem(5, 'FG111LACSO7CHESTERUTR', 'Chester New', 'Stationery Sofa', 'Tuscano Nova', 'Cherry', '', '', 'Brass', '3str', 1, 'Seater', 155811.00, 155811.00),
                new OrderItem(6, 'FG111LACSO7CHESTERUTR', 'Chester New', 'Stationery Sofa', 'Tuscano Nova', 'Cherful Cherry', '', '', 'Brass', '2str', 1, 'Seater', 128048.00, 128048.00),
                new OrderItem(7, 'FG111LUXAMOC5SSM3STR', 'Castro', 'Motion', 'Scandinavia Max', 'OXFORD GREY', '', '', 'SS', '3str', 1, 'Seater', 249884.00, 249884.00),
                new OrderItem(8, 'FG111LUXAMOC5SSM2STR', 'Castro', 'Motion', 'Scandinavia Max', 'OXFORD GREY', '', '', 'SS', '2str', 1, 'Seater', 183772.00, 183772.00)
            };

            // Calculate totals
            calculateTotals();

            // Convert total amount to words using NumberToText class
            totalAmountInWords = NumberToText.convert(totalAmount.intValue()) + ' only';

            // Set remarks and customer/franchise details
            remarks = 'Based On Sales Orders 240201096.<br/>1. DENVER 4+3 Str - FRONT:ICE AGE/BACK:DUSKY TAN<br/>2) Cheerful Cherry Colour 12% Discount';
            customerDetails = new CustomerDetails('K3N Lifestyles - Unit 2', '9903978887', 'Entrepreneur', 'Kolkata', '700046', 'West Bengal', 'Franchisee');
            franchiseDetails = new CustomerDetails('', '', '', '', '', '', '');
        } catch (Exception e) {
            // Handle exception
        }
    }

    private void calculateTotals() {
        subTotalQuantity = 0;
        subTotalValue = 0;
        for (OrderItem item : orderItems) {
            subTotalQuantity += item.quantity != null ? item.quantity : 0;
            subTotalValue += item.netValue != null ? item.netValue : 0;
        }
        cgst = subTotalValue * 0.09;
        sgst = subTotalValue * 0.09;
        rounding = -0.06; // Example rounding adjustment
        totalAmount = subTotalValue + cgst + sgst + rounding;
    }

    public class OrderItem {
        public Integer siNo { get; set; }
        public String itemCode { get; set; }
        public String modelName { get; set; }
        public String type { get; set; }
        public String range { get; set; }
        public String colour { get; set; }
        public String size { get; set; }
        public String others { get; set; }
        public String material { get; set; }
        public String configuration { get; set; }
        public Decimal quantity { get; set; }
        public String uom { get; set; }
        public Decimal rate { get; set; }
        public Decimal netValue { get; set; }

        public OrderItem(Integer siNo, String itemCode, String modelName, String type, String range, String colour, String size, String others, String material, String configuration, Decimal quantity, String uom, Decimal rate, Decimal netValue) {
            this.siNo = siNo;
            this.itemCode = itemCode;
            this.modelName = modelName;
            this.type = type;
            this.range = range;
            this.colour = colour;
            this.size = size;
            this.others = others;
            this.material = material;
            this.configuration = configuration;
            this.quantity = quantity;
            this.uom = uom;
            this.rate = rate;
            this.netValue = netValue;
        }
    }

    public class CustomerDetails {
        public String name { get; set; }
        public String contactNumber { get; set; }
        public String occupation { get; set; }
        public String city { get; set; }
        public String zipCode { get; set; }
        public String state { get; set; }
        public String residency { get; set; }

        public CustomerDetails(String name, String contactNumber, String occupation, String city, String zipCode, String state, String residency) {
            this.name = name;
            this.contactNumber = contactNumber;
            this.occupation = occupation;
            this.city = city;
            this.zipCode = zipCode;
            this.state = state;
            this.residency = residency;
        }
    }
}