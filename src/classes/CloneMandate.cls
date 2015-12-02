/**====================================================================
* Appirio, Inc
* Name: CloneMandate
* Description: Annonymous Code to be executed on click of Clone to Child Accounts button
* Created Date: 27 August 2015
* Created By: Nimisha Prashant (Appirio)
* 
* Date Modified                Modified By                  Description of the update
* 
=====================================================================*/
global class CloneMandate {
  private static final String ACCOUNT_TYPE_CUSTOMER_PARENT = 'Chain';
  private static final String ACCOUNT_TYPE_CUSTOMER_CHILD = 'Banner';
  private static final String ACCOUNT_TYPE_CUSTOMER_DP = 'Decision Point';
  private static final String ACCOUNT_TYPE_CUSTOMER_POC = 'POC';

  webservice static String cloneMandateToChildren(String mandateId, String accountId, String typeOfAccount){
    Set<Id> accountIds = new Set<Id>();
    for(Account acc : DataBase.query(getQueryString(accountId, typeOfAccount))) {
      accountIds.add(acc.Id);
    }

    List<Mandate__c> mandateAndProductsList = new List<Mandate__c>([SELECT Period__c, Name, Id, Division, Account__c  
                                                                    FROM Mandate__c
                                                                    WHERE Id = :mandateId]);

    Mandate__c mandateToClone = mandateAndProductsList[0];
    //if((accountIds.size()*mandateToClone.Mandate_Products__r.size())>10000){
    //  return 'ERROR: Greater than 10,000 Mandates and Products to be cloned';
    //}
    List<Mandate__c> mandatesToInsert = new List<Mandate__c>();

    for(Id accId : accountIds) {
      Mandate__c newMandates = mandateToClone.clone(false, true);
      newMandates.Account__c = accId;
      newMandates.Parent_Mandate__c = mandateId;
      mandatesToInsert.add(newMandates);
    }

    if(!mandatesToInsert.isEmpty()) {
      try {
        insert mandatesToInsert;
        Mandate__c orignalMandate = new Mandate__c(Id = mandateId, Cloned__c = true);
        update orignalMandate;
      }
      catch(Exception ex) {
        system.debug('>>>ERROR>>>'+ex.getMessage());
        return ' ERROR: ' + ex.getMessage();
      }
    }

    //List<Mandate_Product__c> mandateProductsToInsert = new List<Mandate_Product__c>();
    //if(!mandateAndProductsList.isEmpty() && !mandateAndProductsList[0].Mandate_Products__r.isEmpty()) {
    //  for(Integer j = 0 ; j < mandatesToInsert.size() ; j++) {
    //    for(Integer i = 0 ; i < mandateAndProductsList[0].Mandate_Products__r.size() ; i++) {
    //      Mandate_Product__c clonedMP = mandateAndProductsList[0].Mandate_Products__r[i].clone(false, true);
    //      clonedMP.Mandate__c = mandatesToInsert[j].Id;
    //      clonedMP.Cloned__c = true;
    //      mandateProductsToInsert.add(clonedMP);
    //    }
    //  }
    //}

    //if(!mandateProductsToInsert.isEmpty()) {
    //  try {
    //    insert mandateProductsToInsert;
    //  }
    //  catch(Exception ex) {
    //    system.debug('>>>ERROR>>>'+ex.getMessage());
    //    return ' ERROR: ' + ex.getMessage();
    //  }
    //}

    BatchCloneMandateProducts b = new BatchCloneMandateProducts(mandateId);
    database.executebatch(b);

    return 'SUCCESS';
  }

  private static String getQueryString(String accountId, String accountType) {
    String queryString = '';
    queryString = 'SELECT Id FROM Account WHERE (';

    if(accountType.equalsIgnoreCase(ACCOUNT_TYPE_CUSTOMER_PARENT)) {
      queryString += 'Parent.Parent.ParentId = :accountId';
    }
    if(accountType.equalsIgnoreCase(ACCOUNT_TYPE_CUSTOMER_CHILD)) {
      queryString += 'Parent.ParentId = :accountId';
    }
    if(accountType.equalsIgnoreCase(ACCOUNT_TYPE_CUSTOMER_DP)) {
      queryString += 'ParentId = :accountId';
    }

    queryString += ') AND (Type = :ACCOUNT_TYPE_CUSTOMER_POC)';

    return queryString;
  }

}