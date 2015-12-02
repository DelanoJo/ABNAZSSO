@isTest
private class ItemPriceTest {

    static testMethod void setActiveFlagsOnInsert() {
    	Account distributor = new Account(Name='Dist w Inv', M_Is_Inventory_Return__c=true,
                                RecordTypeId=RecType.getId(Account.SObjectType, RecType.Name.Distribution_Center_with_Inventory));
        insert distributor;
        
        
    	
    	M_OPLI_Settings__c opli = new M_OPLI_Settings__c(Name='test opli', M_IsActive__c=true,M_Only_ONE_Price_List_Valid__c=true,
                                    M_Use_Outlet_Pricing__c=false,M_Use_Customer_Pricing__c=true,M_Use_Distributor_Pricing__c=false,
                                    M_Def_Inv_Return_Loc__c=distributor.Id);
        insert opli;
        
        M_Price_List__c priceList = new M_Price_List__c();
        priceList.M_IsActive__c = true;
        priceList.M_Price_List_Type__c = 'Standard';
        insert priceList;
        
        opli.M_Price_List__c=priceList.id;
        update opli;
    	
        List<buzz_retail__Product__c> prodList = new List<buzz_retail__Product__c>();
        buzz_retail__Product__c p1 = new buzz_retail__Product__c(buzz_retail__UPC_Code__c='11111', M_AllowInventory__c = true, Name ='Prod 1',M_Allow_Returns__c=true,RecordTypeId=RecType.getId(buzz_retail__Product__c.SObjectType, RecType.Name.Item));
        prodList.add(p1);
        //buzz_retail__Product__c p2 = new buzz_retail__Product__c(buzz_retail__UPC_Code__c='11222', M_AllowInventory__c = true, Name ='Prod 2');
        //prodList.add(p2);
        insert prodList;
        
        //createFormats
        List<buzz_retail__ProductFormat__c> prodFormatList = new List<buzz_retail__ProductFormat__c>();
        buzz_retail__ProductFormat__c prodForm1 = new buzz_retail__ProductFormat__c(
			Name=p1.Name + 'Test',
			buzz_retail__Product__c=p1.Id,
			buzz_retail__FormatCode__c='Eaches',
			buzz_retail__Conversion_Cases__c = 0.1,
			buzz_retail__Conversion_Eaches__c = 1,
			M_Inventory__c = true,
			M_Active__c = true
			);
			
		prodFormatList.add(prodForm1);
		
		buzz_retail__ProductFormat__c prodForm2 = new buzz_retail__ProductFormat__c(
			Name=p1.Name + 'Test',
			buzz_retail__Product__c=p1.Id,
			buzz_retail__FormatCode__c='Case',
			buzz_retail__Conversion_Cases__c = 0.1,
			buzz_retail__Conversion_Eaches__c = 1,
			M_Inventory__c = true,
			M_Active__c = true
			);
		prodFormatList.add(prodForm2);
		
		insert prodFormatList;
    	
    	List<M_Item_Price__c> ipInsertList = new List<M_Item_Price__c>();
        M_Item_Price__c ip1 = new M_Item_Price__c(M_Selling_Until__c = Date.Today()+20, M_Selling_Price__c=12, M_Selling_From__c=Date.Today()-20, M_Returning_Until__c=Date.Today()+20, M_Returning_From_c__c=Date.Today()-20, 
        					M_Return_Price__c=12, M_Product_Format__c = prodForm1.id, M_Price_List__c=priceList.id, M_Item__c=p1.id, M_Allow_Inventory__c = TRUE);
		ipInsertList.add(ip1);
		M_Item_Price__c ip2 = new M_Item_Price__c(M_Selling_Until__c = Date.Today()+20, M_Selling_Price__c=12, M_Selling_From__c=Date.Today()-20, M_Returning_Until__c=Date.Today()+20, M_Returning_From_c__c=Date.Today()-20, 
        					M_Return_Price__c=12, M_Product_Format__c = prodForm2.id, M_Price_List__c=priceList.id, M_Item__c=p1.id, M_Allow_Inventory__c = TRUE);
		ipInsertList.add(ip2);
		
		insert ipInsertList;
		
		List<M_Item_Price__c> ipListRetrieved = [select M_Active_for_Returns__c,M_Active_for_Order__c from M_Item_Price__c where id IN : ipInsertList];
		for(M_Item_Price__c ip: ipListRetrieved){
			system.assertEquals(ip.M_Active_for_Returns__c,true);
			system.assertEquals(ip.M_Active_for_Order__c, true);
		}
    }
    
