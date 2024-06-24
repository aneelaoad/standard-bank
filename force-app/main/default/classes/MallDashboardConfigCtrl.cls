/**
 * 
 * @description MallDashboardConfigCtrl
 * @author Ankit Kumar
 * @since 
 */
public with sharing class MallDashboardConfigCtrl {
    /**
     * 
     * @description getConfiguredDashboardWidgets
     * @return List<Mall_Dashboard_Configuration__mdt>
     */
    @AuraEnabled
    public static List<Mall_Dashboard_Configuration__mdt> getConfiguredDashboardWidgets(){
        try {
            return Mall_Dashboard_Configuration__mdt.getAll().values();
        } catch (Exception e) {
            throw MallExceptionUtil.throwAuraException('MallDashboardConfigCtrl.getConfiguredDashboardWidgets', e);
        }
    }

    /**
     * 
     * @description getSavedDashboardWidgetConfigurations
     * @return List<Mall_Dashboard_Widget__c>
     */
    @AuraEnabled
    public static List<Mall_Dashboard_Widget__c> getSavedDashboardWidgetConfigurations() {
        try {
            return SEL_MallDashboardWidgets.newInstance().selectByUserIds(new Set<Id>{(Id)UserInfo.getUserId()});
        } catch (Exception e) {
            throw MallExceptionUtil.throwAuraException('MallDashboardConfigCtrl.getSavedDashboardWidgetConfigurations', e);
        }
    }

    /**
     * 
     * @description saveDashboardWidgetConfigurations
     * @param widgets List<Mall_Dashboard_Widget__c>
     */
    @AuraEnabled
    public static void saveDashboardWidgetConfigurations (List<Mall_Dashboard_Widget__c> widgets) {
        try {
            String userId = UserInfo.getUserId();
            List<String> savedWidgetNames = new List<String>();
            Map<String,Mall_Dashboard_Widget__c> idVsWidgetMap = new Map<String,Mall_Dashboard_Widget__c>();
            for(Mall_Dashboard_Widget__c widget: widgets) {
                savedWidgetNames.add(widget.Name);
            }

            List<Mall_Dashboard_Widget__c> storedWidgets = SEL_MallDashboardWidgets.newInstance().selectByUserIds(new Set<Id>{(Id)userId});
            List<Mall_Dashboard_Widget__c> widgetsToBeDeleted = new List<Mall_Dashboard_Widget__c>();
            List<String> toBeDeletedWidgetNames = new List<String>();
            List<Mall_Dashboard_Widget__c> widgetsToBeUpdated = new List<Mall_Dashboard_Widget__c>();
            List<Mall_Dashboard_Widget__c> widgetsToBeInserted = new List<Mall_Dashboard_Widget__c>();
            List<String> toBeUpdatedWidgetNames = new List<String>();

            for(Mall_Dashboard_Widget__c storedWidget: storedWidgets) {
                if(!savedWidgetNames.contains(storedWidget.Name)) {
                    widgetsToBeDeleted.add(storedWidget);
                    toBeDeletedWidgetNames.add(storedWidget.Name);
                } else {
                    toBeUpdatedWidgetNames.add(storedWidget.Name);
                    idVsWidgetMap.put(storedWidget.Name, storedWidget);
                }
            }

            for(Mall_Dashboard_Widget__c widget : widgets) {
                //Update
                if(!toBeDeletedWidgetNames.contains(widget.Name) && toBeUpdatedWidgetNames.contains(widget.Name)) {
                    widget.Id = idVsWidgetMap.get(widget.Name).Id;
                    widgetsToBeUpdated.add(widget);
                } else if(!toBeDeletedWidgetNames.contains(widget.Name) && !toBeUpdatedWidgetNames.contains(widget.Name)){
                    widgetsToBeInserted.add(widget);
                } 
            }

            if(!widgetsToBeInserted.isEmpty()) {
                insert widgetsToBeInserted;
            }
            if(!widgetsToBeUpdated.isEmpty()) {
                update widgetsToBeUpdated;
            }
            if(!widgetsToBeDeleted.isEmpty()) {
                delete widgetsToBeDeleted;
            }
        } catch (Exception e) {
            throw MallExceptionUtil.throwAuraException('MallDashboardConfigCtrl.saveDashboardWidgetConfigurations', e);
        }
    }
}