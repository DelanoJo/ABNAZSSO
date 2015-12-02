/**
 * This class contains unit tests for validating the Item Price List Update trigger.
 *
 */
@isTest
private class TestItemPriceListUpdateTrigger 
{
    
        
    static testMethod void positiveUpdateItemPriceRecord() 
    {
        M_Order_sigcap_Header__c orderRec = new M_Order_sigcap_Header__c(); 
        M_Order_sigcap_Header__c orderRec1 = new M_Order_sigcap_Header__c(); 
        
        M_Item_Price__c testItemPrice = new M_Item_Price__c();
   
           // Populate the TestData
        createTestData(orderRec,orderRec1,testItemPrice);
        
        Test.StartTest();
        
        orderRec1.M_Status__c = 'Final';
        update orderRec1;
        
        orderRec.M_Status__c = 'Final';
        update orderRec;
        
        Test.StopTest();
        
        //M_Item_Price__c itemPriceRec = [Select Id,Name,lboc_Prev_Qty_Ordered_1__c,lboc_Prev_PTR_1__c from M_Item_Price__c where Id =: testItemPrice.Id];
        //system.debug('lboc_Prev_Qty_Ordered_1__c ::: ' + testItemPrice.Name);
        //System.AssertEquals(20,testItemPrice.lboc_Prev_Qty_Ordered_1__c);
        //System.AssertEquals(130.50,testItemPrice.lboc_Prev_PTR_1__c);
        
        
    }