    static testMethod void removeDuplicatesOnInsert() {
    	Account distributor = new Account(Name='Dist w Inv', M_Is_Inventory_Return__c=true,
                                RecordTypeId=RecType.getId(Account.SObjectType, RecType.Name.Distribution_Center_with_Inventory));
        insert distributor;
        
    	M_OPLI_Settings__c opli = new M_OPLI_Settings__c(Name='test opli', M_IsActive__c=true,M_Only_ONE_Price_List_Valid__c=true,
                                    M_Use_Outlet_Pricing__c=false,M_Use_Customer_Pricing__c=true,M_Use_Distributor_Pricing__c=false,
                                    M_Def_Inv_Return_Loc__c=distributor.Id);
        insert opli;
        
        M_Price_List__c priceList = new M_Price_List__c();
        priceList.M_IsActive__c = true;
        priceList.M_Price_List_Type__c = 'Standard';
        insert priceList;
        
        opli.M_Price_List__c=priceList.id;
        update opli;
        
        List<buzz_retail__Product__c> prodList = new List<buzz_retail__Product__c>();
        buzz_retail__Product__c p1 = new buzz_retail__Product__c(buzz_retail__UPC_Code__c='11111', M_AllowInventory__c = true, Name ='Prod 1',M_Allow_Returns__c=true,RecordTypeId=RecType.getId(buzz_retail__Product__c.SObjectType, RecType.Name.Item));
        prodList.add(p1);
        //buzz_retail__Product__c p2 = new buzz_retail__Product__c(buzz_retail__UPC_Code__c='11222', M_AllowInventory__c = true, Name ='Prod 2');
        //prodList.add(p2);
        insert prodList;
        
        //createFormats
        List<buzz_retail__ProductFormat__c> prodFormatList = new List<buzz_retail__ProductFormat__c>();
        buzz_retail__ProductFormat__c prodForm1 = new buzz_retail__ProductFormat__c(
			Name=p1.Name + 'Test',
			buzz_retail__Product__c=p1.Id,
			buzz_retail__FormatCode__c='Eaches',
			buzz_retail__Conversion_Cases__c = 0.1,
			buzz_retail__Conversion_Eaches__c = 1,
			M_Inventory__c = true,
			M_Active__c = true
			);
			
		prodFormatList.add(prodForm1);
		
		buzz_retail__ProductFormat__c prodForm2 = new buzz_retail__ProductFormat__c(
			Name=p1.Name + 'Test',
			buzz_retail__Product__c=p1.Id,
			buzz_retail__FormatCode__c='Case',
			buzz_retail__Conversion_Cases__c = 0.1,
			buzz_retail__Conversion_Eaches__c = 1,
			M_Inventory__c = true,
			M_Active__c = true
			);
		prodFormatList.add(prodForm2);
		
		insert prodFormatList;
    	
    	List<M_Item_Price__c> ipInsertList = new List<M_Item_Price__c>();
        M_Item_Price__c ip1 = new M_Item_Price__c(M_Selling_Until__c = Date.Today()+20, M_Selling_Price__c=12, M_Selling_From__c=Date.Today()-10, M_Returning_Until__c=Date.Today()+20, M_Returning_From_c__c=Date.Today()-20, 
        					M_Return_Price__c=12, M_Product_Format__c = prodForm1.id, M_Price_List__c=priceList.id, M_Item__c=p1.id, M_Allow_Inventory__c = TRUE);
		ipInsertList.add(ip1);
		
		M_Item_Price__c ip2 = new M_Item_Price__c(M_Selling_Until__c = Date.Today()+20, M_Selling_Price__c=12, M_Selling_From__c=Date.Today()-10, M_Returning_Until__c=Date.Today()+20, M_Returning_From_c__c=Date.Today()-20, 
        					M_Return_Price__c=12, M_Product_Format__c = prodForm2.id, M_Price_List__c=priceList.id, M_Item__c=p1.id, M_Allow_Inventory__c = TRUE);
		ipInsertList.add(ip2);
		insert ipInsertList;
		
		Test.startTest();
		
		List<M_Item_Price__c> ipInsertList2 = new List<M_Item_Price__c>();
        M_Item_Price__c ip3 = new M_Item_Price__c(M_Selling_Until__c = Date.Today()+30, M_Selling_Price__c=12, M_Selling_From__c=Date.Today(), M_Returning_Until__c=Date.Today()+20, M_Returning_From_c__c=Date.Today(), 
        					M_Return_Price__c=12, M_Product_Format__c = prodForm1.id, M_Price_List__c=priceList.id, M_Item__c=p1.id, M_Allow_Inventory__c = TRUE);
		ipInsertList2.add(ip3);
		
		M_Item_Price__c ip4 = new M_Item_Price__c(M_Selling_Until__c = Date.Today()+30, M_Selling_Price__c=12, M_Selling_From__c=Date.Today(), M_Returning_Until__c=Date.Today()+20, M_Returning_From_c__c=Date.Today(), 
        					M_Return_Price__c=12, M_Product_Format__c = prodForm2.id, M_Price_List__c=priceList.id, M_Item__c=p1.id, M_Allow_Inventory__c = TRUE);
		ipInsertList2.add(ip4);
		insert ipInsertList2;
		Test.stopTest();
		/*
		List<M_Item_Price__c> ipListRetrieved = [select M_Active_for_Returns__c,M_Active_for_Order__c from M_Item_Price__c where id IN : ipInsertList];
		for(M_Item_Price__c ip: ipListRetrieved){
			system.assertEquals(ip.M_Active_for_Returns__c, false,'return duplication not removed');
			system.assertEquals(ip.M_Active_for_Order__c, false,'order duplication not removed');
		}
		
		List<M_Item_Price__c> ipListRetrieved1 = [select M_Active_for_Returns__c,M_Active_for_Order__c from M_Item_Price__c where id IN : ipInsertList2];
		for(M_Item_Price__c ip: ipListRetrieved1){
			system.assertEquals(ip.M_Active_for_Returns__c, true,'return duplication not removed');
			system.assertEquals(ip.M_Active_for_Order__c, true,'order duplication not removed');
		}*/
    }
    
