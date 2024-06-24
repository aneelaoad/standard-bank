public without sharing class UTL_EmailTemplate {
    private static Map<String, EmailTemplate>  devName2EmailTemplate {
        get {
            if (devName2EmailTemplate == null) {
                devName2EmailTemplate = new Map<String, EmailTemplate>();
            }
            return devName2EmailTemplate;
        }

        set;
    }

    /**
	 * @param templateDevName DeveloperName field value of Email Template
	 *
	 * @return Id of Email Template
	 */
    public static Id getTemplateId(String templateDevName){
        return getTemplate(templateDevName).Id;
    }

    /**
	 * @param templateDevName DeveloperName field value of Email Template
     *
	 * @return DeveloperName, Body, Subject, HtmlValue and Markup of Email Template
     */
    public static EmailTemplate getTemplate(String templateDevName) {
        return getTemplates(new Set<String>{templateDevName}).get(templateDevName);
    }

    /**
	 * @param templateDevNames set of DeveloperName field value of Email Template
     *
	 * @return DeveloperName, Body, Subject, HtmlValue and Markup of Email Templates
     */
    public static Map<String, EmailTemplate> getTemplates(Set<String> templateDevNames) {
        Set<String> templatesToQueryNames = new Set<String>();
        for(String developerName : templateDevNames) {
            if (!devName2EmailTemplate.containsKey(developerName)) {
                templatesToQueryNames.add(developerName);
            }
        }
        if(!templatesToQueryNames.isEmpty()) {
            List<EmailTemplate> emailTemplates = [
                    SELECT DeveloperName, Body, Subject, HtmlValue, Markup
                    FROM EmailTemplate
                    WHERE DeveloperName IN :templatesToQueryNames
            ];

            for(EmailTemplate template : emailTemplates) {
                devName2EmailTemplate.put(template.DeveloperName, template);
            }
        }
        Map<String, EmailTemplate> selectedTemplates = new Map<String, EmailTemplate>();
        for(String developerName : templateDevNames) {
            if (devName2EmailTemplate.containsKey(developerName)) {
                selectedTemplates.put(developerName, devName2EmailTemplate.get(developerName));
            } else {
                throw new EmailTemplateException('There is no Email Template with Name:' + developerName);
            }
        }
        return selectedTemplates;
    }

    public class EmailTemplateException extends Exception {}
}