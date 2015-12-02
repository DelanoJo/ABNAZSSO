/**====================================================================
* Appirio, Inc
* Name: MRWslrProdCommitTriggerHandler
* Description: Handler class for MRWslrProdCommitTrigger
* Created Date: 6 November 2015
* Created By: Matt Salpietro (Appirio)
* 
* Date Modified                Modified By                  Description of the update
* 
=====================================================================*/
public with sharing class MRWslrProdCommitTriggerHandler {

	public static boolean firstRun = true;

	/*------------------------------------------------------------------------------------
	Method to handle all Before Insert funtionalities
	Prameters : newList
	-------------------------------------------------------------------------------------*/
	public static void onBeforeInsert(List<MR_Wholesaler_Product_Commitment__c> newList) {
		populateDPsServiced(newList);
	}

	/*------------------------------------------------------------------------------------
	Method to add csv of DPs serviced to record
	Prameters : oldList
	-------------------------------------------------------------------------------------*/
	private static void populateDPsServiced(List<MR_Wholesaler_Product_Commitment__c> newList) {
		Map<Id,String> wslrDPMap = new Map<Id,String>();
		for(MR_Wholesaler_Product_Commitment__c wslrCommit : newList){
			wslrDPMap.put(wslrCommit.Wholesaler__c,'');
		}

		for(AggregateResult mrp : [SELECT Participant__r.Parent.Name DP, Participant__r.Wholesaler__c WSLR
								   FROM Market_Ready_Participant__c
								   WHERE Participant__r.Wholesaler__c IN :wslrDPMap.keySet()
								   GROUP BY Participant__r.Parent.Name, Participant__r.Wholesaler__c]){
			wslrDPMap.put((Id)mrp.get('WSLR'),wslrDPMap.get((Id)mrp.get('WSLR'))+','+(String)mrp.get('DP'));
		}

		for(MR_Wholesaler_Product_Commitment__c wslrCommit : newList){
			wslrCommit.DPs_Serviced__c = wslrDPMap.get(wslrCommit.Wholesaler__c);
		}
	}

}