    /*static testMethod void removeDuplicatesOnUpdate() {
    	
    	Account distributor = new Account(Name='Dist w Inv', M_Is_Inventory_Return__c=true,
                                RecordTypeId=RecType.getId(Account.SObjectType, RecType.Name.Distribution_Center_with_Inventory));
        insert distributor;
        
    	M_OPLI_Settings__c opli = new M_OPLI_Settings__c(Name='test opli', M_IsActive__c=true,M_Only_ONE_Price_List_Valid__c=true,
                                    M_Use_Outlet_Pricing__c=false,M_Use_Customer_Pricing__c=true,M_Use_Distributor_Pricing__c=false,
                                    M_Price_List__c=null,M_Def_Inv_Return_Loc__c=distributor.Id);
        insert opli;
        
    	M_Price_List__c priceList = new M_Price_List__c();
        priceList.M_IsActive__c = true;
        priceList.M_Price_List_Type__c = 'Standard';
        insert priceList;
        
        List<buzz_retail__Product__c> prodList = new List<buzz_retail__Product__c>();
        buzz_retail__Product__c p1 = new buzz_retail__Product__c(buzz_retail__UPC_Code__c='11111', M_AllowInventory__c = true, Name ='Prod 1',M_Allow_Returns__c=true,RecordTypeId=RecType.getId(buzz_retail__Product__c.SObjectType, RecType.Name.Item));
        prodList.add(p1);
        //buzz_retail__Product__c p2 = new buzz_retail__Product__c(buzz_retail__UPC_Code__c='11222', M_AllowInventory__c = true, Name ='Prod 2');
        //prodList.add(p2);
        insert prodList;
        
        //createFormats
        List<buzz_retail__ProductFormat__c> prodFormatList = new List<buzz_retail__ProductFormat__c>();
        buzz_retail__ProductFormat__c prodForm1 = new buzz_retail__ProductFormat__c(
			Name=p1.Name + 'Test',
			buzz_retail__Product__c=p1.Id,
			buzz_retail__FormatCode__c='Eaches',
			buzz_retail__Conversion_Cases__c = 0.1,
			buzz_retail__Conversion_Eaches__c = 1,
			M_Inventory__c = true,
			M_Active__c = true
			);
			
		prodFormatList.add(prodForm1);
		
		buzz_retail__ProductFormat__c prodForm2 = new buzz_retail__ProductFormat__c(
			Name=p1.Name + 'Test',
			buzz_retail__Product__c=p1.Id,
			buzz_retail__FormatCode__c='Case',
			buzz_retail__Conversion_Cases__c = 0.1,
			buzz_retail__Conversion_Eaches__c = 1,
			M_Inventory__c = true,
			M_Active__c = true
			);
		prodFormatList.add(prodForm2);
		
		insert prodFormatList;
    	
    	List<M_Item_Price__c> ipInsertList = new List<M_Item_Price__c>();
        M_Item_Price__c ip1 = new M_Item_Price__c(M_Selling_Until__c = Date.Today()+20, M_Selling_Price__c=12, M_Selling_From__c=Date.Today()-10, M_Returning_Until__c=Date.Today()+20, M_Returning_From_c__c=Date.Today()-20, 
        					M_Return_Price__c=12, M_Product_Format__c = prodForm1.id, M_Price_List__c=priceList.id, M_Item__c=p1.id, M_Allow_Inventory__c = TRUE);
		ipInsertList.add(ip1);
		
		M_Item_Price__c ip2 = new M_Item_Price__c(M_Selling_Until__c = Date.Today()+20, M_Selling_Price__c=12, M_Selling_From__c=Date.Today()-10, M_Returning_Until__c=Date.Today()+20, M_Returning_From_c__c=Date.Today()-20, 
        					M_Return_Price__c=12, M_Product_Format__c = prodForm2.id, M_Price_List__c=priceList.id, M_Item__c=p1.id, M_Allow_Inventory__c = TRUE);
		ipInsertList.add(ip2);
		insert ipInsertList;
		
		
		
		List<M_Item_Price__c> ipInsertList2 = new List<M_Item_Price__c>();
        M_Item_Price__c ip3 = new M_Item_Price__c(M_Selling_Until__c = Date.Today()+30, M_Selling_Price__c=12, M_Selling_From__c=Date.Today(), M_Returning_Until__c=Date.Today()+20, M_Returning_From_c__c=Date.Today(), 
        					M_Return_Price__c=12, M_Product_Format__c = prodForm1.id, M_Price_List__c=priceList.id, M_Item__c=p1.id, M_Allow_Inventory__c = TRUE);
		ipInsertList2.add(ip3);
		
		M_Item_Price__c ip4 = new M_Item_Price__c(M_Selling_Until__c = Date.Today()+30, M_Selling_Price__c=12, M_Selling_From__c=Date.Today(), M_Returning_Until__c=Date.Today()+20, M_Returning_From_c__c=Date.Today(), 
        					M_Return_Price__c=12, M_Product_Format__c = prodForm2.id, M_Price_List__c=priceList.id, M_Item__c=p1.id, M_Allow_Inventory__c = TRUE);
		ipInsertList2.add(ip4);
		insert ipInsertList2;
		
		Test.startTest();
		ip1.M_Selling_Until__c = Date.Today()-5;
		ip2.M_Selling_Until__c = Date.Today();
		ip1.M_Returning_Until__c = Date.Today();
		ip2.M_Returning_Until__c = Date.Today()-5;
		update ipInsertList;
		Test.stopTest();
		
		List<M_Item_Price__c> ipListRetrieved = [select M_Active_for_Returns__c,M_Active_for_Order__c from M_Item_Price__c where id IN : ipInsertList];
		for(M_Item_Price__c ip: ipListRetrieved){
			system.assertEquals(ip.M_Active_for_Returns__c, false,'return duplication not removed');
			system.assertEquals(ip.M_Active_for_Order__c, false,'order duplication not removed');
		}
		
		List<M_Item_Price__c> ipListRetrieved1 = [select M_Active_for_Returns__c,M_Active_for_Order__c from M_Item_Price__c where id IN : ipInsertList2];
		for(M_Item_Price__c ip: ipListRetrieved1){
			system.assertEquals(ip.M_Active_for_Returns__c, true,'return duplication not removed');
			system.assertEquals(ip.M_Active_for_Order__c, true,'order duplication not removed');
		}
    }*/
    
