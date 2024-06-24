/**
 * 
 * @description Model Class to Convert link to Format Manage by Lightning Componenets
 * @author Maham Hasan
 * @since 
 */
public with sharing class DenormalizedLink {
    @AuraEnabled
    public String id;
    @AuraEnabled
    public String name;
    @AuraEnabled
    public String guestUrl;
    @AuraEnabled
    public String desktopUrl;
    @AuraEnabled
    public String mobileUrl;
    @AuraEnabled
    public Boolean isOnline;
    @AuraEnabled
    public Boolean isPublished;
    @AuraEnabled
    public DateTime publishedFrom;
    @AuraEnabled
    public DateTime publishedUntil;
    @AuraEnabled
    public String type;
    @AuraEnabled
    public String favModalText;
    @AuraEnabled
    public String iconUrl;
    @AuraEnabled
    public String countryTagId;


    /**
     * 
     * @description Constructor for Denormalized Link
     */
    public DenormalizedLink() { }
}