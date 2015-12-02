/**====================================================================
 * Appirio, Inc
 * Name: BatchCloneMandateProducts
 * Description: Batch class to clone Mandate Products
 * Created Date: 27 October 2015
 * Created By: Matt Salpietro (Appirio)
 * 
 * Date Modified                Modified By                  Description of the update
 * 
 =====================================================================*/
global class BatchCloneMandateProducts implements Database.Batchable<sObject> {

	Mandate__c parentMandate;

	global BatchCloneMandateProducts(Id parentMandateId){
		parentMandate = [SELECT Id, Name, (SELECT Id, Division, CurrencyIsoCode, Mandate__c, Product__c, Status__c, Brand_Name__c 
	                     				   FROM Mandate_Products__r)
						 FROM Mandate__c WHERE Id = :parentMandateId];
	}

	global Database.QueryLocator start(Database.BatchableContext BC) {
		return Database.getQueryLocator([SELECT Id FROM Mandate__c WHERE Parent_Mandate__c = :parentMandate.Id]);
	}

	global void execute(Database.BatchableContext BC, List<sObject> scope) {
		List<Mandate_Product__c> newProducts = new List<Mandate_Product__c>();
		for(sObject s : scope) {
			Mandate__c mandate = (Mandate__c)s;

			for(Mandate_Product__c prod : parentMandate.Mandate_Products__r){
				Mandate_Product__c newProd = prod.clone(false, true);
				newProd.Mandate__c = mandate.Id;
				newProd.Cloned__c = true;
				newProducts.add(newProd);
			}
		}
		insert newProducts;
	}

	global void finish(Database.BatchableContext BC) {
		AsyncApexJob a = [SELECT Id, Status, NumberOfErrors, JobItemsProcessed, TotalJobItems, CreatedBy.Email
						  FROM AsyncApexJob
						  WHERE Id = :BC.getJobId()];
		              
		// Send an email to the Apex job's submitter 
		// notifying of job completion. 
		Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
		String[] toAddresses = new String[] {a.CreatedBy.Email};
		mail.setToAddresses(toAddresses);
		mail.setSubject('Mandate Products created for Mandate: '+parentMandate.Name);
		mail.setPlainTextBody
		('Mandate Products have been succesfully added for cloned Mandates related to '+parentMandate.Name);
		if(!Test.isRunningTest()){
			Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
		}
	}

}