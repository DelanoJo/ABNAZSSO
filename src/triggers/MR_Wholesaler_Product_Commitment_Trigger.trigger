/**====================================================================
 * Appirio, Inc
 * Name: MR_Wholesaler_Product_Commitment_Trigger
 * Description: Trigger for MR_Wholesaler_Product_Commitment__c Object
 * Created Date: 6 November 2015
 * Created By: Matt Salpietro (Appirio)
 * 
 * Date Modified                Modified By                  Description of the update
 * 
 =====================================================================*/
trigger MR_Wholesaler_Product_Commitment_Trigger on MR_Wholesaler_Product_Commitment__c (before insert) {
  /*--------------------------------------------------------------------------
    Method to handle all Before Insert funtionalities
  --------------------------------------------------------------------------*/
  if(Trigger.isBefore && Trigger.isInsert) {
    MRWslrProdCommitTriggerHandler.onBeforeInsert(Trigger.new); 
  }
}