@isTest
private class TestAccountExpenseTrigger {


	/* Test the summarization of amount to an account when a account expense has been added, updated or deleted.
	   *Modified by Liliane 16/6/2015
       *Added  sum(lboc_Perceived_Amount__c) to the Query to update the new Field on Account :lboc_Total_Customer_Expenses__c
    */	
	@isTest static void TestAddEditDeleteExpense() {

    	List<Account> acctList = new List<Account>(); 
    	Account acc1 = new Account();
    	acc1.Name = 'BeerStore Mississauga';
    	acc1.lboc_Labatt_Outlet_Id__c = '23456';
    	acc1.buzz_retail__Account_ID__c = '23456';
    	acctList.add(acc1);
    	
    	insert acctList;

    	lboc_Sales_Territory__c territory = new lboc_Sales_Territory__c();
    	territory.name = 'Test Territory';

    	insert territory;

    	lboc_Expense__c expense = new lboc_Expense__c();
    	expense.lboc_Territory__c = territory.id;

    	insert expense;

    	lboc_account_expense__c accountExpense = new lboc_account_expense__c();
    	accountExpense.lboc_account__c = acc1.id;
    	accountExpense.lboc_Expense__c = expense.id;
		accountExpense.lboc_Amount__c = 12;
		accountExpense.lboc_Perceived_Amount__c =12;

		insert accountExpense;

		acc1 = [select id, lboc_total_expenses__c,lboc_Total_Customer_Expenses__c from account where id=:acc1.id];

		system.assertEquals(acc1.lboc_total_expenses__c, 12);
		system.assertEquals(acc1.lboc_Total_Customer_Expenses__c, 12);

    	accountExpense = new lboc_account_expense__c();
    	accountExpense.lboc_account__c = acc1.id;
    	accountExpense.lboc_Expense__c = expense.id;
		accountExpense.lboc_Amount__c = 12;
		accountExpense.lboc_Perceived_Amount__c =12;

		insert accountExpense;

		acc1 = [select id, lboc_total_expenses__c,lboc_Total_Customer_Expenses__c from account where id=:acc1.id];

		system.assertEquals(acc1.lboc_total_expenses__c, 24);
		system.assertEquals(acc1.lboc_Total_Customer_Expenses__c, 24);

		accountExpense.lboc_Amount__c = 13;
		accountExpense.lboc_Perceived_Amount__c =13;

		update accountExpense;

		acc1 = [select id, lboc_total_expenses__c,lboc_Total_Customer_Expenses__c from account where id=:acc1.id];

		system.assertEquals(acc1.lboc_total_expenses__c, 25);
		system.assertEquals(acc1.lboc_Total_Customer_Expenses__c, 25);
		

		delete accountExpense;

		acc1 = [select id, lboc_total_expenses__c,lboc_Total_Customer_Expenses__c from account where id=:acc1.id];

		system.assertEquals(acc1.lboc_total_expenses__c, 12);
		system.assertEquals(acc1.lboc_Total_Customer_Expenses__c, 12);
	}
	
}