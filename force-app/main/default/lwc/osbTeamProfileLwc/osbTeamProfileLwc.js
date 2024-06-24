import { LightningElement } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import OSB_iconEmail from '@salesforce/resourceUrl/OSB_iconEmail';
import OSB_Images_Two from '@salesforce/resourceUrl/OSB_Images_Two';
import getTeamContacts from '@salesforce/apex/OSB_TeamProfile_Ctrl.getTeamContacts';
import createLightContact from '@salesforce/apex/OSB_TeamProfile_Ctrl.createLightContact';
import resendUserInviteLink from '@salesforce/apex/OSB_TeamProfile_Ctrl.resendUserInviteLink';
import declineNewUserAccess from '@salesforce/apex/OSB_TeamProfile_Ctrl.declineNewUserAccess';
import deactivateUserOneHubAccessApex from '@salesforce/apex/OSB_TeamProfile_Ctrl.deactivateUserOneHubAccessApex';
import {
    interactionForm,
    addAnalyticsInteractions
} from 'c/osbAdobeAnalyticsWrapperLwc';

export default class OsbTeamProfileLwc extends NavigationMixin(
    LightningElement
) {
    Logo = OSB_iconEmail + '/OSB_iconEmail/ms-icn.png';
    Logo1 = OSB_iconEmail + '/OSB_iconEmail/ms-icn-people.png';
    Logo2 = OSB_iconEmail + '/OSB_iconEmail/ms-icn-tick.png';
    ReadMore = OSB_Images_Two + '/ReadMoreArrow.svg';
    isError = false;
    contactId;
    designation;
    selectedNavItem;
    accessLevel = false;
    userMap = null;
    section = 'Invite_Members';
    name;
    checked = false;
    numberOfInvites = [1];
    ExampleNumberOFInvites = [];
    sentInvite = [];
    teamDetails = [];
    btnResendInvite;
    NumSent = 0;
    contactArray = [];
    rows = [{ firstName: '', surname: '', email: '' }];
    description;
    reasonForPopup;
    contactsList = [];
    titleForPopup;
    contentForPopup;
    clickedButton;
    disclaimer;
    emailPattern;
    showInviteSection = true;
    caseCreated = false;
    showLoading = false;
    showTeamDetails = false;
    sentInviteLength = false;
    showToastFailure = false;
    showToastSuccess = false;
    teamDetailsLength = false;
    showMarketgramPopup = false;
    showPendingApprovals = false;
    pendingApprovals = [];
    pendingApprovalsLength = false;
    clickedButtonID;
    toastMessage;
    toastType = 'success';
    LightContactData = false;
    isValidVal;
    response;
    declineUser;
    showAddRow = false;
    showAddButtons = false;
    resendUserInvite;
    deactivateUser;
    approveUser;
    newContact = {
        sobjectType: 'Contact'
    };

    newCase = {
        sobjectType: 'Case'
    };

    formStartedValue = false;
    eventValues = {
        name: 'globalFormStart',
        formName: 'invite team members',
        formStatus: '',
        formisSubmitted: 'false'
    };

    renderedCallback() {
        addAnalyticsInteractions(this.template);
    }

    disconnectedCallback() {
        if (this.formStartedValue) {
            let event = this.eventValues;
            event.name = 'globalFormAbandon';
            event.formStatus = 'abandon';
            event.formisSubmitted = false;
            this.setInitalAdobeFields();
        }
    }

    firstFormSubmit() {
        if (!this.formStartedValue) {
            this.formStartedValue = true;
            this.setInitalAdobeFields();
        }
    }

    addRow() {
        this.rows = [...this.rows, { name: '', surname: '', email: '' }];
    }

    connectedCallback() {
        this.showLoading = true;
        this.EmailPattern =
            '^[a-zA-Z0-9._|\\\\%#~`=?&/$^*!}{+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,4}$';
        this.disclaimer =
            "By deactivating a team member profile, this means the team member won't be able to sign in " +
            '<br>and access OneHub as well as any solution they have signed up for through OneHub.' +
            '<br>' +
            '<br>If you require any changes or updates to your team details, please email us at' +
            "<br><b><p style='color:#0089FF;'>onehub@standardbank.co.za.</p></b>";

        getTeamContacts()
            .then((result) => {
                this.response = result;
                let responseList = [];
                let inviteSentList = [];
                let pendingApp = [];
                let approvedUsers = [];
                this.showLoading = false;
                responseList = this.response.teamInvitesSent;
                responseList.forEach(function (item, index) {
                    if (item.OSB_Community_Access_Status__c === 'Invite Sent') {
                        item.unqiueValue = 'Invite ' + index;
                        inviteSentList.push(item);
                    } else if (
                        item.OSB_Community_Access_Status__c ===
                        'Pending Approval'
                    ) {
                        item.unqiueValue = 'Pending ' + index;
                        pendingApp.push(item);
                    } else if (
                        item.OSB_Community_Access_Status__c === 'Approved'
                    ) {
                        let designationRole =
                            item.OSB_Community_Access_Role__c.toLowerCase();
                        if (
                            designationRole === 'designated person' ||
                            designationRole === 'nominated person'
                        ) {
                            item.unqiueValue = 'Approved ' + index;
                            approvedUsers.push(item);
                        }
                        item.OSB_Community_Access_Role__c =
                            designationRole.charAt(0).toUpperCase() +
                            designationRole.slice(1);
                    }
                });

                let primaryContact = this.response.primaryContact;
                this.designation =
                    primaryContact.OSB_Community_Access_Role__c.toLowerCase();
                if (
                    primaryContact.OSB_Community_Access_Role__c ===
                    'Authorised Person'
                ) {
                    this.accessLevel = true;
                }
                if (!primaryContact.OSB_Team_Profile_Onboarding_Tour_Date__c) {
                    this.contactId = primaryContact.Id;
                }
                this.pendingApprovals = pendingApp;
                this.sentInvite = inviteSentList;
                this.teamDetails = approvedUsers;

                if (inviteSentList.length > 0) {
                    this.sentInviteLength = true;
                } else {
                    this.sentInviteLength = false;
                }
                if (pendingApp.length > 0) {
                    this.pendingApprovalsLength = true;
                } else {
                    this.pendingApprovalsLength = false;
                }
                if (approvedUsers.length > 0) {
                    this.teamDetailsLength = true;
                } else {
                    this.teamDetailsLength = false;
                }
            })
            .catch((error) => {
                this.error = error;
            });
    }

    validateOnChange() {
        var isValid = true;

        let fieldErrorMsg = 'Please enter the';
        this.template.querySelectorAll('lightning-input').forEach((item) => {
            let fieldValue = item.value;
            let fieldLabel = item.label;

            if (!fieldValue) {
                item.setCustomValidity(fieldErrorMsg + ' ' + fieldLabel);
                item.reportValidity();
                isValid = false;
            } else {
                item.setCustomValidity('');
            }
        });
        return isValid;
    }

    sendInvite(event) {
        event.preventDefault();
        let isValid = true;
        let fieldErrorMsg = 'Please enter the';
        this.template.querySelectorAll('lightning-input').forEach((item) => {
            let fieldValue = item.value;
            let fieldName = item.name;
            let fieldLabel = item.label;
            if (!fieldValue) {
                item.setCustomValidity(fieldErrorMsg + ' ' + fieldLabel);
                item.reportValidity();
                isValid = false;
            } else if (fieldName === 'firstName' || fieldName === 'surname') {
                if (!fieldValue.match(/^[a-zA-Z' -]+$/)) {
                    item.setCustomValidity(
                        'The ' +
                            fieldLabel +
                            ' entered contains invalid characters.'
                    );
                    item.reportValidity();
                    isValid = false;
                    this.showToastFailure = true;
                } else {
                    item.setCustomValidity('');
                }
            } else if (fieldName === 'email') {
                if (!fieldValue.match(/^[^@ ]+@[^@ ]+\.[^@ \.]+$/)) {
                    item.setCustomValidity(
                        'It seems an entered ' +
                            fieldLabel +
                            ' address is not valid. Please review and try again!'
                    );
                    item.reportValidity();
                    isValid = false;
                } else {
                    item.setCustomValidity('');
                }
            } else {
                item.setCustomValidity('');
            }
            return isValid;
        });

        if (!isValid) {
            window.scrollTo(0, 0);
            this.toastMessage =
                'Please correct any errors on the form and try again.';
            this.showToastFailure = true;
        } else {
            let contactArray = this.contactsList;
            let DataArray = [];
            let numOfInvites = this.rows;
            let emailNameArray =
                this.template.querySelectorAll('[data-id="Email"]');

            let FirstNameArray = this.template.querySelectorAll(
                '[data-id="FirstName"]'
            );
            let LastNameArray = this.template.querySelectorAll(
                '[data-id="LastName"]'
            );
            let access = this.accessLevel;
            let toggleArray = [];
            if (this.accessLevel) {
                toggleArray =
                    this.template.querySelectorAll('[data-id="toggle"]');
            }
            for (let i = 0; i < numOfInvites.length; i++) {
                let persona;
                let emailValueBefore = emailNameArray[i].value.trim();
                let FirstNameArrayBefore = FirstNameArray[i].value.trim();
                let LastNameArrayBefore = LastNameArray[i].value.trim();
                if (
                    emailValueBefore ||
                    FirstNameArrayBefore ||
                    LastNameArrayBefore
                ) {
                    if (access) {
                        let inviteOthers = toggleArray[i].checked;
                        if (inviteOthers) {
                            persona = 'Designated person';
                        } else {
                            persona = 'Nominated person';
                        }
                    } else {
                        persona = 'Nominated person';
                    }
                    let dataLine = {
                        ArrayLine: i,
                        EmailValue: emailNameArray[i],
                        FirstName: FirstNameArray[i],
                        LastName: LastNameArray[i],
                        role: persona
                    };
                    DataArray.push(dataLine);
                }
            }
            if (DataArray.length > 0) {
                let isValidArray = false;
                DataArray.forEach((element) => {
                    let firstNameValue = element.FirstName.value.trim();
                    let lastNameValue = element.LastName.value.trim();
                    let emailValue = element.EmailValue.value.trim();
                    let roleValue = element.role;
                    if (
                        firstNameValue &&
                        lastNameValue &&
                        emailValue &&
                        roleValue
                    ) {
                        isValidArray = true;
                    }
                    contactArray.push({
                        sobjectType: 'Contact',
                        FirstName: firstNameValue,
                        LastName: lastNameValue,
                        Email: emailValue,
                        OSB_Community_Access_Role__c: roleValue
                    });
                });
                if (isValidArray) {
                    this.createLightContacts(contactArray);
                    contactArray = [];
                }
            } else {
                window.scrollTo(0, 0);
                this.toastMessage =
                    'You will need to enter at least one entry below in order to send an invite';
                this.showToastFailure = true;
            }
        }
    }

    createLightContacts(contactArray) {
        this.showLoading = true;
        createLightContact({
            inviteList: contactArray
        })
            .then((result) => {
                if (result) {
                    this.LightContactData = result;
                    this.showLoading = false;

                    let event = this.eventValues;
                    event.name = 'globalFormComplete';
                    event.formStatus = 'complete';
                    event.formisSubmitted = true;
                    this.setInitalAdobeFields();
                    this.updateRecordView();

                    this.toastMessage = 'Invite successfuly sent.';
                    this.showToastSuccess = true;
                } else {
                    this.toastMessage =
                        'It seems we can not send your invites out right now. Please try again later.';
                    this.showToastFailure = true;
                }
            })
            .catch((error) => {
                this.showLoading = false;
                this.error = error;
                this.toastMessage =
                    'It seems we can not send your invites out right now. Please try again later.';
                this.showToastFailure = true;
            });
    }

    addAnother() {
        let numOfInvites = this.numberOfInvites;
        let num = numOfInvites[numOfInvites.length - 1];
        let integer = parseInt(num, 10);
        numOfInvites.push(integer + 1);
        this.numberOfInvites = numOfInvites;
    }

    stopSpecialChars(event) {
        let regex = /[a-zA-Z- ']+$/;
        let key = String.fromCharCode(
            !event.charCode ? event.which : event.charCode
        );
        if (!regex.test(key)) {
            event.preventDefault();
            return false;
        }
    }

    cancel(e) {
        e.preventDefault();
        this.reasonForPopup = 'Cancel Invite';
        this.titleForPopup = 'Cancel request?';
        this.contentForPopup =
            'By doing so you will clear the form to it’s original state.';
        this.showMarketgramPopup = true;
    }

    handleNavItemChange(event) {
        let section = event.currentTarget.dataset.tabName;
        this.showInviteSection = false;
        this.showPendingApprovals = false;
        this.showTeamDetails = false;
        if (section === 'Invite team members') {
            this.showInviteSection = true;
        } else if (section === 'Pending approvals') {
            this.showPendingApprovals = true;
        } else if (section === 'Team details') {
            this.showTeamDetails = true;
        }
    }

    declineOHAccessPopup(event) {
        this.reasonForPopup = 'declineOneSpaceAccess';
        this.titleForPopup = 'Decline access?';
        this.contentForPopup =
            "You are about to decline someone's access. Do you want to continue?";
        this.clickedButtonID = event.target.getAttribute('data-id');
        this.showMarketgramPopup = true;
    }

    resendOHInvitePopup(event) {
        this.reasonForPopup = 'resendOneSpaceInvite';
        this.titleForPopup = 'Resend invite';
        this.contentForPopup =
            'You are about to resend and invite. Would still like to do so?';
        this.clickedButtonID = event.target.getAttribute('data-id');
        this.showMarketgramPopup = true;
    }

    deactivateUserOHAccessPopup(event) {
        this.reasonForPopup = 'deactivateUserOneHubAccess';
        this.titleForPopup = 'Deactivate profile?';
        this.contentForPopup =
            "You are about to deactivate someone's profile. Do you want to continue?";
        this.clickedButtonID = event.target.getAttribute('data-id');
        this.showMarketgramPopup = true;
    }
    declineOneSpaceAccess(contactId) {
        this.showLoading = true;
        declineNewUserAccess({
            contactId: contactId
        })
            .then((result) => {
                this.declineUser = result;
                this.showLoading = false;
                this.toastMessage =
                    'Team member access has been declined successfully.';
                this.showToastFailure = false;
                this.showToastSuccess = true;
                window.location.reload();
            })
            .catch((error) => {
                this.showLoading = false;
                this.error = error;
                this.toastMessage =
                    'It seems there was a problem in declining an invite. Please try again later.';
                this.showToastSuccess = false;
                this.showToastFailure = true;
            });
    }

    deactivateUserOneHubAccess(contactId) {
        this.showLoading = true;
        deactivateUserOneHubAccessApex({
            contactId: contactId
        })
            .then((result) => {
                this.deactivateUser = result;
                this.showLoading = false;
                this.toastMessage =
                    'You have successfully deactivated a team members profile.';
                this.showToastSuccess = true;
                window.location.reload();
            })
            .catch((error) => {
                this.showLoading = false;
                this.error = error;
                this.toastMessage =
                    'It seems there was a problem in deactivating a team member. Please try again later.';
                this.showToastSuccess = false;
                this.showToastFailure = true;
            });
    }

    resendOneSpaceInvite(contactId) {
        this.showLoading = true;
        resendUserInviteLink({
            contactId: contactId
        })
            .then((result) => {
                this.resendUserInvite = result;
                this.showLoading = false;
                this.toastMessage = 'Team invite resent successfully';
                this.showToastSuccess = true;
                window.location.reload();
            })
            .catch((error) => {
                this.showLoading = false;
                this.error = error;
                this.toastMessage =
                    'It seems there was a problem in resending an invite. Please try again later.';
                this.showToastFailure = true;
            });
    }

    handleCloseEvent(event) {
        event.preventDefault();
        let optionSelected = event.detail;
        if (optionSelected === 'YES') {
            let reasonForPopup = this.reasonForPopup;
            if (reasonForPopup === 'Cancel Invite') {
                this.template.querySelector('form').reset();
                this.updateRecordView();
            }
            let contactId = this.template.querySelector(
                '[data-id="' + this.clickedButtonID + '"]'
            ).value;
            if (reasonForPopup === 'resendOneSpaceInvite') {
                this.resendOneSpaceInvite(contactId);
            } else if (reasonForPopup === 'approveOneSpaceAccess') {
                this.approveOneSpaceAccess(contactId);
            } else if (reasonForPopup === 'declineOneSpaceAccess') {
                this.declineOneSpaceAccess(contactId);
            } else if (reasonForPopup === 'deactivateUserOneHubAccess') {
                this.deactivateUserOneHubAccess(contactId);
            }
            this.showMarketgramPopup = false;
        } else {
            this.showMarketgramPopup = false;
        }
    }

    setInitalAdobeFields() {
        interactionForm(this.eventValues);
    }

    updateRecordView() {
        eval("$A.get('e.force:refreshView').fire();");
    }
}