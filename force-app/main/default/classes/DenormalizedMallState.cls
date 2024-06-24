/**
 * 
 * @description Model Class to Store the Current Mall State Manage by Lightning Componenets
 * @author Maham Hasan
 * @since 
 */
public with sharing class DenormalizedMallState {
   @AuraEnabled
   public List<DenormalizedTag> segments;
   @AuraEnabled
   public List<DenormalizedTag> solutions;
   @AuraEnabled
   public List<DenormalizedTag> categories;
   @AuraEnabled
   public List<DenormalizedShop> shops;
   @AuraEnabled
   public List<DenormalizedProduct> products;   
   @AuraEnabled
   public List<DenormalizedProduct> services;   
   @AuraEnabled
   public List<DenormalizedProduct> guidedSolutions;  
   @AuraEnabled
   public List<DenormalizedPromotion> promotions;
   @AuraEnabled
   public List<DenormalizedEvent> events;
   @AuraEnabled
   public Boolean mallMultiLanguageContent;

   /**
    * @description Constructor for Denormalized Mall State
    */
   public DenormalizedMallState() { }
}