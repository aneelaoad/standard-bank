import getCustomLabels from '@salesforce/apex/MallCustomLabelsController.getCustomLabels';
import { mallStateName, getUserState } from 'c/sbgUserStateUtils';

const DEFAULT_MALL_LANGUAGE_ISO = 'en';

export class MallCustomLabels {
    labels = [];
    customLabels = {};

    async fetchCustomLabels() {
        try {
            let labels = await getCustomLabels();
            this.labels = [...labels];
            this.customLabels = this.processCustomLabels(this.labels);
            return this.customLabels;
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
}  

function getFormattedLanguage() {
    let mallUserSelectedLanguageISOCode = getUserState(mallStateName.mallUserSelectedLanguageISOCode, DEFAULT_MALL_LANGUAGE_ISO); 
    let mallUserLanguage = mallUserSelectedLanguageISOCode.replace('-','_');
    let formattedLanguageName = mallUserLanguage.toUpperCase();
    return formattedLanguageName; 
}

export function getCustomLabelByLabelName(labelName, customLabels) {
    let developerName = labelName + '_' + getFormattedLanguage();
    let value = '';
    if(customLabels && customLabels[developerName]) {
        value = customLabels[developerName].translation;
    }
    return value;
}

export function getCustomLabelByMetadataId(navItemId, customLabels) {
    let key = navItemId.slice(0,15) + '_' + getFormattedLanguage();
    let value = '';
    if(customLabels[key]) {
      value = customLabels[key].translation;
    } 
    return value;
}