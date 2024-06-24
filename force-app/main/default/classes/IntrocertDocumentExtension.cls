/*************************************************************************
    @ Author        : psvestka
    @ Date          : 10. 6. 2016
    @ TestClass     : IntrocertDocumentExtensionTest
    @ Description   : US-1375
****************************************************************************/

public with sharing class IntrocertDocumentExtension {
    
    private Account acc;
    private String orgId = UserInfo.getOrganizationId();
    private Id logoId = null;
    private String pod = null;
    
    public List<Integer> controllers { get; private set; }
    public List<Integer> shareholders { get; private set; }
  
    public IntrocertDocumentExtension(ApexPages.StandardController stdCont) {
        this.acc = (Account) stdCont.getRecord();
        
        List<Document> docs = [SELECT id
                                 FROM Document 
                                WHERE developerName = 'Standard_Bank_Logo'
                                  AND isPublic = true
                                ORDER BY createdDate DESC];
        if (docs.size() > 0) {
            this.logoId = docs.get(0).id;
        } else if (Test.isRunningTest()) {
            this.logoId = '000000000000000000';
        }
        
        String baseUrl = System.URL.getSalesforceBaseURL().toExternalForm();
        //this.pod = findPod(baseUrl);
        this.pod = URL.getSalesforceBaseUrl().getHost().remove('.visual.force.com');
        controllers = new List<Integer>();
        shareholders = new List<Integer>();
        
        // generate dummy values up to the ideal of 14 rows each
        for (Integer i = controllers.size(); i < 14; i++) {
            controllers.add(i);
        }
        
        for (Integer i = shareholders.size(); i < 13; i++) {
            shareholders.add(i);
        }
    }
    
    @TestVisible
    private String findPod(String host) {
        system.debug('host ' + host); 
        System.debug('1111 ' + URL.getSalesforceBaseUrl().getHost().remove('visual.force.com'));
        Pattern p = Pattern.compile('(https://|https://c\\.)([a-zA-Z0-9]+)\\.(sales|visual\\.)force\\.com');
        Matcher m = p.matcher(host);
        system.debug('m ' + m);
        //return 'https://standardbank--sprint--c.cs81';
        
        if (!m.matches() || m.groupCount() != 3) {
            return null;
        }
        
        return m.group(2); 
    }
    
    public String getLogoUrl() {
        System.debug('logoId ' + logoId);
        System.debug('pod ' + pod);
        System.debug('orgId ' + orgId);
        //String template = 'https://c.{0}.content.force.com/servlet/servlet.ImageServer?id={1}&oid={2}';
        String template = 'https://{0}.content.force.com/servlet/servlet.ImageServer?id={1}&oid={2}';
        String defaultUrl = 'https://experience.standardbank.co.za/assets/images/logo-black.png';
        String val = '';
        
        if (!String.isEmpty(pod) && !String.isEmpty(logoId) && !String.isEmpty(orgId)) {
            val = String.format(template, new List<String> {pod, logoId, orgId});
        } else {
            val = defaultUrl;
        }
        
        return val;
    }
    
    /**
     * Helper to generate Ms Word directives to open up in the print layout, 
     * if written directly in VF, it will become lowercased and not work in Ms Word 
     * <= 2010
     */
    public String getWordDirectives() {
        return '\n<!--[if gte mso 9]>\n' +
        '<xml>\n' +
        '\t<w:WordDocument>\n' +
        '\t\t<w:View>Print</w:View>\n' +
        '\t\t<w:Zoom>100</w:Zoom>\n' +
        '\t\t<w:DoNotOptimizeForBrowser/>\n' +
        '\t</w:WordDocument>\n' +
        '</xml>\n' +
        '<![endif]-->';
    }
}