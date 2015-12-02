global class ObjectiveCascadeBatchJob implements Schedulable {

	global void execute(SchedulableContext ctx) {
    	ObjectiveCascadeBatch objectiveCascadeBatch = new ObjectiveCascadeBatch();    
        Id batchprocessid = Database.executeBatch(objectiveCascadeBatch);
	}
	
}