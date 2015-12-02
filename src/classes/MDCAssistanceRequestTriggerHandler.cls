/**====================================================================
 * Appirio, Inc
 * Name: MDCAssistanceRequestTriggerHandler 
 * Description: Handler Class for MDCAssistanceRequestTrigger
 * Created Date: 16 September 2015
 * Created By: Nimisha Prashant (Appirio)
 * 
 * Date Modified                Modified By                  Description of the update
 * 16 Sept 2015                 Poonam                       T-433454
 * 30 Sept 2015                 Nimisha Prashant             T-436955 (Added method syncDataOnApproval to push data to Space Plan Reset)
 * 01 Oct  2015                 Nimisha Prashant             T-437592 (Added method cancelPreviousRequests to cancel the previously approved Requests)
 * 04 Oct  2015                 Nimisha Prashant             T-437592 (Updated method updateStatus to update Status of the Latest Request in MDC_Request_Status__c)
 =====================================================================*/
 public class MDCAssistanceRequestTriggerHandler {
    public static void onAfterInsert(List<MDC_Assistance_Request__c > newList){
        updateStatus(null, newList);
        cancelPreviousRequests(newList);
    } 
 
    public static void afterUpdate(Map<Id, MDC_Assistance_Request__c > oldMap, List<MDC_Assistance_Request__c > newList){
        syncDataOnApproval(oldMap, newList);
        updateStatus(oldMap, newList);
        //cancelPreviousRequests(oldMap, newList);
    }
    
    private static void updateStatus(Map<Id, MDC_Assistance_Request__c > oldMap, List<MDC_Assistance_Request__c > newList) {
        List<Space_Plan_Reset__c> updateSpacePlanReset = new List<Space_Plan_Reset__c>();
        Set<String> spacePlanResetIds = new Set<String>();
        for(MDC_Assistance_Request__c  mar : newList) {
            //check status field and space plan reset lookup val
            if(mar.Space_Plan_Reset__c != null && mar.Status__c != null
                && (oldMap != null && mar.Status__c != oldMap.get(mar.Id).Status__c)) {
                /*updateSpacePlanReset.add(new Space_Plan_Reset__c(Id = mar.Space_Plan_Reset__c, 
                                                   MDC_Request_Status__c = mar.Status__c));*/
                spacePlanResetIds.add(mar.Space_Plan_Reset__c);
               
            }
            
            if(oldMap == null) {
              updateSpacePlanReset.add(new Space_Plan_Reset__c(Id = mar.Space_Plan_Reset__c, 
                                                   MDC_Request_Status__c = mar.Status__c));
            }
        }
        
        for(Space_Plan_Reset__c spr : [SELECT Id, MDC_Request_Status__c, 
                                        (SELECT CreatedDate, Status__c 
                                         FROM MDC_Assistance_Requests__r 
                                         order by CreatedDate desc limit 1)
                                       FROM Space_Plan_Reset__c 
                                       WHERE Id IN :spacePlanResetIds]) {
           if( spr.MDC_Assistance_Requests__r.size() > 0 ) {
             updateSpacePlanReset.add(new Space_Plan_Reset__c(Id = spr.Id, MDC_Request_Status__c = spr.MDC_Assistance_Requests__r[0].Status__c));
           }
        }
         
        //update space plan reset list with status
        try{
            if(!updateSpacePlanReset.isEmpty()) {
                update updateSpacePlanReset;
            }
        }catch(exception ex) {
            system.debug(' Error :::: '+ex.getMessage());
        }
    }
    
    /*------------------------------------------------------------------------------------------------------------------------------
      Method to sync the Data from MDC_Assistance_Request__c to Space_Plan_Reset__c when Status changes to 'Approved'
      Parameters: Trigger.oldMap & Trigger.new
    --------------------------------------------------------------------------------------------------------------------------------*/
    private static void syncDataOnApproval(Map<Id, MDC_Assistance_Request__c > oldMap, List<MDC_Assistance_Request__c > newList) {
        List<Space_Plan_Reset__c> spacePlanResetToUpdate = new List<Space_Plan_Reset__c>();
        Space_Plan_Reset__c updatedSPR;
        for(MDC_Assistance_Request__c mdc : newList) {
            if( mdc.Status__c != oldMap.get(mdc.Id).Status__c && mdc.Status__c == 'Approved' && mdc.Space_Plan_Reset__c != null) {
              updatedSPR = new Space_Plan_Reset__c(Id = mdc.Space_Plan_Reset__c);
                system.debug('Updated SPR: '+updatedSPR.name);
              updatedSPR.Num_Planograms__c = mdc.Num_Planograms__c;
              updatedSPR.Num_Stores__c = mdc.Num_Stores__c;
              updatedSPR.Avg_Num_Doors__c = mdc.Avg_Num_Doors__c;
              updatedSPR.Merchandising_Start_Date__c = mdc.Merchandising_Start_Date__c;
              updatedSPR.Merchandising_End_Date__c = mdc.Merchandising_End_Date__c;
              updatedSPR.Staggered_Return_Cycle__c = mdc.Staggered_Return_Cycle__c;
              updatedSPR.Complexity_of_Guidelines__c = mdc.Complexity_of_Guidelines__c;
              updatedSPR.Reset_Type__c = mdc.Reset_Type__c;
              updatedSPR.MDC_Assistance_Override__c = true;
              spacePlanResetToUpdate.add(updatedSPR);
            }
        }
        
        try{
            if(!spacePlanResetToUpdate.isEmpty()) {
                update spacePlanResetToUpdate;
            }
        }catch(exception ex) {
            system.debug(' Error :::: '+ex.getMessage());
        }
    }
    private static void cancelPreviousRequests(List<MDC_Assistance_Request__c > newList) {
      Set<String> relatedSpacePlanResets = new Set<String>();
      Set<String> currentApprovedMDCIds = new Set<String>();
      List<MDC_Assistance_Request__c> mdcRequestsToUpdate = new List<MDC_Assistance_Request__c>();
      for(MDC_Assistance_Request__c mdc : newList) {
        if(/*mdc.Status__c != oldMap.get(mdc.Id).Status__c && (mdc.Status__c == 'Submitted' || mdc.Status__c == 'Approved')*/
        mdc.Status__c != null && mdc.Space_Plan_Reset__c != null) {
          relatedSpacePlanResets.add(mdc.Space_Plan_Reset__c);
          currentApprovedMDCIds.add(mdc.Id);
        }
      }
      for(MDC_Assistance_Request__c mdc : [SELECT Id, Status__c 
                                           FROM MDC_Assistance_Request__c 
                                           WHERE Space_Plan_Reset__c IN : relatedSpacePlanResets 
                                           AND (Status__c = 'Approved'
                                             OR Status__c = 'Submitted')]) {
        
        if(!currentApprovedMDCIds.contains(mdc.Id)) {
          mdcRequestsToUpdate.add(new MDC_Assistance_Request__c(Id = mdc.Id, Status__c = 'Cancelled'));
        }
      }
      try{
        if(!mdcRequestsToUpdate.isEmpty()) {
            update mdcRequestsToUpdate;
        }
        }catch(exception ex) {
            system.debug(' Error :::: '+ex.getMessage());
        }
    }
}