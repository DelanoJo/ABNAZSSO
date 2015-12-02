/**====================================================================
* Appirio, Inc
* Name: ProductsSearchControllerTest
* Description: Test class for ProductsSearchController
* Created Date: 27 August 2015
* Created By: Matt Salpietro (Appirio)
* 
* Date Modified                Modified By                  Description of the update
* 
=====================================================================*/
@isTest(seealldata=false)
private class ProductsSearchController_Test {
    
    static US_Product__c product;
    static US_Product__c product2;
    static US_Product__c product3;
    static US_Product__c product4;
    
    static Milestone1_Project__c program;
    static{
        
        //creates 2 products
        product = new US_Product__c(Name = '_test_Prod1');
        insert product;

        product2 = new US_Product__c(Name = '_test_Prod2');
        insert product2;

        product3 = new US_Product__c(Name = '_test_Prod3');
        insert product3;
        
        product4 = new US_Product__c(Name = '_test_Prod4');
        insert product4;
        
        program = new Milestone1_Project__c(Name = 'test');
        insert program;

    } 
    
    static testMethod void unit_test_1() {
        
        User usr = [Select Id From User Where Id = :UserInfo.getUserId()];
        update usr;

        Market_Ready_Product__c mrp = new Market_Ready_Product__c(Program__c = program.Id, Product__c = product.Id);
        insert mrp;

        Test.startTest();

        PageReference ref = Page.ProductSearch;
        Test.setCurrentPageReference(ref);
        ApexPages.currentPage().getParameters().put('id', program.Id);
        ApexPages.currentPage().getParameters().put('child', 'Market_Ready_Product__c');

        ProductSearchController controller = new ProductSearchController(new ApexPages.StandardController(program));

        controller.productName = '_test_Prod';
        controller.loadData();
        System.assert(controller.records.size()==4,' Why not 4 products? '+controller.records);
        System.assert(controller.resultSize == 4,' Why not 2 results in totale? '+controller.resultSize);
        System.assert(controller.pageSize == 10, ' Why page size is not the default value? '+controller.pageSize);
        System.assert(controller.pageNumber == 1, ' Why not 1st page? '+controller.pageNumber);
        System.assert(controller.totalPages == 1, ' Why not 1 page in total? '+controller.totalPages);
        System.assert(controller.selectedProductsValues.size() == 1, ' Why selected products? '+controller.selectedProductsValues);
        System.assert(controller.itemsSelected == true,' Why items selected? ');
        
        //changes page size to 1: should be 4 pages
        controller.newPageSize = 1;
        controller.loadData();
        
        System.assert(controller.pageSize == 1, ' Why page size is not 1? '+controller.pageSize);
        System.assert(controller.totalPages == 4, ' Why not 4 pages in total? '+controller.totalPages);
        controller.goToLastPage();
        System.assert(controller.pageNumber == 4,' Why not 4th page? '+controller.pageNumber);
        controller.goToFirstPage();
        System.assert(controller.pageNumber == 1,' Why not first page? '+controller.pageNumber);
        controller.goToNextPage();
        System.assert(controller.pageNumber == 2,' Why not 2nd page? '+controller.pageNumber);
        controller.goToNext2Page();
        System.assert(controller.pageNumber == 4,' Why not 4th page? '+controller.pageNumber);
        controller.goToPrevPage();
        System.assert(controller.pageNumber == 3,' Why not 3th page? '+controller.pageNumber);
        controller.goToPrev2Page();
        System.assert(controller.pageNumber == 1,' Why not 1st page? '+controller.pageNumber);
        controller.sortRecordset();
        controller.records[0].selectItem();
        controller.saveData();
        
        //test remote action
        List<AggregateResult> arList = ProductSearchController.searchFilters('_test_Prod', 'Name');
        SYstem.assert(arList.size()==4,'Why not 4 results? '+arList );
        
        update product;
        controller.loadData();
        
        //tests compare to
        ProductSearchController.SelectableProduct selProd = new ProductSearchController.SelectableProduct(new US_Product__c(Name = 'A'),false,controller);
        ProductSearchController.SelectableProduct selProd2 = new ProductSearchController.SelectableProduct(new US_Product__c(Name = 'B'),false,controller);
        System.assert(selProd.compareTo('TEST') == 1,'Unexpected return value');
        System.assert(selProd.compareTo(selProd2 ) == -1,'Unexpected return value');
        selProd.selectItem();
        selProd.removeSelected();
        System.Assert(ProductSearchController.getPicklistValues('Mandate_Product__c','Status__c').size() > 0);
        controller.selectAll();
        controller.cancel();
        Test.stopTest();
    }
}