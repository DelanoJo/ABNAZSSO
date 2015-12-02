/**====================================================================
 * Appirio, Inc
 * Name: MandateProductTriggerHandler
 * Description: Handler class for MandateProductTrigger
 * Created Date: 9 September 2015
 * Created By: Nimisha Prashant (Appirio)
 * 
 * Date Modified                Modified By                  Description of the update
 * 
 =====================================================================*/
 public with sharing class MandateProductTriggerHandler {

  public static boolean firstRun = true;
   
  /*------------------------------------------------------------------------------------
    Method to handle all After Delete funtionalities
    Prameters : oldList
  -------------------------------------------------------------------------------------*/
  public static void onAfterDelete(List<Mandate_Product__c> oldList) {
    if(firstRun){
      firstRun = false;
      deleteCloneMandateProducts(oldList);
    }
  }
  public static void onAfterInsert(List<Mandate_Product__c> newList) {
    if(firstRun){
      insertCloneMandateProducts(newList);
      firstRun = false;
    }
  }
  public static void onBeforeDelete(Map<Id,Mandate_Product__c> oldMap) {
    if(firstRun){
      validateCloned(oldMap);
    }
  }
  
  /*------------------------------------------------------------------------------------
    Method to delete the cloned Mandate Products when orignal Mandate Product is Deleted
    Prameters : oldList
  -------------------------------------------------------------------------------------*/
  private static void deleteCloneMandateProducts(List<Mandate_Product__c> oldList) {
    Set<Id> mandateIds = new Set<Id>();
    Set<Id> productIds = new Set<Id>();
    Set<String> mandateProductPair = new Set<String>();
    String pair = '';

    for(Mandate_Product__c mp : oldList) {
      mandateIds.add(mp.Mandate__c);
      productIds.add(mp.Product__c);
      mandateProductPair.add(mp.Mandate__c+'~'+mp.Product__c);
    }
    
    Set<Id> clonedMandateIds = new Set<Id>();
    for(Mandate__c mandate : [SELECT Id, Cloned__c 
                              FROM Mandate__c 
                              WHERE Id IN :mandateIds
                              AND Cloned__c = true]) {
      clonedMandateIds.add(mandate.Id);
    }
    
    List<Mandate_Product__c> mandateProdsToDel = new List<Mandate_Product__c>();                                                  
    if(!clonedMandateIds.isEmpty()) {
      for(Mandate_Product__c mp : [SELECT Product__c, Mandate__r.Parent_Mandate__c
                                   FROM Mandate_Product__c
                                   WHERE Product__c IN :productIds
                                   AND Mandate__r.Parent_Mandate__c IN :clonedMandateIds]){
        pair = mp.Mandate__r.Parent_Mandate__c + '~' + mp.Product__c;
        if(mandateProductPair.contains(pair)) {
          mandateProdsToDel.add(mp);    
        }                                                 
      }
    }
    
    if(!mandateProdsToDel.isEmpty()){
      delete mandateProdsToDel;
    }
  }

  /*------------------------------------------------------------------------------------
    Method to insert the cloned Mandate Products when orignal Mandate Product is Inserted
    Prameters : newList
  -------------------------------------------------------------------------------------*/
  private static void insertCloneMandateProducts(List<Mandate_Product__c> newList) {
    List<Mandate_Product__c> mandateProdsToIns = new List<Mandate_Product__c>();  
    Map<Id,List<Mandate_Product__c>> mandateProductMap = new Map<Id,List<Mandate_Product__c>>();

    for(Mandate_Product__c mp : newList) {
      List<Mandate_Product__c> mpList = mandateProductMap.containsKey(mp.Mandate__c) ? mandateProductMap.get(mp.Mandate__c) : new List<Mandate_Product__c>();
      mpList.add(mp);
      mandateProductMap.put(mp.Mandate__c,mpList);
    }
    
    for(Mandate__c mandate : [SELECT Id, Parent_Mandate__c
                               FROM Mandate__c
                               WHERE Parent_Mandate__c IN :mandateProductMap.keySet()]){
      for(Mandate_Product__c mp : mandateProductMap.get(mandate.Parent_Mandate__c)){
        Mandate_Product__c newMp = new Mandate_Product__c(Mandate__c = mandate.Id
                                                        , Product__c = mp.Product__c
                                                        , Status__c = mp.Status__c
                                                        , Cloned__c = true);
        mandateProdsToIns.add(newMp);
      }
    }
                                                 
    if(!mandateProdsToIns.isEmpty()){
      insert mandateProdsToIns;
    }
  }

  private static void validateCloned(Map<Id,Mandate_Product__c> oldMap) {
    Map<Id,Mandate_Product__c> mandateMap = new Map<Id,Mandate_Product__c>([SELECT Mandate__r.Id
                                             FROM Mandate_Product__c
                                             WHERE Id IN :oldMap.keySet()
                                             AND Mandate__r.Parent_Mandate__c != null]);
    for(Mandate_Product__c mp : oldMap.values()){
      if(mandateMap.containsKey(mp.Id)){
        mp.addError('Please manage products from the Parent Mandate.');
      }
    }
  }
}