    /* Create test data for testing the ItemPriceListUpdateTrigger functionality.
     * Account, Product, Product Format, Price List, Item Price, Order, Order Details
     */
    public static void createTestData(M_Order_sigcap_Header__c orderRec,M_Order_sigcap_Header__c orderRec1,M_Item_Price__c testItemPrice)
    {
        
        // Create a Central Warehouse record
        RecordType cenAcctRecType = [select Id from RecordType where Name = 'Distribution Center with Inventory' and SobjectType = 'Account'];
        Account testCentAcct = new Account();
        testCentAcct.Name = 'Central Warehouse Acct';
        testCentAcct.buzz_retail__Account_ID__c = '4567';
        testCentAcct.lboc_Labatt_Outlet_Id__c = '4567';
        testCentAcct.RecordTypeId = cenAcctRecType.Id;
        insert testCentAcct;
        
        
        // Create OPLI Record
        M_OPLI_Settings__c opliRec = new M_OPLI_Settings__c();
        opliRec.Name = 'Standard OPLI';
        opliRec.M_IsActive__c = TRUE;
        opliRec.M_Default_DSC_Order_Account__c = testCentAcct.Id;
        opliRec.M_Default_DSC_Return_Account__c = testCentAcct.Id;
        opliRec.M_Requested_Delivery_Days__c = 0;
        opliRec.Read_Only_Status_for_Orders_No_Invento__c = 'Final';
        opliRec.Read_Only_Status_for_Orders_w_Inventory__c = 'Final';
        opliRec.M_Read_Only_Status_for_Returns_No_Invent__c = 'Final';
        opliRec.M_Read_Only_Status_for_Returns_w_Invent__c = 'Final';
        opliRec.Final_Order_Status_for_Orders_No_Invent__c = 'Final';
        opliRec.Final_Order_Status_for_Orders_w_Invent__c = 'Final';
        opliRec.Final_Order_Status_for_Returns_No_Invent__c = 'Final';
        opliRec.M_Final_Order_Status_for_Returns_w_Inven__c = 'Final';
        opliRec.M_Use_Customer_Pricing__c = TRUE;
        opliRec.M_Only_ONE_Price_List_Valid__c = TRUE;
        opliRec.M_Def_Inv_Return_Loc__c = testCentAcct.Id;
        insert opliRec;
        
        
        
        
        // Create Account Record.
        RecordType acctRecType = [select Id from RecordType where Name = 'Outlet' and SobjectType = 'Account'];
        Account testAcct = new Account();
        testAcct.Name = 'Test Account';
        testAcct.buzz_retail__Account_ID__c = '12345';
        testAcct.lboc_Labatt_Outlet_Id__c = '12345';
        testAcct.RecordTypeId = acctRecType.Id;
        insert testAcct;
        
        // Create Product Record.
        RecordType prodRecType = [select Id from RecordType where Name = 'Item' and SobjectType = 'buzz_retail__Product__c'];
        buzz_retail__Product__c testProd = new buzz_retail__Product__c();
        testProd.Name = 'Test Product 1';
        testProd.buzz_retail__UPC_Code__c = '12345';
        testProd.lboc_Labatt_Product_External_Id__c = '12345';
        testProd.RecordTypeId = prodRecType.Id;
        testProd.buzz_retail__Allow_Ordering__c = TRUE;
        insert testProd;
        
        // Create Product Format Record.
        buzz_retail__ProductFormat__c testProdFormat = new buzz_retail__ProductFormat__c();
        testProdFormat.Name = 'EA';
        testProdFormat.buzz_retail__Product__c = testProd.Id;
        testProdFormat.lboc_SAP_Material_Name__c = 'Test Product 1';
        testProdFormat.lboc_Conversion_24_bottle_eqv__c = 0.5;
        testProdFormat.buzz_retail__Conversion_Eaches__c = 1;
        testProdFormat.M_Active__c = TRUE;
        insert testProdFormat;
        
        // Create Price List.
        M_Price_List__c testPriceList = new M_Price_List__c();
        testPriceList.Name = 'Test Price List 1';
        testPriceList.M_Account__c = testAcct.Id;
        testPriceList.M_IsActive__c = TRUE;
        testPriceList.M_Price_List_Type__c = 'Customer';
        insert testPriceList;
        
        // Create Price List Item.
        //M_Item_Price__c testItemPrice = new M_Item_Price__c();
        testItemPrice.M_Price_List__c = testPriceList.Id;
        testItemPrice.M_Product_Format__c = testProdFormat.Id;
        testItemPrice.M_Item__c = testProd.Id;
        testItemPrice.M_ERP_Item_Price_ID__c = '12345';
        testItemPrice.M_Selling_From__c = Date.today();
        testItemPrice.M_Selling_Until__c = Date.today() + 20;
        testItemPrice.M_Selling_Price__c = 120.50;
        testItemPrice.M_Active_for_Order__c = True;
        testItemPrice.M_Available_for_Central_Orders__c = TRUE;
        //testItemPrice.M_Active_for_Returns__c = TRUE;
        insert testItemPrice;
        
        // Create Order Record 1
        //M_Order_sigcap_Header__c orderRec1 = new M_Order_sigcap_Header__c();
        orderRec1.M_AccountName__c = testAcct.Id;
        orderRec1.M_Status__c = 'Draft';
        insert orderRec1;
        
       
        
        // Create Order detail Record
        M_Order_Detail__c orderDet1 = new M_Order_Detail__c();
        orderDet1.M_Order__c = orderRec1.Id;
        orderDet1.M_Product_Name__c = testProd.Id;
        orderDet1.M_Product_Format__c = testProdFormat.Id;
        orderDet1.M_Qty_Ordered__c = 40;
        orderDet1.M_Item_Price__c = 110.50;
        orderDet1.M_Item_Price_ID__c = testItemPrice.Id;
        insert orderDet1;
        
        
        
        
        // Create Order Record
        orderRec.M_AccountName__c = testAcct.Id;
        orderRec.M_Status__c = 'Draft';
        insert orderRec;
        
        // Create Order detail Record
        M_Order_Detail__c orderDet = new M_Order_Detail__c();
        orderDet.M_Order__c = orderRec.Id;
        orderDet.M_Product_Name__c = testProd.Id;
        orderDet.M_Product_Format__c = testProdFormat.Id;
        orderDet.M_Qty_Ordered__c = 20;
        orderDet.M_Item_Price__c = 130.50;
        orderDet.M_Item_Price_ID__c = testItemPrice.Id;
        insert orderDet;
        
        
    }
}