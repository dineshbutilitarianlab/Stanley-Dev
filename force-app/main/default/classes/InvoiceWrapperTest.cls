@isTest
public class InvoiceWrapperTest {
    @isTest
    static void testInvoiceWrapperInitialization() {
        InvoiceWrapper invoice = new InvoiceWrapper();
        System.assertEquals('240232489', invoice.documentNo);
        System.assertEquals('27/06/2024', invoice.documentDate);
        System.assertEquals('GLE 15963', invoice.customerRef);
        System.assertEquals('Net-30', invoice.modelTermPay);
        System.assertEquals('Bengaluru', invoice.destination);
        System.assertEquals('SRL-Bangalore', invoice.branch);
        System.assertEquals(3, invoice.orderItems.size());
        InvoiceWrapper.OrderItem firstItem = invoice.orderItems[0];
        System.assertEquals(1, firstItem.slNo);
        System.assertEquals('Re-upholstery Customised', firstItem.model);
        System.assertEquals('Sofa', firstItem.specialCase);
        System.assertEquals('Customer Fabric', firstItem.range);
        System.assertEquals('Customer Fabric', firstItem.colour);
        System.assertEquals('1 SEATER', firstItem.seater);
        System.assertEquals(1, firstItem.quantity);
        System.assertEquals('No.', firstItem.uom);
        System.assertEquals(132338.00, firstItem.rate);
        System.assertEquals(132338.00, firstItem.netValue);
        Decimal expectedSubTotal = 132338.00 + 41626.00 + 570135.00;
        Decimal expectedTotalQuantity = 3;
        System.assertEquals(expectedSubTotal, invoice.subTotal);
        System.assertEquals(expectedTotalQuantity, invoice.totalQuantity);
        Decimal expectedCgst = (expectedSubTotal * 9) / 100;
        Decimal expectedSgst = (expectedSubTotal * 9) / 100;
        System.assertEquals(expectedCgst, invoice.cgst);
        System.assertEquals(expectedSgst, invoice.sgst);
        Decimal expectedTotal = expectedSubTotal + expectedCgst + expectedSgst;
        System.assertEquals(expectedTotal, invoice.total);
        Decimal expectedTotalRounded = Math.round(expectedTotal);
        Decimal expectedRounding = expectedTotalRounded - expectedTotal;
        System.assertEquals(expectedTotalRounded, invoice.totalRounded);
        System.assertEquals(expectedRounding, invoice.rounding);
        System.assertEquals('5, Richmond Road Flyover, Bengaluru,<br/>Bengaluru - 560025', invoice.billTo);
        System.assertEquals('Near Ashoka Pillar Bangalore,<br/>House No. 15, Gopalan Nilayam, 5Th Cross, 1St <br/>Block, Jayanagar,<br/>Bengaluru - 560011', invoice.shipTo);
    }
}