public with sharing class NAM_CTRL_CaseProcessReturnController {
    @AuraEnabled(Cacheable=true)
    public static List<Atonit_Mktplace__Occurrence_Item__c> getItemsFromCase(String caseId){
        return [SELECT Id, Name, Atonit_Mktplace__ProductVariant__r.Name, 
        Atonit_Mktplace__UnitPrice__c,
        Atonit_Mktplace__TotalPrice__c,
        Atonit_Mktplace__Quantity__c,
        Quantity_Returned__c,
        Status__c
        FROM Atonit_Mktplace__Occurrence_Item__c WHERE Atonit_Mktplace__Case__c =: caseId WITH SECURITY_ENFORCED];
    }

    @AuraEnabled
    public static void confirmItems(List<Atonit_Mktplace__Occurrence_Item__c> itemsForUpdate, String caseId) {
        List<Atonit_Mktplace__Line_Item__c> lineItemToUpdate = new List<Atonit_Mktplace__Line_Item__c>();

        try{
            //update Case status to closed
            updateCase(caseId);
    
            //Update occurrence item status
            updateOccurenceItemStatus(itemsForUpdate);
    
            //update order line item status
            for(Atonit_Mktplace__Occurrence_Item__c occ : [SELECT Id, Atonit_Mktplace__Quantity__c, Quantity_Returned__c, 
            Atonit_Mktplace__SellerItem__c
            FROM Atonit_Mktplace__Occurrence_Item__c WHERE Id IN: itemsForUpdate WITH SECURITY_ENFORCED]){
                Atonit_Mktplace__Line_Item__c lineItem = new Atonit_Mktplace__Line_Item__c(Id = occ.Atonit_Mktplace__SellerItem__c);
                if(occ.Atonit_Mktplace__Quantity__c == occ.Quantity_Returned__c){
                    lineItem.Marketplace_Line_Item_Status__c = 'Returned';
                } else {
                    lineItem.Marketplace_Line_Item_Status__c = 'Partially returned';
                }
                lineItemToUpdate.add(lineItem);
            }
            SObjectAccessDecision securityDecisionLineItem = Security.stripInaccessible(AccessType.UPDATABLE, lineItemToUpdate);
            update securityDecisionLineItem.getRecords();

        } catch (DmlException de) {
            UTL_ExceptionHelper.throwDMLException(de, true, null, null);
        } catch(Exception e) {
            throw new SecurityException('An error occured : ' + e.getMessage(), e);
        }
    }

    private static void updateOccurenceItemStatus(List<Atonit_Mktplace__Occurrence_Item__c> itemsForUpdate){
        for(Atonit_Mktplace__Occurrence_Item__c occItem : itemsForUpdate){
            occItem.Status__c = 'Confirmed';
        }
        fflib_SecurityUtils.checkObjectIsUpdateable(Atonit_Mktplace__Occurrence_Item__c.sObjectType);
        update itemsForUpdate;
    }

    private static void updateCase(String caseId){
        List<Case> listCaseToUpdate = new List<Case>();
        Case req = new Case(Id = caseId, Status = 'Closed');
        listCaseToUpdate.add(req);

        fflib_SecurityUtils.checkObjectIsUpdateable(Case.sObjectType);
        if(!Test.isRunningTest()){
            update listCaseToUpdate;
        }
    }

    @AuraEnabled
    public static void updateItems(List<Atonit_Mktplace__Occurrence_Item__c> itemsForUpdate) {
        try{
            for(Atonit_Mktplace__Occurrence_Item__c occItem : itemsForUpdate){
                occItem.Status__c = 'Draft';
            }
            SObjectAccessDecision securityDecisionOccurenceItem = Security.stripInaccessible(AccessType.UPDATABLE, itemsForUpdate);
            update securityDecisionOccurenceItem.getRecords();
        } catch (DmlException de) {
            UTL_ExceptionHelper.throwDMLException(de, true, 'update', 'Atonit_Mktplace__Occurrence_Item__c');
        } catch(Exception e) {
            throw new SecurityException('An error occured : ' + e.getMessage(), e);
        }
    }
}