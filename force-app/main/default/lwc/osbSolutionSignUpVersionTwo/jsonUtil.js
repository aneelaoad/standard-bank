export default class JsonUtil {
    constructor(contact, account, isInternal, customFields) {
        this.contact = contact;
        this.account = account;
        this.isInternal = isInternal;
        this.customFields = customFields;
    }

    formatJson(requiredFields = []) {
        const {
            Id: id,
            FirstName: firstname,
            LastName: lastName,
            Salutation:salutation,
            Title: title,
            Phone: mobileNumber,
            Email: email,
            Ping_Id__c: pingId,
            Company_Industry__c: companyIndustry,
            Identity_Number__c: identityNumber,
            OSB_ContactCountry__c: contactCountry,
            OSB_Community_Access_Status__c: communityAccessStatus,
            OSB_Community_Access_Role__c: accessRole,
            OSB_Operating_Country__c: operatingCountry
        } = this.contact;

        const {
            Registration_Number__c: companyRegistrationNumber,
            CIF__c: cifNumber,
            Name: clientName
        } = this.account;
        const jsonTemplate = {};

        if (requiredFields.includes('id')) jsonTemplate.id = id;
        if (requiredFields.includes('firstname')) jsonTemplate.firstname = firstname;
        if (requiredFields.includes('lastName')) jsonTemplate.lastName = lastName;
        if (requiredFields.includes('mobileNumber')) jsonTemplate.mobileNumber = mobileNumber;    
        if (requiredFields.includes('email')) jsonTemplate.email = email;
        if (requiredFields.includes('pingId')) jsonTemplate.pingId = pingId;
        if (requiredFields.includes('companyIndustry')) jsonTemplate.companyIndustry = companyIndustry;         
        if (requiredFields.includes('registrationNumber')) jsonTemplate.companyRegistrationNumber = companyRegistrationNumber;
        if (requiredFields.includes('identityNumber')) jsonTemplate.identityNumber = identityNumber;      
        if (this.isInternal && requiredFields.includes('cifNumber')) {
            jsonTemplate.cifNumber = cifNumber;
        }
        if (requiredFields.includes('salutation')) jsonTemplate.salutation = salutation;
        if (requiredFields.includes('contactCountry')) jsonTemplate.contactCountry = contactCountry;
        if (requiredFields.includes('communityAccessStatus')) jsonTemplate.communityAccessStatus = communityAccessStatus;
        if (requiredFields.includes('communityAccessRole')) jsonTemplate.accessRole = accessRole;
        if (requiredFields.includes('title')) jsonTemplate.title = title;
        if (requiredFields.includes('operatingCountry')) jsonTemplate.operatingCountry = operatingCountry;
        if (requiredFields.includes('clientName')) jsonTemplate.clientName = clientName;

        if (this.customFields) {
            const customFieldMap = JSON.parse(`{${this.customFields}}`);
            Object.assign(jsonTemplate, customFieldMap);
        }

        return jsonTemplate;
    }
}