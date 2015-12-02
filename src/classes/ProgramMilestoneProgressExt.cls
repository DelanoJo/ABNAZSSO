public with sharing class ProgramMilestoneProgressExt {

	public Milestone1_Project__c currentProgram			 {get;set;}
	public List<Milestone1_Milestone__c> steps 		 	 {get;set;}

	public ProgramMilestoneProgressExt(Apexpages.StandardController con){
		steps = new List<Milestone1_Milestone__c>();
		
		String programId = Apexpages.currentPage().getParameters().get('id');
		
		if(programId == null || programId == '' )
			programId = con.getId();
			
		currentProgram  = [SELECT Id, Name, Status__c,
						   (SELECT Id, Name, Status__c, Deadline__c, Image__c, Order__c FROM Project_Milestones__r ORDER BY Order__c ASC) 
						   FROM Milestone1_Project__c WHERE Id = :programId];
		
		if(currentProgram.Project_Milestones__r != null && currentProgram.Project_Milestones__r.size() > 0)
			steps = currentProgram.Project_Milestones__r;
	}
}