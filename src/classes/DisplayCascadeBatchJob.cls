global class DisplayCascadeBatchJob implements Schedulable{
	
	global void execute(SchedulableContext ctx) {	
    	DisplayCascadeBatch displayCascadeBatch = new DisplayCascadeBatch();    
        Id batchprocessid = Database.executeBatch(displayCascadeBatch);
	}

}