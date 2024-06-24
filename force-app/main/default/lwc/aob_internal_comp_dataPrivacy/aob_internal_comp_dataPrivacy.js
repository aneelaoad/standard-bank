/**
 * @description       : Displays privacy statements
 * @author            : Mahlatse Tjale
 * @last modified on  : 07-20-2023
 * @last modified by  : Mahlatse Tjale
 * Modifications Log
 * Ver   Date         Author           Modification
 * 1.0   07-20-2023   Mahlatse Tjale   Initial Version
**/

import { LightningElement } from 'lwc';
import AOB_ZA_PleasebeAdvisedThat from '@salesforce/label/c.AOB_ZA_PleasebeAdvisedThat';
import AOB_ZA_WillProcessYourPersonal from '@salesforce/label/c.AOB_ZA_WillProcessYourPersonal';
import AOB_ZA_ThisIncludesAllSubsidiaries from '@salesforce/label/c.AOB_ZA_ThisIncludesAllSubsidiaries';
import AOB_ZA_OurPrivacyStatementINformsYou from '@salesforce/label/c.AOB_ZA_OurPrivacyStatementINformsYou';
import AOB_ZA_ANDUponRequestFromOurBranch from '@salesforce/label/c.AOB_ZA_ANDUponRequestFromOurBranch';
import AOB_ZA_SeeMore from '@salesforce/label/c.AOB_ZA_SeeMore';
import PBP_ZA_Standardbankcomurl from '@salesforce/label/c.PBP_ZA_Standardbankcomurl';
import PBP_ZA_StandardBankUrl from '@salesforce/label/c.PBP_ZA_StandardBankUrl';
import AOB_ZA_SBURL from '@salesforce/label/c.AOB_ZA_SBURL';

import 	AOB_ZA_STAFF_WeUnderstandThat from '@salesforce/label/c.AOB_ZA_STAFF_WeUnderstandThat';
import 	AOB_ZA_STAFF_ItIsYourResponsibility from '@salesforce/label/c.AOB_ZA_STAFF_ItIsYourResponsibility';
import 	AOB_ZA_STAFF_EmailToYou from '@salesforce/label/c.AOB_ZA_STAFF_EmailToYou';
import 	AOB_ZA_STAFF_WeWillMaintain from '@salesforce/label/c.AOB_ZA_STAFF_WeWillMaintain';
import 	AOB_ZA_STAFF_OurPrivacyStatement from '@salesforce/label/c.AOB_ZA_STAFF_OurPrivacyStatement';
import 	AOB_ZA_STAFF_ICanConfirm from '@salesforce/label/c.AOB_ZA_STAFF_ICanConfirm';






export default class Aob_internal_comp_dataPrivacy extends LightningElement {
    label={
        AOB_ZA_PleasebeAdvisedThat,
        AOB_ZA_WillProcessYourPersonal,
        AOB_ZA_ThisIncludesAllSubsidiaries,
        AOB_ZA_OurPrivacyStatementINformsYou,
        AOB_ZA_ANDUponRequestFromOurBranch,
        AOB_ZA_SeeMore,
        AOB_ZA_SBURL,
        AOB_ZA_STAFF_WeUnderstandThat,
        AOB_ZA_STAFF_ItIsYourResponsibility,
        AOB_ZA_STAFF_EmailToYou,
        AOB_ZA_STAFF_WeWillMaintain,
        AOB_ZA_STAFF_OurPrivacyStatement,
        AOB_ZA_STAFF_ICanConfirm
    };
    standardbankGroupLink = PBP_ZA_Standardbankcomurl + '/sbg/standard-bank-group/who-we-are/our-structure';
    standardbankPrivacyLink = PBP_ZA_StandardBankUrl + '/privacy';
    isEventFired;
    showMore = false;

    adobePageTag = {
        dataId: "link_content",
        dataIntent: "navigational",
        seemoreintent:"informational",
        dataScope: "mymobiz application",
        standardbanklinkclick: "pre application | data privacy | standard bank link click",
        seemorelinkclick: "pre application | data privacy | see more link click",
        standardbankurlclick:"pre application | data privacy | standard bank url click",
    }


     showMoreText() {
        this.showMore = true;
    }

    showLessText(){
        this.showMore = false;
    }
    connectedCallback() {
    }
   
}