    static testMethod void setUnsetFlagsOnUpdate() {
    	
    	Account distributor = new Account(Name='Dist w Inv', M_Is_Inventory_Return__c=true,
                                RecordTypeId=RecType.getId(Account.SObjectType, RecType.Name.Distribution_Center_with_Inventory));
        insert distributor;
        
    	M_OPLI_Settings__c opli = new M_OPLI_Settings__c(Name='test opli', M_IsActive__c=true,M_Only_ONE_Price_List_Valid__c=true,
                                    M_Use_Outlet_Pricing__c=false,M_Use_Customer_Pricing__c=true,M_Use_Distributor_Pricing__c=false,
                                    M_Def_Inv_Return_Loc__c=distributor.Id);
        insert opli;
        
        M_Price_List__c priceList = new M_Price_List__c();
        priceList.M_IsActive__c = true;
        priceList.M_Price_List_Type__c = 'Standard';
        insert priceList;
        
        opli.M_Price_List__c=priceList.id;
        update opli;
        
        List<buzz_retail__Product__c> prodList = new List<buzz_retail__Product__c>();
        buzz_retail__Product__c p1 = new buzz_retail__Product__c(buzz_retail__UPC_Code__c='11111', M_AllowInventory__c = true, Name ='Prod 1',M_Allow_Returns__c=true,RecordTypeId=RecType.getId(buzz_retail__Product__c.SObjectType, RecType.Name.Item));
        prodList.add(p1);
        insert prodList;
        
        //createFormats
        List<buzz_retail__ProductFormat__c> prodFormatList = new List<buzz_retail__ProductFormat__c>();
        buzz_retail__ProductFormat__c prodForm1 = new buzz_retail__ProductFormat__c(
			Name=p1.Name + 'Test',
			buzz_retail__Product__c=p1.Id,
			buzz_retail__FormatCode__c='Eaches',
			buzz_retail__Conversion_Cases__c = 0.1,
			buzz_retail__Conversion_Eaches__c = 1,
			M_Inventory__c = true,
			M_Active__c = true
			);
			
		prodFormatList.add(prodForm1);
		
		buzz_retail__ProductFormat__c prodForm2 = new buzz_retail__ProductFormat__c(
			Name=p1.Name + 'Test',
			buzz_retail__Product__c=p1.Id,
			buzz_retail__FormatCode__c='Case',
			buzz_retail__Conversion_Cases__c = 0.1,
			buzz_retail__Conversion_Eaches__c = 1,
			M_Inventory__c = true,
			M_Active__c = true
			);
		prodFormatList.add(prodForm2);
		
		insert prodFormatList;
    	
    	List<M_Item_Price__c> ipInsertList = new List<M_Item_Price__c>();
    	//order flag checked return flag unchecked
        M_Item_Price__c ip1 = new M_Item_Price__c(M_Selling_From__c=Date.Today(), M_Selling_Until__c = Date.Today()+20, M_Selling_Price__c=12, M_Returning_From_c__c=Date.Today()-20, M_Returning_Until__c=Date.Today()-1,
        					M_Return_Price__c=12, M_Product_Format__c = prodForm1.id, M_Price_List__c=priceList.id, M_Item__c=p1.id, M_Allow_Inventory__c = TRUE);
		ipInsertList.add(ip1);
		//order flag unchecked return flag checked
		M_Item_Price__c ip2 = new M_Item_Price__c(M_Selling_Price__c=12, M_Selling_From__c=Date.Today()-30, M_Selling_Until__c = Date.Today()-20, M_Returning_From_c__c=Date.Today()-20, M_Returning_Until__c=Date.Today()+20,
        					M_Return_Price__c=12, M_Product_Format__c = prodForm2.id, M_Price_List__c=priceList.id, M_Item__c=p1.id, M_Allow_Inventory__c = TRUE);
		ipInsertList.add(ip2);
		insert ipInsertList;
		
		List<M_Item_Price__c> ipListRetrieved = [select M_Active_for_Returns__c,M_Active_for_Order__c from M_Item_Price__c where id IN : ipInsertList order by Name];
		system.assertEquals(ipListRetrieved[1].M_Active_for_Returns__c, true,'flag not set');
		system.assertEquals(ipListRetrieved[0].M_Active_for_Order__c, true,'flag not set');
		
		/*List<M_Item_Price__c> ipInsertList2 = new List<M_Item_Price__c>();
        M_Item_Price__c ip3 = new M_Item_Price__c(M_Selling_Until__c = Date.Today()-20, M_Selling_Price__c=12, M_Selling_From__c=Date.Today()-30, M_Returning_Until__c=Date.Today()+20, M_Returning_From_c__c=Date.Today(), 
        					M_Return_Price__c=12, M_Product_Format__c = prodForm1.id, M_Price_List__c=priceList.id, M_Item__c=p1.id, M_Allow_Inventory__c = TRUE);
		ipInsertList2.add(ip3);
		
		M_Item_Price__c ip4 = new M_Item_Price__c(M_Selling_Until__c = Date.Today()+30, M_Selling_Price__c=12, M_Selling_From__c=Date.Today(), M_Returning_Until__c=Date.Today()-2, M_Returning_From_c__c=Date.Today()-20, 
        					M_Return_Price__c=12, M_Product_Format__c = prodForm2.id, M_Price_List__c=priceList.id, M_Item__c=p1.id, M_Allow_Inventory__c = TRUE);
		ipInsertList2.add(ip4);
		insert ipInsertList2;*/
		
		//uncheck order flag and check return flag
		ip1.M_Selling_From__c=Date.Today()-30;
		ip1.M_Selling_Until__c = Date.Today()-20;
		
		ip1.M_Returning_From_c__c=Date.Today();
		ip1.M_Returning_Until__c=Date.Today()+20;
		
		
		//check order flag& uncheck return flag
		ip2.M_Selling_From__c=Date.Today();
		ip2.M_Selling_Until__c = Date.Today()+30;
		
		ip2.M_Returning_From_c__c=Date.Today()-20;
		ip2.M_Returning_Until__c=Date.Today()-2;
		
		Test.startTest();
		update ipInsertList;
		Test.stopTest();
		
		List<M_Item_Price__c> ipListRetrieved1= [select M_Active_for_Returns__c,M_Active_for_Order__c from M_Item_Price__c where id IN : ipInsertList order by Name];
		system.assertEquals(ipListRetrieved1[0].M_Active_for_Returns__c, true,'flag not set');
		system.assertEquals(ipListRetrieved1[1].M_Active_for_Order__c, true,'flag not set');
		/*
		List<M_Item_Price__c> ipListRetrieved = [select M_Active_for_Returns__c,M_Active_for_Order__c from M_Item_Price__c where id IN : ipInsertList];
		for(M_Item_Price__c ip: ipListRetrieved){
			system.assertEquals(ip.M_Active_for_Returns__c, false,'return duplication not removed');
			system.assertEquals(ip.M_Active_for_Order__c, false,'order duplication not removed');
		}
		
		List<M_Item_Price__c> ipListRetrieved1 = [select M_Active_for_Returns__c,M_Active_for_Order__c from M_Item_Price__c where id IN : ipInsertList2];
		for(M_Item_Price__c ip: ipListRetrieved1){
			system.assertEquals(ip.M_Active_for_Returns__c, true,'return duplication not removed');
			system.assertEquals(ip.M_Active_for_Order__c, true,'order duplication not removed');
		}*/
    }
    
