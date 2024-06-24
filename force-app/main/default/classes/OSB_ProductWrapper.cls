/**
 * Wrapper class to store Product data recieved from IBM API Connect
 * 
 * @author Wojciech Kowalczyk (wkowalczyk@deloittece.com)
 * @date Mar 2020
 */
public class OSB_ProductWrapper {
    public String id {get;set;}
    public String url {get;set;}
    public cls_info info {get;set;}
    public class cls_info {
		public String name {get;set;}
		public String title {get;set;}
	}
}