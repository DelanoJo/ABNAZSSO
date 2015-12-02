/**====================================================================
 * Appirio, Inc
 * Name: MandateTriggerHandler
 * Description: Handler class for MandateTrigger
 * Created Date: 24 September 2015
 * Created By: Nimisha Prashant (Appirio)
 * 
 * Date Modified                Modified By                  Description of the update
 * 
 =====================================================================*/
public with sharing class MandateTriggerHandler {
  private static final String PERIOD_POPULATED_MSG = 'You can\'t update Period while inserting Mandate';
  /*------------------------------------------------------------------------------------
    Method to handle all Before Insert funtionalities
    Prameters : Trigger.new
  -------------------------------------------------------------------------------------*/
  public static void onBeforeInsert(List<Mandate__c> newList) {
    updateMandatePeriod(null, newList);
  }
  
  /*------------------------------------------------------------------------------------
    Method to handle all Before Update funtionalities
    Prameters : Trigger.oldMap, Trigger.new
  -------------------------------------------------------------------------------------*/
  public static void onBeforeUpdate(Map<Id, Mandate__c> oldMap, List<Mandate__c> newList) {
    updateMandatePeriod(oldMap, newList);
  }
  
  /*------------------------------------------------------------------------------------
    Private Method to update the Period field from Account Mandate Recurrence
    Prameters : Trigger.oldMap, Trigger.new
  -------------------------------------------------------------------------------------*/
  private static void updateMandatePeriod(Map<Id, Mandate__c> oldMap, List<Mandate__c> newList) {
    List<Mandate__c> mandatesToUpdate = new List<Mandate__c>();
    Set<Id> relatedAccountIds = new Set<Id>();
    for(Mandate__c mandate : newList) {
      if(oldMap == null && mandate.Period__c != null && mandate.Parent_Mandate__c == null) {
        Trigger.new[0].addError(PERIOD_POPULATED_MSG);
      }
      if(mandate.Parent_Mandate__c == null) {
        mandatesToUpdate.add(mandate);
        relatedAccountIds.add(mandate.Account__c);
      }
    }
    Map<Id, Account> relatedAccounts = new Map<Id, Account>([SELECT Id, Mandate__c 
                                                             FROM Account 
                                                             WHERE Id = : relatedAccountIds]);
    for(Mandate__c mandate : mandatesToUpdate) {

      mandate.Period__c = relatedAccounts.get(mandate.Account__c).Mandate__c;
    }
  }
}