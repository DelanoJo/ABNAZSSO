// 
// (c) 2012 Appirio, Inc.
//
// Handler class of AccountTrigger
//
// 15 Sep 2015     Parul Gupta       Original
//
public class AccountTriggerHandler {

  public static boolean firstRun = true;

	// Method executes On After Insert
  public static void afterInsert(List<Account> newList){
    createAndUpdateCOH(newList, null);
  }

	// Method executed on After Update
  public static void afterUpdate(List<Account> newList, Map<Id, Account> oldMap){
  	updateRetailAssets(newList, oldMap);
  	if(firstRun){
    	createAndUpdateCOH(newList, oldMap);
    }
  }

	// Method creates/updates Captaincy Survey History records
  private static void createAndUpdateCOH(List<Account> newList, Map<Id, Account> oldMap){
  	
  	// Get all Captaincy Survey fields from custom setting
    Map<String, Captaincy_Survey_Fields__c> captaincySurveyFields = Captaincy_Survey_Fields__c.getAll();
  	
  	if(captaincySurveyFields.size() > 0) { 
	  	// List of Captaincy Survey History to upsert
	  	List<Captaincy_Survey_History__c> lstCOHtoUpsert = new List<Captaincy_Survey_History__c>();
	  	
	  	//On Update Case
	  	if(oldMap != null){
	      //Map<Id, Account> accIds = new Map<Id, Account>();
	      for(Account acc : newList){
	      	for(Captaincy_Survey_Fields__c field : captaincySurveyFields.values()){
		      	if(isNewOrChanged(acc, field.Field_API_Name__c, oldMap)){
		          lstCOHtoUpsert.add(new Captaincy_Survey_History__c(Account__c = acc.Id,
			                      Date_Transferred__c = Datetime.now(),
			                      Field_Name__c = field.Name,
			                      New_Value__c = String.valueOf(acc.get(field.Field_API_Name__c)),
			                      Old_Value__c = String.valueOf(oldMap.get((Id)acc.get('id')).get(field.Field_API_Name__c)), 
			                      User__c = UserInfo.getUserId(),
			                      Current_User__c = UserInfo.getName()));
		
		      	}
	      	}
	      }
	  	}
	  if(!lstCOHtoUpsert.isEmpty()){
	  		upsert lstCOHtoUpsert;
	  }
  	}
  }
  
  // Method updates retial assets for owner Id
  private static void updateRetailAssets(List<Account> newList, Map<Id, Account> oldMap){
  		set<Id> setOfAccoutOwnerChanged = new set<Id>();

	    for(Account a : newList){
	      if (a.OwnerId != oldMap.get(a.Id).OwnerId)
	           setOfAccoutOwnerChanged.add(a.Id);
	    }
	
	    if(!setOfAccoutOwnerChanged.isEmpty()) {
	   	 List<buzz_retail__Asset__c> listOfAssetsToUpdate = new List<buzz_retail__Asset__c>();
			for(buzz_retail__Asset__c assets : [SELECT Id, buzz_retail__Account__r.OwnerId FROM buzz_retail__Asset__c 
																						WHERE buzz_retail__Account__c IN :setOfAccoutOwnerChanged]){
	  		    assets.OwnerId = assets.buzz_retail__Account__r.OwnerId;
	   		   listOfAssetsToUpdate.add(assets);
	    	}
	  
	    if(listOfAssetsToUpdate != null && listOfAssetsToUpdate.size() > 0) 
	      update listOfAssetsToUpdate;		
	   	}
  }
	
	// Method returns true if field value has updated, otherwise false
  private static Boolean isNewOrChanged(Sobject obj, String fldName, Map<Id, Sobject> oldMap) {
    if (obj != null && fldName != null && oldMap != null) {
      return ((obj.get(fldName) != oldMap.get((Id)obj.get('id')).get(fldName) ? true : false));
    }
    return (obj.get(fldName) != null);
  }

}