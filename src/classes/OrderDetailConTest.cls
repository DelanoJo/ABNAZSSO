/**
 
 */
@isTest
private class OrderDetailConTest {

    static testMethod void testOrderDetail() {
        PageReference pageRef = Page.Order_Details;
        Test.setCurrentPage(pageRef);
        
        Apexpages.Standardcontroller sc = new Apexpages.Standardcontroller(new M_Order_sigcap_Header__c());
        OrderDetailCon contrl = new OrderDetailCon(sc);
        //contrl.nameSpace='Test namespace';
        //contrl.isOrder = true;
        //contrl.IsReturn = true;
        
        
        //List<M_Order_Detail__c> listOrder = contrl.MOrder(testOrder.id);
        
    }
}