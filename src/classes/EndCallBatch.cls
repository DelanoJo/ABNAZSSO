/**
 * This batch picks up calls that were started before 11:59 PM the previous day but not ended. 
 * All the calls that are picked up are ended. 
 * If some of the calls could not be ended (for reasons like a must do action item not complete) the call is flipped to a status of 'New'
 * Author: Raghav Medahal
 */
global without sharing class EndCallBatch implements Schedulable, Database.Batchable<SObject>, Database.Stateful {
    
    public final Integer BATCH_SIZE = 1; // VERY IMPORTANT to keep this size to 1. the scope for execute() should have only one Call object
    
    // no-args constructor
    public EndCallBatch() {}
    
    // batch start method
    global Database.Querylocator start(Database.BatchableContext ctx) {
        String selectSoql = 'SELECT '
                                + ' Id,'
                                + ' Name,'
                                + ' buzz_retail__EventId__c,'
                                + ' OwnerId,'
                                + ' buzz_retail__Account__c,'
                                + ' buzz_retail__Contact__c,'
                                + ' buzz_retail__CallStatus__c,'
                                + ' buzz_retail__Date__c,'
                                + ' buzz_retail__Duration__c,'
                                + ' buzz_retail__End__c,'
                                + ' buzz_retail__Initialize__c,'
                                + ' buzz_retail__DoComplete__c,'
                                + ' buzz_retail__MyLastCall__c,'
                                + ' buzz_retail__LastCall__c,'
                                + ' buzz_retail__CallObjectives__c,'
                                + ' buzz_retail__CallComments__c,'
                                + ' buzz_retail__NextCallObjectives__c,'
                                + ' buzz_retail__ObjectivesFromLastCall__c,'
                                + ' buzz_retail__LocationDetails__c,'
                                + ' buzz_retail__EventSubject__c,'
                                + ' buzz_retail__fCallSubject__c,'
                                + ' buzz_retail__LastInitialized__c,'
                                + ' buzz_retail__sysUpdateAccountProduct__c,'
                                + ' buzz_retail__fDuration__c,'
                                + ' buzz_retail__NextCallDate__c,'
                                + ' buzz_retail__FixedAppointment__c,'
                                + ' buzz_retail__Call_Type__c,'
                                + ' buzz_retail__Call_Value__c,'
                                + ' buzz_retail__Call_Color__c,'
                                + ' buzz_retail__Hide_on_Calendar__c,'
                                + ' buzz_retail__StartCall__c,'
                                + ' buzz_retail__EndCall__c'                                
                                + ' FROM buzz_retail__call__c'
                                + ' WHERE buzz_retail__StartCall__c = true'
                                + ' AND buzz_retail__EndCall__c = false'
                                + ' AND buzz_retail__DoComplete__c = false' // some calls in Labatt prod are in 'Completed' status but not ended and hence this condition
                                + ' AND buzz_retail__Date__c < TODAY' // retrieve calls that were started before 11:59 PM the previous day
                                //+ ' AND Owner.IsActive = true' // if calls are retrieved for inactive owner the processing fails with error 'operation performed with inactive user'
                                + ' AND buzz_retail__IsMobile__c = true' // if non mobile calls are processed they might fail with an error saying the event duration can't be more than 1440 minutes
                                + ' ORDER BY buzz_retail__Date__c ASC';
        system.debug('******selectSoql=' + selectSoql);
        
        return Database.getQueryLocator(selectSoql);
    }
    
    // batch execute. one call at a time. if there is a system exception during processing the call, the next call will be processed
    global void execute(Database.BatchableContext ctx, List<SObject> scope) {
        
        // scope has only one call object
        buzz_retail__Call__c call = (buzz_retail__Call__c)scope.get(0);
        try {
            // end call
            call.buzz_retail__EndCall__c = true;
            // set end date to 11:59 PM of the call start date. this also ensure the event duration is less than 1440 minutes
            call.buzz_retail__End__c = DateTime.newInstance(call.buzz_retail__Date__c.year(), call.buzz_retail__Date__c.month(), call.buzz_retail__Date__c.day(), 23, 59, 59);
            update call;
        
        } catch (Exception e) {
            // if an exception was thrown by trigger for reasons like a must do action item not complete, flip the call status to new
            call.buzz_retail__StartCall__c = false;
            call.buzz_retail__EndCall__c = false;
            update call;
        }

    }
    
    // batch execute invoked by the scheduler
    global void execute(SchedulableContext ctx) {
        Database.executeBatch(new EndCallBatch(), BATCH_SIZE);
    }
    
    // batch finish
    global void finish(Database.BatchableContext ctx) {
        system.debug('End Call Batch processing completed');
    }
    
}