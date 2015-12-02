public with sharing class MRProgramLateTasksCtrl {
	
	Milestone1_Project__c program;
	
	public MRProgramLateTasksCtrl(ApexPages.StandardController controller){
		program = (Milestone1_Project__c)controller.getRecord();
	}
}