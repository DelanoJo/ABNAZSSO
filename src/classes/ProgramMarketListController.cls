public with sharing class ProgramMarketListController {
	//private Map<Id,MarketAccount> maMap;
	//private Map<Id,MarketAccount> wslrMap;

    public PaginationUtility dpCon {get;set;}
    public PaginationUtility wslrCon {get;set;}

    public Integer dpPage {get; set;}
    public Integer wslrPage {get; set;}

    public Integer newConPage {get; set;}
    public Integer curCon {get; set;}

    /* returns list of selected wholesalers */
    public List<MarketAccount> marketDPs{
        get{
            if(dpCon.totalRecords > 0){
                return getWrapperList(dpCon.getPage(dpPage));
            } else {
                return new List<MarketAccount>();
            }
        } set;
    }

    /* returns list of selected wholesalers */
    public List<MarketAccount> marketWSLRs{
        get{
            if(wslrCon.totalRecords > 0){
                return getWrapperList(wslrCon.getPage(wslrPage));
            } else {
                return new List<MarketAccount>();
            }
        } set;
    }

    public ProgramMarketListController(ApexPages.StandardController sc){
    	Map<String,MarketAccount> dpMap = new Map<String,MarketAccount>();
    	Map<String,MarketAccount> wslrMap = new Map<String,MarketAccount>();

    	for(Milestone1_Task__c t : [SELECT Id, Name, Retailer__r.Name, Retailer__r.Id, Wholesaler__r.Name
    								, Wholesaler__r.Id, Task_Stage__c, Blocked__c, Class__c
    								FROM Milestone1_Task__c
    								WHERE Project_Milestone__r.Project__c = :sc.getId()
    								AND (Class__c = 'Retailer Alignment' OR Class__c = 'Wholesaler Alignment')
                                    ORDER BY Wholesaler__r.Name, Retailer__r.Name]){
    		if(t.Class__c == 'Retailer Alignment' && t.Retailer__c != null){
    			MarketAccount ma = !dpMap.containsKey(t.Retailer__r.Id) ? new MarketAccount(t.Retailer__r) : dpMap.get(t.Retailer__r.Id);
    			ma.incrementTask(t);
    			dpMap.put(t.Retailer__r.Id, ma);
    		} else if(t.Class__c == 'Wholesaler Alignment' && t.Wholesaler__c != null){
    			MarketAccount ma = !wslrMap.containsKey(t.Wholesaler__r.Id) ? new MarketAccount(t.Wholesaler__r) : wslrMap.get(t.Wholesaler__r.Id);
    			ma.incrementTask(t);
    			wslrMap.put(t.Wholesaler__r.Id, ma);
    		}
    	}
        Integer dpMapSize = dpMap.size();
        if(dpMapSize == 0 || math.mod(dpMapSize,5) > 0){
            Integer remainder = dpMapSize>5 ? 5-math.mod(dpMapSize,5) : 5-dpMapSize;
            for(Integer i = 1;i<=remainder;i++){
                if(dpMap.size()==0){
                    dpMap.put(''+i,new MarketAccount(new Account(Name='No Decision Points selected')));
                } else {
                    dpMap.put(''+i,new MarketAccount(new Account(Name='--')));
                }
            }
        }
        Integer wslrMapSize = wslrMap.size();
        if(wslrMapSize == 0 || math.mod(wslrMapSize,5) > 0){
            Integer remainder = wslrMapSize>5 ? 5-math.mod(wslrMapSize,5) : 5-wslrMapSize;
            for(Integer i = 1;i<=remainder;i++){
                if(wslrMap.size()==0){
                    wslrMap.put(''+i,new MarketAccount(new Account(Name='No Wholesalers selected')));
                } else {
                    wslrMap.put(''+i,new MarketAccount(new Account(Name='--')));
                }
            }
        }

        dpCon = new PaginationUtility();
        dpCon.pageSize = 5;
        dpPage = 1;
        wslrCon = new PaginationUtility();
        wslrCon.pageSize = 5;
        wslrPage = 1;

        dpCon.setPagination(dpMap.values());
        wslrCon.setPagination(wslrMap.values());
    }

    private List<MarketAccount> getWrapperList(List<Object> currentList) {
        List<MarketAccount> accountList = new List<MarketAccount>();
        for(Object obj : currentList) {
            accountList.add((MarketAccount)obj);
        }
        return accountList;
    }
    
    public void setPage(){
        if(curCon == 1){
            dpPage = newConPage;
        } else if(curCon == 2){
            wslrPage = newConPage;
        }
    }

    //public class MarketAccount implements Comparable{
    public class MarketAccount{
    	public Account account{get;set;}
    	public Integer openTasks{get;set;}
    	public Integer blockedTasks{get;set;}
    	public Integer totalTasks{get;set;}

    	public marketAccount(Account a){
    		account = a;
    		openTasks = 0;
    		blockedTasks = 0;
    		totalTasks = 0;
    	}

    	public void incrementTask(Milestone1_Task__c t){
    		totalTasks += 1;
    		if(t.Task_Stage__c != 'Completed'){
    			openTasks += 1;
    		}
    		if(t.Blocked__c){
    			blockedTasks += 1;
    		}
    	}
    	/* Comparable interace */
      	//public Integer compareTo(Object compareTo) {
       // 	if((compareTo instanceof MarketAccount) == false) return 1;
       //   	MarketAccount compareToA = (MarketAccount)compareTo;
       //   	return this.account.Name.compareTo(compareToA.account.Name);       
      	//}
    }
}