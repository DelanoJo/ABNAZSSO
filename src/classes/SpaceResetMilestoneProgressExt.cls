/**=====================================================================
 * Appirio, Inc
 * Name: SpaceResetMilestoneProgressExt
 * Description: [T-433601]
 * Created Date: 16 September
 * Created By: Poonam Varyani (Appirio)
 * 
 * Date Modified                Modified By                  Description of the update
 =====================================================================*/
public with sharing class SpaceResetMilestoneProgressExt {
    public Space_Plan_Reset__c currentProgram          {get;set;}
    public List<Reset_Milestones__c> steps           {get;set;}

    public SpaceResetMilestoneProgressExt(Apexpages.StandardController con){
        steps = new List<Reset_Milestones__c>();
        
        String spacePlanId = Apexpages.currentPage().getParameters().get('id');
        
        if(spacePlanId == null || spacePlanId == '' )
            spacePlanId = con.getId();
            
        currentProgram  = [SELECT Id, Name, Status__c,
                           (SELECT Id, Name, Status__c, Deadline__c FROM Reset_Milestones__r ORDER BY Order__c ASC) 
                           FROM Space_Plan_Reset__c WHERE Id = :spacePlanId];
        
        if(currentProgram.Reset_Milestones__r != null && currentProgram.Reset_Milestones__r.size() > 0)
            steps = currentProgram.Reset_Milestones__r;
    }
}