/**====================================================================
 * Appirio, Inc
 * Name: WSLRForecastCheck
 * Description: Annonymous Code to be executed on click of WSLR Forecast Check Button
 * Created Date: 26 August 2015
 * Created By: Nimisha Prashant (Appirio)
 * 
 * Date Modified                Modified By                  Description of the update
 * 
 =====================================================================*/
 global class WSLRForecastCheck {
  webservice static String checkWSLRForecast(String milestoneId){
    Set<Id> wholesalerIds = new Set<Id>();
    Set<Id> productIds = new Set<Id>();
    Map<String, List<Milestone1_Task__c>> wholsalerProductMap = new Map<String, List<Milestone1_Task__c>>();
    for(Milestone1_Task__c task : [SELECT Id, Clone_by_WSLR_PDCN__c, Wholesaler__c, Product__c
                                   FROM Milestone1_Task__c 
                                   WHERE Project_Milestone__c = :milestoneId]) {
      if(task.Clone_by_WSLR_PDCN__c && task.Wholesaler__c != null && task.Product__c != null) {
        wholesalerIds.add(task.Wholesaler__c);
        productIds.add(task.Product__c);
        String matchKey = String.valueOf(task.Wholesaler__c).substring(0,15) +'~'+String.valueOf(task.Product__c).substring(0,15);
        if(!wholsalerProductMap.containsKey(matchKey)) {
          wholsalerProductMap.put(matchKey, new List<Milestone1_Task__c>());
        }
        wholsalerProductMap.get(matchKey).add(task);
      }
    }
    if(wholsalerProductMap.size() > 0){
      List<Milestone1_Task__c> tasksToUpdate = new List<Milestone1_Task__c>();
      for(Forecast__c forcast : [SELECT Id, Wholesaler__c, Product__c
                                 FROM Forecast__c 
                                 WHERE Wholesaler__c IN :wholesalerIds 
                                 AND Product__c IN :productIds]) {
        String matckKey = String.valueOf(forcast.Wholesaler__c).substring(0,15) +'~'+String.valueOf(forcast.Product__c).substring(0,15);
        if(wholsalerProductMap.containsKey(matckKey)){
          for(Milestone1_Task__c task : wholsalerProductMap.get(matckKey)) {
            tasksToUpdate.add(new Milestone1_Task__c(Id = task.Id, WSLR_Inventory_Aligned__c = true));
          }
        }
      }
      if(!tasksToUpdate.isEmpty()) {
        try{
          update tasksToUpdate;
          return 'SUCCESS';
        }
        catch(Exception ex) {
          return 'ERROR: ' + ex.getMessage();
        }
      }
    }
    return 'SUCCESS';
  }
  webservice static String checkWSLRInventory(String taskId, String wholesalerId, String productId){
    List<Forecast__c> matchingForecastList = new List<Forecast__c>([SELECT Id, Wholesaler__c, Product__c
                                                                    FROM Forecast__c 
                                                                    WHERE Wholesaler__c = :wholesalerId
                                                                    AND Product__c = :productId]);
    if(!matchingForecastList.isEmpty()) {
      Milestone1_Task__c tasksToUpdate = new Milestone1_Task__c(Id = taskId, WSLR_Inventory_Aligned__c = true, Task_Stage__c = 'Complete');
      try{
          update tasksToUpdate;
          return taskId;
        }
        catch(Exception ex) {
          return 'ERROR: ' + ex.getMessage();
        }
    }
    return taskId;
  }
}