    /*
    static testMethod void removeDuplicatesInBatch() {
    	
    	Account distributor = new Account(Name='Dist w Inv', M_Is_Inventory_Return__c=true,
                                RecordTypeId=RecType.getId(Account.SObjectType, RecType.Name.Distribution_Center_with_Inventory));
        insert distributor;
        
        
    	M_OPLI_Settings__c opli = new M_OPLI_Settings__c(Name='test opli', M_IsActive__c=true,M_Only_ONE_Price_List_Valid__c=true,
                                    M_Use_Outlet_Pricing__c=false,M_Use_Customer_Pricing__c=true,M_Use_Distributor_Pricing__c=false,
                                    M_Def_Inv_Return_Loc__c=distributor.Id);
        insert opli;
        
        M_Price_List__c priceList = new M_Price_List__c();
        priceList.M_IsActive__c = true;
        priceList.M_Price_List_Type__c = 'Standard';
        insert priceList;
        
    	opli.M_Price_List__c=priceList.id;
    	update opli;
        
        List<buzz_retail__Product__c> prodList = new List<buzz_retail__Product__c>();
        buzz_retail__Product__c p1 = new buzz_retail__Product__c(buzz_retail__UPC_Code__c='11111', M_AllowInventory__c = true, Name ='Prod 1',M_Allow_Returns__c=true,RecordTypeId=RecType.getId(buzz_retail__Product__c.SObjectType, RecType.Name.Item));
        prodList.add(p1);
        buzz_retail__Product__c p2 = new buzz_retail__Product__c(buzz_retail__UPC_Code__c='11222', M_AllowInventory__c = true, Name ='Prod 2',M_Allow_Returns__c=true,RecordTypeId=RecType.getId(buzz_retail__Product__c.SObjectType, RecType.Name.Item));
        prodList.add(p2);
        insert prodList;
        
        //createFormats
        List<buzz_retail__ProductFormat__c> prodFormatList = new List<buzz_retail__ProductFormat__c>();
        buzz_retail__ProductFormat__c prodForm1 = new buzz_retail__ProductFormat__c(
			Name=p1.Name + 'Test',
			buzz_retail__Product__c=p1.Id,
			buzz_retail__FormatCode__c='Eaches',
			buzz_retail__Conversion_Cases__c = 0.1,
			buzz_retail__Conversion_Eaches__c = 1,
			M_Inventory__c = true,
			M_Active__c = true
			);
			
		prodFormatList.add(prodForm1);
		
		buzz_retail__ProductFormat__c prodForm2 = new buzz_retail__ProductFormat__c(
			Name=p1.Name + 'Test',
			buzz_retail__Product__c=p1.Id,
			buzz_retail__FormatCode__c='Case',
			buzz_retail__Conversion_Cases__c = 0.1,
			buzz_retail__Conversion_Eaches__c = 1,
			M_Inventory__c = true,
			M_Active__c = true
			);
		prodFormatList.add(prodForm2);
		
		buzz_retail__ProductFormat__c prodForm3 = new buzz_retail__ProductFormat__c(
			Name=p1.Name + 'Test',
			buzz_retail__Product__c=p2.Id,
			buzz_retail__FormatCode__c='Eaches',
			buzz_retail__Conversion_Cases__c = 0.1,
			buzz_retail__Conversion_Eaches__c = 1,
			M_Inventory__c = true,
			M_Active__c = true
			);
			
		prodFormatList.add(prodForm3);
		
		buzz_retail__ProductFormat__c prodForm4 = new buzz_retail__ProductFormat__c(
			Name=p1.Name + 'Test',
			buzz_retail__Product__c=p2.Id,
			buzz_retail__FormatCode__c='Eaches',
			buzz_retail__Conversion_Cases__c = 0.1,
			buzz_retail__Conversion_Eaches__c = 1,
			M_Inventory__c = true,
			M_Active__c = true
			);
			
		prodFormatList.add(prodForm4);
		
		insert prodFormatList;
    	
    	List<M_Item_Price__c> ipInsertList = new List<M_Item_Price__c>();
        M_Item_Price__c ip1 = new M_Item_Price__c(M_Selling_Until__c = Date.Today()+20, M_Selling_Price__c=12, M_Selling_From__c=Date.Today()-10, M_Returning_Until__c=Date.Today()+20, M_Returning_From_c__c=Date.Today()-20, 
        					M_Return_Price__c=12, M_Product_Format__c = prodForm1.id, M_Price_List__c=priceList.id, M_Item__c=p1.id, M_Allow_Inventory__c = TRUE);
		ipInsertList.add(ip1);
		
		M_Item_Price__c ip2 = new M_Item_Price__c(M_Selling_Until__c = Date.Today()+20, M_Selling_Price__c=12, M_Selling_From__c=Date.Today()-10, M_Returning_Until__c=Date.Today()+20, M_Returning_From_c__c=Date.Today()-20, 
        					M_Return_Price__c=12, M_Product_Format__c = prodForm2.id, M_Price_List__c=priceList.id, M_Item__c=p1.id, M_Allow_Inventory__c = TRUE);
		ipInsertList.add(ip2);
			
        M_Item_Price__c ip3 = new M_Item_Price__c(M_Selling_Until__c = Date.Today()+30, M_Selling_Price__c=12, M_Selling_From__c=Date.Today(), M_Returning_Until__c=Date.Today()+20, M_Returning_From_c__c=Date.Today(), 
        					M_Return_Price__c=12, M_Product_Format__c = prodForm1.id, M_Price_List__c=priceList.id, M_Item__c=p1.id, M_Allow_Inventory__c = TRUE);
		ipInsertList.add(ip3);
		
		M_Item_Price__c ip4 = new M_Item_Price__c(M_Selling_Until__c = Date.Today()+30, M_Selling_Price__c=12, M_Selling_From__c=Date.Today(), M_Returning_Until__c=Date.Today()+20, M_Returning_From_c__c=Date.Today(), 
        					M_Return_Price__c=12, M_Product_Format__c = prodForm2.id, M_Price_List__c=priceList.id, M_Item__c=p1.id, M_Allow_Inventory__c = TRUE);
		ipInsertList.add(ip4);
		

        M_Item_Price__c ip5 = new M_Item_Price__c(M_Selling_Until__c = Date.Today()+20, M_Selling_Price__c=12, M_Selling_From__c=Date.Today()-10, M_Returning_Until__c=Date.Today()+20, M_Returning_From_c__c=Date.Today()-20, 
        					M_Return_Price__c=12, M_Product_Format__c = prodForm3.id, M_Price_List__c=priceList.id, M_Item__c=p2.id, M_Allow_Inventory__c = TRUE);
		ipInsertList.add(ip5);
		
		M_Item_Price__c ip6 = new M_Item_Price__c(M_Selling_Until__c = Date.Today()+20, M_Selling_Price__c=12, M_Selling_From__c=Date.Today()-10, M_Returning_Until__c=Date.Today()+20, M_Returning_From_c__c=Date.Today()-20, 
        					M_Return_Price__c=12, M_Product_Format__c = prodForm4.id, M_Price_List__c=priceList.id, M_Item__c=p2.id, M_Allow_Inventory__c = TRUE);
		ipInsertList.add(ip6);
			
        M_Item_Price__c ip7 = new M_Item_Price__c(M_Selling_Until__c = Date.Today()+30, M_Selling_Price__c=12, M_Selling_From__c=Date.Today(), M_Returning_Until__c=Date.Today()+20, M_Returning_From_c__c=Date.Today(), 
        					M_Return_Price__c=12, M_Product_Format__c = prodForm3.id, M_Price_List__c=priceList.id, M_Item__c=p2.id, M_Allow_Inventory__c = TRUE);
		ipInsertList.add(ip7);
		
		M_Item_Price__c ip8 = new M_Item_Price__c(M_Selling_Until__c = Date.Today()+30, M_Selling_Price__c=12, M_Selling_From__c=Date.Today(), M_Returning_Until__c=Date.Today()+20, M_Returning_From_c__c=Date.Today(), 
        					M_Return_Price__c=12, M_Product_Format__c = prodForm4.id, M_Price_List__c=priceList.id, M_Item__c=p2.id, M_Allow_Inventory__c = TRUE);
		ipInsertList.add(ip8);
		
		//records to unset values
		M_Item_Price__c ip9 = new M_Item_Price__c(M_Selling_Until__c = Date.Today()-2, M_Selling_Price__c=12, M_Selling_From__c=Date.Today()-30, M_Returning_Until__c=Date.Today()-2, M_Returning_From_c__c=Date.Today()-20, 
        					M_Return_Price__c=12, M_Product_Format__c = prodForm1.id, M_Price_List__c=priceList.id, M_Item__c=p1.id, M_Allow_Inventory__c = TRUE,M_Active_for_Order__c=true,M_Active_for_Returns__c=true);
		ipInsertList.add(ip9);
		
		ItemPriceRecord.preventUpateTrigger = true;// this has to be done so that duplicates are not detected on insert just set flags if they call within today's dates
		
		insert ipInsertList;
		
		
	    ItemPriceBatch ipBatch = new ItemPriceBatch();
        /*ipBatch.query = 'SELECT Id, Name, StartDate__c, EndDate__c, CurrentPeriod__c ' +
            'FROM Call_Frequency__c ' +
            'WHERE Id IN :cf' +
            ' LIMIT 3';*/
        /* M:    
        Test.StartTest();
        Database.executeBatch(ipBatch);
        Test.StopTest();
	    
		/*Test.startTest();
		ip1.M_Selling_Until__c = Date.Today()-5;
		ip2.M_Selling_Until__c = Date.Today();
		ip1.M_Returning_Until__c = Date.Today();
		ip2.M_Returning_Until__c = Date.Today()-5;
		update ipInsertList;
		Test.stopTest();*/
		
		// M: List<M_Item_Price__c> ipListOrders = [select M_Active_for_Returns__c,M_Active_for_Order__c from M_Item_Price__c where id IN : ipInsertList and M_Active_for_Order__c = true];
		// M: system.assertEquals(ipListOrders.size(),4);
		/*for(M_Item_Price__c ip: ipListRetrieved){
			system.assertEquals(ip.M_Active_for_Returns__c, true,'return duplication not removed');
			system.assertEquals(ip.M_Active_for_Order__c, false,'order duplication not removed');
		}*/
		
		// M: List<M_Item_Price__c> ipListReturns = [select M_Active_for_Returns__c,M_Active_for_Order__c from M_Item_Price__c where id IN : ipInsertList and M_Active_for_Returns__c = true];
		// M: system.assertEquals(ipListReturns.size(),4);
		/*for(M_Item_Price__c ip: ipListRetrieved1){
			system.assertEquals(ip.M_Active_for_Returns__c, true,'return duplication not removed');
			system.assertEquals(ip.M_Active_for_Order__c, true,'order duplication not removed');
		}*/
   //M:  }
    
    
}