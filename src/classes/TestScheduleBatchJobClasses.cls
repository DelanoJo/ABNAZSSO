/**
 * This class contains unit tests for validating all the Batch Job Scheduler classes.
 */
@isTest
private class TestScheduleBatchJobClasses 
{

	public static final String CRON_EXP = '0 0 * * * ?';
	
	// Method to test "ActionItemAnswerRefreshBatchJob"
    static testMethod void testActionItemAnswerRefreshBatchJobScheduler() 
    {
        Test.startTest();
 
        // Schedule a job for ActionItemAnswerRefreshBatchJob
        
        String jobId = System.schedule('testActionItemAnswerRefreshBatchJobScheduler',CRON_EXP, new ActionItemAnswerBatch());
      	
      	// Get the information from the CronTrigger API object
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, 
          NextFireTime
          FROM CronTrigger WHERE id = :jobId];

       // Verify the expressions are the same
       System.assertEquals(CRON_EXP, 
          ct.CronExpression);	
  
        Test.stopTest();
        
    }
    
    // Method to test "GameplanCascadeBatchJob"
    static testMethod void testGameplanCascadeBatchJobScheduler() 
    {
        Test.startTest();
 
        // Schedule a job for testGameplanCascadeBatchJobScheduler
        
        String jobId = System.schedule('testGameplanCascadeBatchJobScheduler',CRON_EXP, new GameplanCascadeBatchJob());
      	
      	// Get the information from the CronTrigger API object
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, 
          NextFireTime
          FROM CronTrigger WHERE id = :jobId];

       // Verify the expressions are the same
       System.assertEquals(CRON_EXP, 
          ct.CronExpression);	
  
        Test.stopTest();
    }
    
    // Method to test "ObjectiveCascadeBatchJob"
    static testMethod void testObjectiveCascadeBatchJobScheduler() 
    {
        Test.startTest();
 
        // Schedule a job for testObjectiveCascadeBatchJobScheduler
        
        String jobId = System.schedule('testObjectiveCascadeBatchJobScheduler',CRON_EXP, new ObjectiveCascadeBatchJob());
      	
      	// Get the information from the CronTrigger API object
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, 
          NextFireTime
          FROM CronTrigger WHERE id = :jobId];

       // Verify the expressions are the same
       System.assertEquals(CRON_EXP, 
          ct.CronExpression);	
  
        Test.stopTest();
    }
    
    // Method to test "DisplayCascadeBatchJob"
    static testMethod void testDisplayCascadeBatchJobScheduler() 
    {
        Test.startTest();
 
        // Schedule a job for testDisplayCascadeBatchJobScheduler
        
        String jobId = System.schedule('testDisplayCascadeBatchJobScheduler',CRON_EXP, new DisplayCascadeBatchJob());
      	
      	// Get the information from the CronTrigger API object
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, 
          NextFireTime
          FROM CronTrigger WHERE id = :jobId];

       // Verify the expressions are the same
       System.assertEquals(CRON_EXP, 
          ct.CronExpression);	
  
        Test.stopTest();
    }
    
    // Method to test "AttachmentCascadeBatchJob"
    static testMethod void testAttachmentCascadeBatchJobScheduler() 
    {
        Test.startTest();
 
        // Schedule a job for testAttachmentCascadeBatchJobScheduler
        
        String jobId = System.schedule('testAttachmentCascadeBatchJobScheduler',CRON_EXP, new AttachmentCascadeBatchJob());
      	
      	// Get the information from the CronTrigger API object
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, 
          NextFireTime
          FROM CronTrigger WHERE id = :jobId];

       // Verify the expressions are the same
       System.assertEquals(CRON_EXP, 
          ct.CronExpression);	
  
        Test.stopTest();
    }
}