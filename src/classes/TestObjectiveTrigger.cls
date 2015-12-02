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
private class TestObjectiveTrigger 
{

    static testMethod void positiveAddToCallTest() 
    {
    	List<lboc_Objective__c> objList = new List<lboc_Objective__c>();
    	
    	createTestData(objList);
    	Test.startTest();
    	
    	if(objList != null && objList.size() > 0)
    	{
    		for(lboc_Objective__c objRec : objList)
    		{
    			objRec.lboc_Status__c = 'Completed';
    			objRec.lboc_this_call__c = true;
    		}
    		update objList;
    	}
    	
    	Test.stopTest();
        
    }
    
    /* Create test data for testing the ActionItemAnswerRefresh Batch functionality.
     * Account, Calls, Objectives
     */
    public static void createTestData(List<lboc_Objective__c> objList)
    {
    	/* Create Accounts
    	 * 1. BeerStore Mississauga (23456)
    	 * 2. BeerStore Toronto (45678)
    	 */
    	List<Account> acctList = new List<Account>(); 
    	Account acc1 = new Account();
    	acc1.Name = 'BeerStore Mississauga';
    	acc1.lboc_Labatt_Outlet_Id__c = '23456';
    	acc1.buzz_retail__Account_ID__c = '23456';
    	acctList.add(acc1);
    	
    	insert acctList;
    	
    	
    	DateTime prevDateStartTime = System.now(); 
    	DateTime prevDateEndTime = System.now().addMinutes(30);
    	
    	List<buzz_retail__Call__c> callList = new List<buzz_retail__Call__c>();
    	buzz_retail__Call__c call1 = new buzz_retail__Call__c();
    	call1.Name = 'BeerStore Mississauga 1';
    	call1.buzz_retail__Account__c = acc1.Id;
    	call1.buzz_retail__Date__c = prevDateStartTime;
    	call1.buzz_retail__End__c = prevDateEndTime;
    	callList.add(call1);
    	
    	insert callList;
   
    	call1.buzz_retail__CallStatus__c = 'Completed';
    	
    	update call1;
    	
    	for(Integer i = 0; i< 300 ; i++)
    	{
    		lboc_Objective__c objRec = new lboc_Objective__c();
    		objRec.lboc_Description__c = 'Description ' + i;
    		objRec.lboc_Outlet__c = acc1.Id;
    		objList.add(objRec);
    	}
    	insert objList;
    }
}