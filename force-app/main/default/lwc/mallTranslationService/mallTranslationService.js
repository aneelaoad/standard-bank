import getCustomLabels from '@salesforce/apex/MallCustomLabelsController.getCustomLabels';
import { mallStateName, getUserState } from 'c/sbgUserStateUtils';
import DEFAULT_MALL_LANGUAGE_ISO from '@salesforce/label/c.DEFAULT_MALL_LANGUAGE_ISO';

export class MallTranslationService {
    labels = [];
    customLabels = {};

    static _instance;
    static _labelsLoaded = false;
    static _customLabels = {};

    //returns the singleton instance of the custom labels class
    static getInstance() {
        if(!MallTranslationService._instance) {
            MallTranslationService._instance = new MallTranslationService(); 
        }
        return MallTranslationService._instance;
    }

    async getTranslatedLabels() {
        try {
            if(!MallTranslationService._labelsLoaded) {
                const labels = await getCustomLabels();
                MallTranslationService._customLabels = this.processCustomLabels(labels);
                MallTranslationService. _labelsLoaded = true;
            } 
            return MallTranslationService._customLabels;
        } catch (error) {
            this.error = error;
        }
    }

    processCustomLabels(labels) {
        let customLabels = {};
        for(let row=0; row < labels.length; row++) {
            let label = {};
            label.labelName = labels[row].Label;
            label.developerName = labels[row].DeveloperName;
            label.translation = labels[row].Translation__c;
            label.language = labels[row].Language__c;
            label.id = labels[row].Id;
            let key = label.developerName;
            let language = label.language;
            language = language.replace('-','_');
            //SBG_Navigation_Item__c Metadata relationship
            if(labels[row].SBG_Navigation_Item__c) {
                label.headerId = labels[row].SBG_Navigation_Item__c;
                key = label.headerId + '_' + language.toUpperCase();
            }
            //SBG_Footer_Item__c Metadata relationship
            if(labels[row].SBG_Footer_Item__c) {
                label.footerId = labels[row].SBG_Footer_Item__c;
                key = label.footerId + '_' + language.toUpperCase();
            }
            customLabels[key] = label;
        }
        this.customLabels = {...customLabels};
        return this.customLabels;
    }

    //to get the language formatted
    getFormattedLanguage() {
        let mallUserSelectedLanguageISOCode = getUserState(mallStateName.mallUserSelectedLanguageISOCode, DEFAULT_MALL_LANGUAGE_ISO); 
        let mallUserLanguage = mallUserSelectedLanguageISOCode.replace('-','_');
        let formattedLanguageName = mallUserLanguage.toUpperCase();
        return formattedLanguageName; 
    }

    //get the custom labels by name
    getTranslatedLabelByLabelName(labelName) {
        let developerName = labelName + '_' + getFormattedLanguage();
        let value = '';
        if(MallTranslationService._customLabels && MallTranslationService._customLabels[developerName]) {
            value = MallTranslationService._customLabels[developerName].translation;
        }
        return value;
    }

    getTranslatedLabelByMetadataId(navItemId) {
        let key = navItemId.slice(0,15) + '_' + getFormattedLanguage();
        let value = '';
        if(MallTranslationService._customLabels[key]) {
          value = MallTranslationService._customLabels[key].translation;
        } 
        return value;
    }
}  

function getFormattedLanguage() {
    let mallUserSelectedLanguageISOCode = getUserState(mallStateName.mallUserSelectedLanguageISOCode, DEFAULT_MALL_LANGUAGE_ISO); 
    let mallUserLanguage = mallUserSelectedLanguageISOCode.replace('-','_');
    let formattedLanguageName = mallUserLanguage.toUpperCase();
    return formattedLanguageName; 
}

export function getTranslatedLabelByLabelName(labelName, customLabels) {
    let developerName = labelName + '_' + getFormattedLanguage();
    let value = '';
    if(customLabels && customLabels[developerName]) {
        value = customLabels[developerName].translation;
    }
    return value;
}

export function getTranslatedLabelByMetadataId(navItemId, customLabels) {
    let key = navItemId.slice(0,15) + '_' + getFormattedLanguage();
    let value = '';
    if(customLabels[key]) {
      value = customLabels[key].translation;
    } 
    return value;
}