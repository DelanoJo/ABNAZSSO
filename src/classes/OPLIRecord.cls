public with sharing class OPLIRecord {

    public static M_OPLI_Settings__c getActiveOPLISetting()
    { 
        List<M_OPLI_Settings__c> oplis = [SELECT SystemModstamp, OwnerId, Name, CreatedDate, CreatedById, 
                                                M_Use_Product_Pricing__c,Inventory_Transaction_Completion_Status__c, 
                                                M_Use_Outlet_Pricing__c, M_Use_Distributor_Pricing__c, M_Use_Customer_Pricing__c, 
                                                M_Price_List__c, M_Automated_Order_Details__c,
                                                M_Price_List_OnlyOnePerCustomer__c, M_Order_Return_Products__c, 
                                                M_Only_ONE_Price_List_Valid__c, 
                                                M_Item_Price_unique_product__c, M_Default_DSC_Return_Account__c, 
                                                M_Default_DSC_Order_Account__c, M_DefaultSSROrderSet__c, M_Def_Inv_Return_Loc__c, 
                                                M_Def_Inv_Disc_Loc__c, LastModifiedDate, LastModifiedById, Id,M_Requested_Delivery_Days__c, 
                                                Final_Order_Status_for_Orders_No_Invent__c,
                                               	Final_Order_Status_for_Orders_w_Invent__c,Final_Order_Status_for_Returns_No_Invent__c,
                                               	M_Final_Order_Status_for_Returns_w_Inven__c,M_OPLI_Settings__c.Cancelled_Order_Status__c,
                                               	Read_Only_Status_for_Orders_No_Invento__c, Read_Only_Status_for_Orders_w_Inventory__c,
                                               	M_Read_Only_Status_for_Returns_w_Invent__c, M_Read_Only_Status_for_Returns_No_Invent__c,
                                               	M_Automate_Inventory_Break_Case__c
                                            FROM M_OPLI_Settings__c
                                            WHERE M_IsActive__c = true];

        system.assertNotEquals(null,oplis);
        system.assertEquals(1,oplis.size(),'There is more than 1  or NO OPLI Setting Record!');
        return oplis[0];

    }
}