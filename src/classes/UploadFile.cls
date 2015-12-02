/**====================================================================
 * Appirio, Inc
 * Name: UploadFile
 * Description: Controller for Add_Photo.page
 * Created Date: 5 October 2015
 * Created By: Nimisha Prashant (Appirio)
 * 
 * Date Modified                Modified By                  Description of the update
 * 
 =====================================================================*/
 public class UploadFile {
  
  transient Document d;
    
  public Document getd (){
      if (d == null)
          d = new Document();
          return d;
    }
  public void setd (Document doc){
    d = doc;
  }

  public Contact c = new Contact();
  //public boolean allowedToUpdloadImage;
  
    public UploadFile(ApexPages.StandardController controller) {
        c = (Contact) controller.getRecord();
/*      // True if User is associated to contact
	      if(c.user__c == Userinfo.getUserId()){
          allowedToUpdloadImage = true;
        }
        else   
          allowedToUpdloadImage = false;

        allowedToUpdloadImage = true;
*/        
    } 
    
    public PageReference savefile (){
    try {
      List<Folder> folderIds = new List<Folder>([SELECT Name, Id FROM Folder WHERE Name = 'Contact Photos']);
      if(!folderIds.isEmpty()) {
        d.folderid = folderIds[0].Id; 
      }
      else {
        d.folderid = UserInfo.getUserId();
      }
/*    //Throw exception if User is not allowed to upload a picture to that contact.
      if(!allowedToUpdloadImage)
        throw new CloudSpokesUserException();
*/        
      //Throw exception if picture uploaded exceed 1 Mo.
      if(d.BodyLength < 1000000){
        insert d;         
        c.Image_Id__c = d.Id;
        update c;
        return redirectUser();
      }
      else
        throw new CloudSpokesFileException();
      }
   catch(CloudSpokesFileException ex){
        ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, Label.CloudspokesFileException);
        ApexPages.addMessage(myMsg);
        return null;
   }
/*  
  catch(CloudSpokesUserException ex){
        ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, Label.CloudspokesUserException);
        ApexPages.addMessage(myMsg);
        return null;
  }
*/
    }
    
    public PageReference redirectUser(){
      //Return user to Contact page
      PageReference page = new ApexPages.StandardController(c).view();
      page.setRedirect(true);
      return page;
    }
    
    public class CloudSpokesFileException extends Exception {}
    public class CloudSpokesUserException extends Exception {}
    
}