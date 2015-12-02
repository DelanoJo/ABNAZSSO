public with sharing class InventoryRecord {
   
    public static void ProcessAllInventoriesToBreak(List <M_Inventory__c> ListInventoriesToBreak){
         //Item#703 - Setting Break Case checkbox to true if Each Inventory is negative 
        
        System.Debug('MMMMMM : InventoryRecord.ProcessAllInventoriesToBreak ListInventoriesToBreak.ize(): ' + ListInventoriesToBreak.size());
        
        M_OPLI_Settings__c opli=OPLIRecord.getActiveOPLISetting();
        
        //old code comparison boolean bug  
        //If (opli.M_Automate_Inventory_Break_Case__c = true)
        if(opli.M_Automate_Inventory_Break_Case__c) //modified by Minh-Dien@15-Aug-2013
        {  
            System.Debug('*****************************LN  In ProcessAllInventoriesToBreak'); 
            // Build Map of Negative Inv
            set<Id> possibleInventory = new set<Id>();
  
 
            for (M_Inventory__c i:ListInventoriesToBreak) 
                if (i.M_FormatCode__c =='Each')
                {
                    possibleInventory.add(i.Id);
                    System.Debug('*****************************LN  Id of Inventory to Break :'+ i.Name + ', ' + i.Id);  
                }
                
            //Calculate the RollupSummary and fill  NegEachInventory set of Id  
            AggregateResult[] groupResultSumQtty = [SELECT sum(M_Net_Qty__c),M_Inventory__r.Id From M_Transaction_Item__c 
                    where M_Inventory__c  in :possibleInventory  and M_CountInInventory__c = true 
                    group by M_Inventory__r.Id  
                    having sum(M_Net_Qty__c)<0];
                        
      
                  
                set<Id> NegEachInventory = new set<Id>();
                set<Id> PosCaseInventory = new set<Id>();
                set<Id> possibleDistributor = new set<Id>();
                set<Id> possibleProducts = new set<Id>();
                set<Id> possibleLocations= new set<Id>();
                Map<string,Id> MapNegativeInv = new Map<string,Id>(); 
                Map<Id,Decimal> MapNegInvEachIdQtty= new Map<Id,Decimal>(); 
                Map<Id,Decimal> MapPosCaseInvIdQtty= new Map<Id,Decimal>();
                
                Map<string,M_Inventory__c> MapNegEachInv= new Map<string,M_Inventory__c>();
                
                
                //Final Map
                Map<Id,Decimal> MapCaseInvQttyToBreak= new Map<Id,Decimal>();
            
                                
                for ( AggregateResult SumQtty:groupResultSumQtty )
                {        
                    System.Debug('*****************************LN  In Calculating  SumQtty/Qtty On hand ' + SumQtty.get('expr0')  );
                    Decimal  vsumQtty = Integer.valueOf(SumQtty.get('expr0'));
                   
                        Id InvId= (Id)(SumQtty.get('Id'));
                        NegEachInventory.add(InvId);
                        MapNegInvEachIdQtty.put(InvId,vsumQtty);
                        System.Debug('*****************************LN Negative Inventory true:' +SumQtty.get('Id') + '' + SumQtty.get('expr0'));
                   
                }
            
                if (!NegEachInventory.isEmpty())
                {               
                	//M_Merck_Product_Code__c,
                    for (M_Inventory__c i:[Select Id,Name,M_Inventory_Location__c,M_Distributor__c,M_Product__c,M_Product_Format__c,
                                            M_Product_Format__r.Name
                                            from M_Inventory__c where Id in :NegEachInventory  ]) 
                    {
                       
                        //MapNegativeInv.put(String.ValueOf(i.M_Distributor__c)+String.ValueOf(i.M_Inventory_Location__c)+String.ValueOf(i.M_Merck_Product_Code__c),i.id);
                        MapNegativeInv.put(String.ValueOf(i.M_Distributor__c)+String.ValueOf(i.M_Inventory_Location__c)+String.ValueOf(i.M_Product__c),i.id);
                        
                        //used to get the product format
                        MapNegEachInv.put(String.ValueOf(i.M_Distributor__c)+String.ValueOf(i.M_Inventory_Location__c)+String.ValueOf(i.M_Product__c),i);
                        
                        possibleDistributor.add(i.M_Distributor__c); 
                        possibleLocations.add(i.M_Inventory_Location__c); 
                       // possibleProducts.add(i.M_Merck_Product_Code__c);
                       possibleProducts.add(i.M_Product__c);
                          
                    }
                    
                    System.Debug('*****************************LN Calculating Rollup Sum stock_Qty_at_hand for corr cases that has postive Stock');
                    
                    //caculate RollupSum stock_Qty_at_hand for corr cases that has postive Stock
                    AggregateResult[] groupResultSumSTKInHand = [SELECT sum(M_Net_Qty__c),M_Inventory__r.Id From M_Transaction_Item__c 
                                        where M_Inventory__r.M_Distributor__c  in :possibleDistributor  
                                        //and M_Inventory__r.M_Merck_Product_Code__c in:possibleProducts
                                          and M_Inventory__r.M_Product__c in:possibleProducts 
                                        and M_Inventory__r.M_Inventory_Location__c in:possibleLocations
                                        and M_Inventory__r.M_FormatCode__c='Case' 
                                        and M_CountInInventory__c = true 
                                         group by M_Inventory__r.Id 
                                         having sum(M_Net_Qty__c) >0];   
                                          
                    for ( AggregateResult SumSTKInHand:groupResultSumSTKInHand )
                    {       
                        System.Debug('*****************************LN  Rollupsum StInHand ' + SumSTKInHand)  ;
                        Decimal  vSumSTKInHand = Integer.valueOf(SumSTKInHand.get('expr0'));
                       
                            Id InvCaseId= (Id)(SumSTKInHand.get('Id'));
                            PosCaseInventory.add(InvCaseId);
                            MapPosCaseInvIdQtty.put(InvCaseId,vSumSTKInHand);
                            System.Debug('*****************************LN Positive Case Inventory true:' +SumSTKInHand.get('Id') + '' + SumSTKInHand.get('expr0'));
                       
                    }
            
                    //Build Map of possible corresponding cases that match the negative Inv Eaches
                    //M_Merck_Product_Code__c,
                    Map<Id,M_Inventory__c> MapCorrCases = new Map<Id,M_Inventory__c>([SELECT Id, Name,M_Inventory_Location__c,M_Distributor__c,
                            M_BreakCase__c,M_FormatCode__c,M_Product__c,
                            M_Product_Format__r.buzz_retail__Conversion_Eaches__c,M_Product_Format__r.Id
                            FROM M_Inventory__c
                            where Id in :PosCaseInventory ]);
                 
                    // Build list of  Inventory Id of corresponding Inv Cases to check the Break Case Checkbox 
                    if (MapCorrCases.size()>0)
                    {    
                        System.Debug('*****************************LN >0 CorrCasesFound');
                        List<Id> InventoriesToBreakIds = new List<Id>();
                        
                        for (M_Inventory__c CorrCaseInv:MapCorrCases.values()) 
                        {
                            System.Debug('*****************************LN  In MapCorrCases.values ,MapNegativeInv:'+ MapNegativeInv);
                            //string key=String.ValueOf(CorrCaseInv.M_Distributor__c)+String.ValueOf(CorrCaseInv.M_Inventory_Location__c)+String.ValueOf(CorrCaseInv.M_Merck_Product_Code__c);
                            string key=String.ValueOf(CorrCaseInv.M_Distributor__c)+String.ValueOf(CorrCaseInv.M_Inventory_Location__c)+String.ValueOf(CorrCaseInv.M_Product__c);
                            if (MapNegativeInv.containsKey(key)) 
                            {
                               InventoriesToBreakIds.add(MapCorrCases.get(CorrCaseInv.Id).Id);
                                
                                Decimal vNegQttyEachToAdjust = MapNegInvEachIdQtty.get(MapNegativeInv.get(key));
                                Decimal vProdConversionEach = MapCorrCases.get(CorrCaseInv.Id).M_Product_Format__r.buzz_retail__Conversion_Eaches__c;
                                Decimal vCasesQttyInHand = MapPosCaseInvIdQtty.get(CorrCaseInv.Id);
                                
                                 vNegQttyEachToAdjust = math.abs(vNegQttyEachToAdjust);
                                 if (vNegQttyEachToAdjust < vProdConversionEach)
                                    MapCaseInvQttyToBreak.put(CorrCaseInv.Id,1);    
                                else
                                {                                            
                                        Decimal vnumberoRound = (vNegQttyEachToAdjust/vProdConversionEach);
                                                                 
                                        Decimal vNumberofCaseToBreak = vnumberoRound.round(roundingMode.UP);
                                        
                                        //if we have more cases to break than what we have so only break Qtty in hand for cases 
                                        if (vNumberofCaseToBreak >= vCasesQttyInHand)
                                                MapCaseInvQttyToBreak.put(CorrCaseInv.Id,vCasesQttyInHand);
                                        else
                                               MapCaseInvQttyToBreak.put(CorrCaseInv.Id,vNumberofCaseToBreak);
                                }
                                System.Debug('*****************************LN CorrCasesFound :ProductCode: ' + MapCorrCases.get(CorrCaseInv.Id).M_Product__c + 'inv :' +  + MapCorrCases.get(CorrCaseInv.Id).Name);
                            }       
                        }
                        
                        //Get Fred Function
                        if (MapCaseInvQttyToBreak.size()>0){
                            TriggerControl.FreezeInventoryTrigger = true;
                            List<M_Inventory_Transaction__c> newTransactions = new list<M_Inventory_Transaction__c>();
                            //Get the Cases Inv to Break
                            //M_Merck_Product_Code__c,
                            Map<Id,M_Inventory__c> inventories = new Map<Id,M_Inventory__c>([SELECT Id, Name,M_Inventory_Location__c,M_Distributor__c,
                                        M_BreakCase__c,M_BatchExpiration__c,M_IsMobile__c,M_LastCaseBorken__c,
                                        M_Owner__c,M_Product__c,M_Product_Format__c,M_ProductBatch__c,M_UPC_Code__c,M_Product_Format__r.buzz_retail__Conversion_Eaches__c
                                        FROM M_Inventory__c
                                        WHERE id in:InventoriesToBreakIds ]);
                          
                            
                            for (M_Inventory__c inventory:inventories.Values()) {
                               //3. Transaction Header
                                    M_Inventory_Transaction__c newTrans=new M_Inventory_Transaction__c();
                                    newTrans.RecordTypeId=RecType.getId(M_Inventory_Transaction__c.SObjectType,RecType.Name.Break_Case);
                                    newTrans.M_Distributor__c=inventory.M_Distributor__c;
                                    newTrans.M_Transaction_Date__c=System.Today();
                                    newTrans.M_Inventory_Location__c=inventory.M_Inventory_Location__c;
                                    newTrans.M_From__c=inventory.M_Distributor__c;
                                    newTrans.M_To__c=inventory.M_Distributor__c;
                                    newTrans.M_Status__c='Processing';
                                    newTrans.M_Transaction_Origin_ID__c=inventory.id;
                                    newTransactions.add(newTrans);
                                    
                                    //4. Upadte Inventory's Last Date Broken                    
                                    inventory.M_LastCaseBorken__c=System.Today();
                                              
                            }
                                        
                            insert newTransactions;
                                                    
                            List<M_Transaction_Item__c> newTransItems = new List<M_Transaction_Item__c>();
                            
                            string Key2;
                            for (M_Inventory_Transaction__c trans:newTransactions) {
                                
                                M_Inventory__c originalInv=inventories.get(trans.M_Transaction_Origin_ID__c);
                                //Old code
                                Key2=String.ValueOf(String.ValueOf(originalInv.M_Distributor__c)+String.ValueOf(originalInv.M_Inventory_Location__c)+String.ValueOf(originalInv.M_Product__c)); 
                                
                                //Modified by Minh-Dien@9-Aug-2013
                                //Use M_Merck_Product_Code__c
                                //Since Merck Product Code is different than M_Product__c
                                //Key2=String.ValueOf(String.ValueOf(originalInv.M_Distributor__c)+String.ValueOf(originalInv.M_Inventory_Location__c)+String.ValueOf(originalInv.M_Merck_Product_Code__c));                      

                             
                                //5. Debit Transation
                                M_Transaction_Item__c debitTrans = new M_Transaction_Item__c();
                                debitTrans.M_Inventory_Transaction__c=trans.Id;
                                debitTrans.RecordTypeId=RecType.getId(M_Transaction_Item__c.SObjectType,RecType.Name.Break_Case);
                                debitTrans.M_Inventory__c=trans.M_Transaction_Origin_ID__c;
                                debitTrans.M_Product__c=originalInv.M_Product__c;
                                debitTrans.M_Product_Format__c=originalInv.M_Product_Format__c; //Should always be a case
                                debitTrans.M_Original_Qty__c=MapCaseInvQttyToBreak.get(trans.M_Transaction_Origin_ID__c); //Nbr cases to break
                                debitTrans.M_IsMobile__c=trans.M_IsMobile__c;
                                debitTrans.M_Debit_Transaction__c=true;
                                debitTrans.M_Credit_Transaction__c=false;
                                newTransItems.add(debitTrans);
                                                    
                                //6. Credit Transaction //should point to a "Each" inventory
                               
                                M_Transaction_Item__c creditTrans = new M_Transaction_Item__c();
                                creditTrans.M_Inventory_Transaction__c=trans.Id;
                                creditTrans.RecordTypeId=RecType.getId(M_Transaction_Item__c.SObjectType,RecType.Name.Break_Case);
                                creditTrans.M_Inventory__c=MapNegativeInv.get(Key2);
                                creditTrans.M_Product__c=originalInv.M_Product__c;
                                //Old code              
                                //creditTrans.M_Product_Format__c=MapNegEachInv.get(Key2).M_Product_Format__r.Name;
                                //Modified by Minh-Dien@09-Aug-2013
                                //Datatype match
                                creditTrans.M_Product_Format__c=MapNegEachInv.get(Key2).M_Product_Format__c; 
                                creditTrans.M_Original_Qty__c=(originalInv.M_Product_Format__r.buzz_retail__Conversion_Eaches__c)*(MapCaseInvQttyToBreak.get(trans.M_Transaction_Origin_ID__c));
                                creditTrans.M_IsMobile__c=trans.M_IsMobile__c;
                                creditTrans.M_Debit_Transaction__c=false;
                                creditTrans.M_Credit_Transaction__c=true;
                                newTransItems.add(creditTrans); 
                                
                                trans.M_Status__c=opli.Inventory_Transaction_Completion_Status__c;   
                                        
                            }
                            
                            insert newTransItems;
                            update newTransactions; //to reflect final status
                                    
                            //Update inventories with Last Date Broken
                            update inventories.Values();                  
                        }       
                                                                
                    }//if (MapCorrCases.size()>0)    
                    //Avoid Governor Limits 
                    System.Debug('*****************************LN  Checking Governor Limits,Current query ran:' + Limits.getQueries() + 'out of : ' +  Limits.getLimitQueries()  );
                    
                }// if (!NegEachInventory.isEmpty())
                
        } //If (opli.M_Automate_Inventory_Break_Case__c = true)
        
        System.Debug('MMMMMM : InventoryRecord.ProcessAllInventoriesToBreak END ');
 
        
    }//  if (!TriggerControl.FreezeInventoryTriggerBreakCase)
   
}