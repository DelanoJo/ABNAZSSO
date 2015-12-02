/**====================================================================
 * Appirio, Inc
 * Name: UploadFileTest
 * Description: Test Class for Controller for Add_Photo.page
 * Created Date: 5 October 2015
 * Created By: Nimisha Prashant (Appirio)
 * 
 * Date Modified                Modified By                  Description of the update
 * 
 =====================================================================*/
@isTest
private class UploadFileTest {

    testMethod static void tsavefile() {      
        Account ac = new Account(Name = 'OxalaConsulting',ShippingPostalCode = '75001');
        insert ac;
        Contact ctc = new Contact (Salutation ='M.',
                       LastName = 'Spehner',
                       Firstname ='Olivier');
        insert ctc;
        
        Document doc = new Document(URL='http://oxalaconsulting.com/wp-content/uploads/2012/03/visu_seul_BD_Sansbarre-e1331891944675.jpg',
                      Name='FileName',
                      FolderId= UserInfo.getUserId());
        Insert doc;                     
        Test.setCurrentPage(Page.Add_Photo);
		    ApexPages.currentPage().getParameters().put('id', ctc.id);
		    ApexPages.StandardController sc = new ApexPages.StandardController(ctc);
		    UploadFile VF = new UploadFile(sc);
		    VF.setd(doc);   
		    doc = VF.getd();       
 
        
        // Beginning of TESTS 
        Test.startTest();
	        VF.savefile();
	        VF.redirectUser();
        Test.stopTest();
    }
}