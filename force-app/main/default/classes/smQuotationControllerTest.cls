@isTest
public class smQuotationControllerTest {

    @isTest
    static void testsmQuotationControllerInitialization() {
        smQuotationController controller = new smQuotationController();
        System.assertEquals(2, controller.productDatas.size());
        smQuotationController.ProductData firstProduct = controller.productDatas[0];
        System.assertEquals('1', firstProduct.slno);
        System.assertEquals('AMERICAN COMFORT', firstProduct.product);
        System.assertEquals('CHARLOTTE MOTION', firstProduct.model);
        System.assertEquals('1 STR', firstProduct.sitter);
        System.assertEquals(' 1,63200*8= 13,05,600', firstProduct.mrp);
        System.assertEquals('1,18,200*8= 9,45,600', firstProduct.offerprice);
        System.assertEquals('94,500*8= 7,56,000', firstProduct.finalprice);
        smQuotationController.ProductData secondProduct = controller.productDatas[1];
        System.assertEquals('2', secondProduct.slno);
        System.assertEquals('EUROPEAN ELEGANCE', secondProduct.product);
        System.assertEquals('CHARLOTTE MOTION', secondProduct.model);
        System.assertEquals('2 STR', secondProduct.sitter);
        System.assertEquals('1,63200*8= 13,05,600', secondProduct.mrp);
        System.assertEquals('1,18,200*8= 9,45,600', secondProduct.offerprice);
        System.assertEquals('94,500*8= 7,56,000', secondProduct.finalprice);
        System.assertEquals(1, controller.addresslist.size());
        smQuotationController.Address firstAddress = controller.addresslist[0];
        System.assertEquals('Customer details here', firstAddress.customerDetails);
        System.assertEquals('John Doe', firstAddress.name);
        System.assertEquals('123 Main St, Anytown, USA', firstAddress.Address);
        System.assertEquals('123-456-7890', firstAddress.phone);

      
    }
}