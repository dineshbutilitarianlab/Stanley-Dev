@isTest
public class PurchaseOrderWrapperTest {

    @isTest
    static void testPurchaseOrderWrapperInitialization() {
        PurchaseOrderWrapper purchaseOrder = new PurchaseOrderWrapper();
        System.assertEquals('ICVSLL<br/>Stanley Lifestyles Limited-CR<br/>Bangalore-Hosur Main Road, Bangalore South,<br/>Unit-V, No #16/2/16/3, Veerasandra Village,<br/>Bangalore - 560100<br/>Contact No.:<br/>GSTIN/UIN: 29AALCS3769P1ZB<br/>State Name : Karnataka Code : 29', purchaseOrder.supplier);
        System.assertEquals('Yogesh R Puranik<br/>Mall Whitefield,<br/>Flat No C1206 Inor Carmel Hieghts Next To Nexus Foram,<br/>Bangalore - 560066<br/>GSTIN/UIN:<br/>State Name: Karnataka Code: 29', purchaseOrder.shipTo);
        System.assertEquals('240201979', purchaseOrder.purchaseOrderNo);
        System.assertEquals('27/06/2024', purchaseOrder.orderDate);
        System.assertEquals('15-7-2024', purchaseOrder.deliveryDate);
        System.assertEquals(8, purchaseOrder.orderItems.size());

        Decimal expectedSubTotalQuantity = 8;
        Decimal expectedSubTotalValue = 1461216.00;

        Decimal expectedCgst = expectedSubTotalValue * 0.09;
        Decimal expectedSgst = expectedSubTotalValue * 0.09;
        Decimal expectedTotalAmount = expectedSubTotalValue + expectedCgst + expectedSgst + purchaseOrder.rounding;
      
        String expectedTotalAmountInWords = NumberToText.convert(purchaseOrder.totalAmount.intValue()) + ' only';
        System.assertEquals(expectedTotalAmountInWords, purchaseOrder.totalAmountInWords);

      }
}