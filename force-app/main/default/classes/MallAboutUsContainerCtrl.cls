/**
 * 
 * @description MallAboutUsContainerCtrl
 * @author Ankit Kumar
 * @since 
 */
public with sharing class MallAboutUsContainerCtrl {
    /**
     * 
     * @description getAboutUsValuePropositions
     * @return List<Mall_About_Us_Value_Proposition__mdt>
     */
    @AuraEnabled
    public static List<Mall_About_Us_Value_Proposition__mdt> getAboutUsValuePropositions(){
        return Mall_About_Us_Value_Proposition__mdt.getAll().values();
    }
}