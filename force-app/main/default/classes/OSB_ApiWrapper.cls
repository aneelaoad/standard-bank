/**
 * Wrapper class to store API data recieved from IBM API Connect
 * 
 * @author Wojciech Kowalczyk (wkowalczyk@deloittece.com)
 * @date Mar 2020
 */
public with sharing class OSB_ApiWrapper {
    public String id {get;set;}
    public String url {get;set;}
    public String protocol {get;set;}
    public cls_info info {get;set;}
    public class cls_info {
		public String title {get;set;}
		public String version {get;set;}
	}
}