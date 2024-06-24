/*****************************************************************************************************\
    @ Author        : Rudolf Niehaus
    @ Date          : 10/2010
    @ Test File     : Test Method (testMe()) at the bottom of this class
    @ Description	: Class that contains functions to be used within email templates
    @ Last Modified By  : Rudolf Niehaus
    @ Last Modified On  : 03/2011
    @ Modification Description : update the function "setLine" to cater for strings that do not contain 
    							HTML tags. The function will now strip HTML tags only if they exists. 
    							
    @ Last Modified By  : Rudolf Niehaus
    @ Last Modified On  : 10/2011
    @ Modification Description : Add some logic to make sure the tagline string is not null before we check for HTML tags
     
******************************************************************************************************/
public with sharing class SA_EmailTemplateFunctions{
	
    public String line;
    public String text;
   
	//this method extracts the plain text from HTML tags   
	public void setLine(String tagline){
		if(tagline != null){
			if(tagline.contains('>') && tagline.contains('<')){
				Integer x = tagline.indexOf('>');
			
				tagline = tagline.substring(x+1,tagline.length());
			
				x = tagline.indexOf('<');
			
				line = tagline.substring(0,x);
			}else{
				line = tagline;
			}
		}
	}
	
	public String getLine(){
		return line;
	}
	

	//######################## TEST METHOD #############################
	static testMethod void testMe(){
		SA_EmailTemplateFunctions tclass = new SA_EmailTemplateFunctions();
		
		String tags = '<href=http://www.test.class>HELLO RUDIX</>';
		tclass.setLine(tags);
		tags = tclass.getLine();
		System.assertEquals(tags,'HELLO RUDIX');
		//test empty string
		tags = null;
		tclass.line = null;
		tclass.setLine(tags);
		tags = tclass.getLine();
		System.assertEquals(tags,null);
	}
	
}