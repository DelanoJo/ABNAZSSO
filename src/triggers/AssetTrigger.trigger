/*
** Created by Liliane 22/06/2015 - Sprint 6
** To update the owner Field of  the Assets same as the Account Onwer
*/


trigger AssetTrigger on buzz_retail__Asset__c (before insert, before update) {

 if (trigger.isBefore){
     if(trigger.isInsert || trigger.isUpdate){
       List<buzz_retail__Asset__c> listOfAssetsToUpdate = new List<buzz_retail__Asset__c>();    
           
       for(buzz_retail__Asset__c a : Trigger.new){
            if (a.buzz_retail__Account__c == null) continue;
           
            if(a.OwnerId != a.lboc_Account_OwnerId__c)  
                a.OwnerId = a.lboc_Account_OwnerId__c;
        } 
     }
  
 }
}