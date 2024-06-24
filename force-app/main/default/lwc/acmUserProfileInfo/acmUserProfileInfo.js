import { LightningElement, track, wire } from 'lwc';
import Id from '@salesforce/user/Id';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';
import getUserDetail from '@salesforce/apex/AcmUserProfileInfoController.getUserDetail';
import updateUserDetail from '@salesforce/apex/AcmUserProfileInfoController.updateUserDetail';

export default class AcmUserProfileInfo extends NavigationMixin(LightningElement) {
    userId = Id;
    @track userDetail = {
        Id: Id,
        FirstName: '',
        LastName: '',
        CompanyName: '',
        Title: '',
        Email: '',
        MobilePhone: '',
        CommunityNickname: ''
    };
    error;

    @wire(getUserDetail, {userId: '$userId'}) 
    wireUserDetail({error, data}) {
        if (data) {
            this.userDetail = Object.assign(this.userDetail, data);
        } else if (error) {
            this.showNotification('Failed', error.body.message, 'error');
        }
    }

    handleChange(event) {
        this.userDetail[event.target.name] = event.target.value;
    }

    handleSubmit() {
        this.template.querySelector('.siteforceLoadingBalls.loadingCon').classList.remove('hideEl');
        updateUserDetail({ userDetail: this.userDetail })
        .then((result) => {
            if(result) {
                this.template.querySelector('.siteforceLoadingBalls.loadingCon').classList.add('hideEl');
                this.showNotification('Success', 'You have successfully updated the profile!', 'success');
            } else {
                this.showNotification('failed', result, 'error');
            }
        })
        .catch((error) => {
            this.template.querySelector('.siteforceLoadingBalls.loadingCon').classList.add('hideEl');
            this.showNotification('Failed', error.body.message, 'error');
        });
    }

    handleCancel() {
        this[NavigationMixin.Navigate]({
            type: 'standard__webPage',
            attributes: {
                url: '/'
            }
        },
        true // Replaces the current page in your browser history with the URL
      );
    }
    showNotification(title, message, variant) {
        const evt = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
        });
        this.dispatchEvent(evt);
    }
}