public class createactivities {

    public String Event { get; set; }

    public PageReference logevent() {
    PageReference changePage = new PageReference('/00U/e');
   changePage.setRedirect(true);
  
   return changePage;
           }

    public PageReference logtask() {
    PageReference changePage = new PageReference('/00T/e');
   changePage.setRedirect(true);
  
   return changePage;
            }
   
   public PageReference newopp() {
    PageReference changePage = new PageReference('/006/e');
   changePage.setRedirect(true);
  
   return changePage;
            }
}