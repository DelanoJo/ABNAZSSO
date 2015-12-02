/** 
 *  Trigger is used to sum amounts to the account when an account expense is created or updated.
 *  Modified by Liliane 16/6/2015  - sprint 6
 *  Added  sum(lboc_Perceived_Amount__c) to the Query to update the new Field on Account :lboc_Total_Customer_Expenses__c
 */

trigger AccountExpenseTrigger on lboc_Account_Expense__c (after insert, after update, after delete) {

    set<id> SetAccountId = new set<id>();
    map<id, account> mapAccount;
    AggregateResult[] groupedResults;

    if (trigger.isAfter) {
        if(trigger.isInsert || trigger.isUpdate) {
            for (lboc_Account_Expense__c oAccountExpense: trigger.new) {
                if (oAccountExpense.lboc_Account__c !=null) {
                    SetAccountId.add(oAccountExpense.lboc_Account__c);
                }
            }
        } else {
            for (lboc_Account_Expense__c oAccountExpense: trigger.old) {
                if (oAccountExpense.lboc_Account__c !=null) {
                    SetAccountId.add(oAccountExpense.lboc_Account__c);
                }
            }           
        }

        if (SetAccountId.size() > 0) {
            groupedResults = [SELECT lboc_Account__c, SUM(lboc_Amount__c),sum(lboc_Perceived_Amount__c) FROM lboc_Account_Expense__c WHERE lboc_Account__c IN: SetAccountId GROUP BY lboc_Account__c];
            mapAccount = new map<id, account>([SELECT id FROM account WHERE id IN: SetAccountId]);

            for (AggregateResult ar : groupedResults)  {
                mapAccount.get((id)ar.get('lboc_Account__c')).lboc_Total_Expenses__c = (decimal)ar.get('expr0');
                mapAccount.get((id)ar.get('lboc_Account__c')).lboc_Total_Customer_Expenses__c = (decimal)ar.get('expr1');
            }

            try {
                update mapAccount.values();
            } catch (exception e) {
                System.debug('The following exception has occurred while updating accounts: ' + e.getMessage());
            }

            // Update the Date Field on the Account Detail everytime a corresponding Account Expense is Updated.
            List<lboc_Account_Detail__c> accntDetails = [SELECT id, lboc_Account_Expense_Last_Update_Date__c FROM lboc_Account_Detail__c WHERE lboc_Account__c IN: SetAccountId];

            for (lboc_Account_Detail__c accntDetail : accntDetails)  {
                accntDetail.lboc_Account_Expense_Last_Update_Date__c = DateTime.Now();
            }

            try {
                update accntDetails;
            } catch (exception e) {
                System.debug('The following exception has occurred while updating Account Details: ' + e.getMessage());
            }
        }
    
    }
    



    /*set<id> SetAccountId = new set<id>();
    set<id> SetTerritoryId = new set<id>();

    map<id, lboc_Account_Expense__c> mapAccIdToAccountExpense = new map<id, lboc_Account_Expense__c>();
    map<id, account> mapAccount;
    map<id, lboc_Sales_Territory__c> mapTerritories;

    for (lboc_Account_Expense__c oAccountExpense: Trigger.new) {
        SetAccountID.add(oAccountExpense.lboc_Account__c);
        mapAccIdToAccountExpense.put(oAccountExpense.lboc_Account__c, oAccountExpense);
    }

    mapAccount = new map<id, account>([select id, lboc_Sales_Territory2__c from account where id in: SetAccountID]);

    for(account oAccount: mapAccount.values()){
        SetTerritoryId.add(oAccount.lboc_Sales_Territory2__c);
    }

    mapTerritories = new map<id, lboc_Sales_Territory__c>([select (select id from Expenses__r) from lboc_Sales_Territory__c where id in: SetTerritoryId]);

    for(account oAccount: mapAccount.values()){
        if(mapTerritories.containskey(oAccount.lboc_Sales_Territory2__c)){
            mapAccIdToAccountExpense.get(oAccount.id).lboc_Expense__c = mapTerritories.get(oAccount.lboc_Sales_Territory2__c).Expenses__r[0].id;
        }
    }   */



    //list<account> lstTerr = [Select id, (SELECT id from Expenses__r) from lboc_Sales_Territory__c where id IN (select lboc_Sales_Territory2__c from account where id IN: SetAccountID)];

    // big assumption happening here, there should be ONLY one expense per territory.

    
}