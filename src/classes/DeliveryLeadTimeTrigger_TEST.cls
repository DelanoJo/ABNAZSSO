/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
private class DeliveryLeadTimeTrigger_TEST {

	private static Account distAcct;
	private static M_Price_List__c customerPriceList;
	private static M_OPLI_Settings__c OpliSetting;
	
    static testMethod void myUnitTest() {
        
        //Create distributor account
		distAcct = TestUtils.createTestAccount('Test Distributor', 'Distribution Center with Inventory', null);
		insert distAcct;
		
        //OPLI setting object with distributor account
		OpliSetting = new M_OPLI_Settings__c(Name='Test OPLI', 
											M_IsActive__c=true,
											M_Only_ONE_Price_List_Valid__c=true,
											M_Use_Outlet_Pricing__c=false,
											M_Use_Customer_Pricing__c=true,
											M_Use_Distributor_Pricing__c=false, 
											M_Price_List__c=null,
											M_Def_Inv_Return_Loc__c=distAcct.Id,
											M_Automate_Inventory_Break_Case__c=true);
											
		insert OpliSetting;
											
		Delivery_Lead_Time__c dlt = new Delivery_Lead_Time__c(State__c='FL', Delivery_Lead_Days__c=8, OPLI_Settings__c=OpliSetting.Id);
		
		// Insert book
		insert dlt;
		
    }
}