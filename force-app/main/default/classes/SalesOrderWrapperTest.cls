@isTest
public class SalesOrderWrapperTest {

    @isTest
    static void testSalesOrderWrapperInitialization() {
        SalesOrderWrapper salesOrder = new SalesOrderWrapper();
        System.assertEquals('240201979', salesOrder.salesOrderNo);
        System.assertEquals('27/06/2024', salesOrder.orderDate);
        System.assertEquals('IND-406', salesOrder.customerRef);
        System.assertEquals(2, salesOrder.orderItems.size());
        SalesOrderWrapper.OrderItem firstItem = salesOrder.orderItems[0];
        System.assertEquals(1, firstItem.siNo);
        System.assertEquals('SRLHOMEYCT and 10010', firstItem.itemCode);
        System.assertEquals('OP and I', firstItem.classification);
        System.assertEquals('OPandI-COTBXG-06-N Console Table', firstItem.model);
        System.assertEquals('NA', firstItem.specialCase);
        System.assertEquals('NA', firstItem.range);
        System.assertEquals('NA', firstItem.colour);
        System.assertEquals('Centre Table', firstItem.seater);
        System.assertEquals(1.00, firstItem.quantity);
        System.assertEquals('NOS', firstItem.uom);
        System.assertEquals(38135.59, firstItem.rate);
        System.assertEquals(38135.59, firstItem.netValue);
        SalesOrderWrapper.OrderItem secondItem = salesOrder.orderItems[1];
        System.assertEquals(2, secondItem.siNo);
        System.assertEquals('SRLHOMEYCT and 10011', secondItem.itemCode);
        System.assertEquals('OP and II', secondItem.classification);
        System.assertEquals('OPandII-COTBXG-07-N Dining Table', secondItem.model);
        System.assertEquals('NA', secondItem.specialCase);
        System.assertEquals('NA', secondItem.range);
        System.assertEquals('NA', secondItem.colour);
        System.assertEquals('Dining Table', secondItem.seater);
        System.assertEquals(2.00, secondItem.quantity);
        System.assertEquals('NOS', secondItem.uom);
        System.assertEquals(45123.45, secondItem.rate);
        System.assertEquals(90246.90, secondItem.netValue);
        Decimal expectedTotalQuantity = 3.00;
        Decimal expectedTotalNetValue = 38135.59 + 90246.90;
        Decimal expectedCgst = expectedTotalNetValue * 0.09;
        Decimal expectedSgst = expectedTotalNetValue * 0.09;
        Decimal expectedRounding = expectedTotalNetValue + expectedCgst + expectedSgst - Math.floor(expectedTotalNetValue + expectedCgst + expectedSgst);
        Decimal expectedTotalAmount = expectedTotalNetValue + expectedCgst + expectedSgst + expectedRounding;
        
        System.assertEquals(expectedTotalQuantity, salesOrder.totalQuantity);
        System.assertEquals(expectedTotalNetValue, salesOrder.totalNetValue);
        System.assertEquals(expectedCgst, salesOrder.cgst);
        System.assertEquals(expectedSgst, salesOrder.sgst);
        System.assertEquals(expectedRounding, salesOrder.rounding);
        System.assertEquals(expectedTotalAmount, salesOrder.totalAmount);
        String expectedTotalAmountInWords = NumberToText.convert(expectedTotalAmount.intValue()) + ' only';
        System.assertEquals(expectedTotalAmountInWords, salesOrder.totalAmountInWords);
        String expectedBillTo = '2005819<br/>Yogesh R Puranik<br/>Mall Whitefield,<br/>Flat No C1206 Inor Carmel Hieghts Next To Nexus Foram,<br/>Bangalore - 560066<br/>Contact No.: 8600998906<br/>GSTIN/UIN:<br/>State Name: Karnataka Code: 29';
        String expectedShipTo = 'Yogesh R Puranik<br/>Mall Whitefield,<br/>Flat No C1206 Inor Carmel Hieghts Next To Nexus Foram,<br/>Bangalore - 560066<br/>GSTIN/UIN:<br/>State Name: Karnataka Code: 29';
        
        System.assertEquals(expectedBillTo, salesOrder.billTo);
        System.assertEquals(expectedShipTo, salesOrder.shipTo);
    }
}