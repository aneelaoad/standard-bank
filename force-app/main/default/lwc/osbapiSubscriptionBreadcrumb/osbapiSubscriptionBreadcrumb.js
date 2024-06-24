import { api, LightningElement, wire } from 'lwc';
import { NavigationMixin, CurrentPageReference } from 'lightning/navigation';

export default class OsbapiSubscriptionBreadcrumb extends NavigationMixin(
    LightningElement
) {
    @api recordId;

    name;

    @wire(CurrentPageReference)
    getStateParameters(currentPageReference) {
       if (currentPageReference) {
          this.name = currentPageReference.state?.name;
       }
    }

    navigateHome(event) {
        let tabName = event.target.dataset.id;
        this[NavigationMixin.Navigate]({
            type: 'comm__namedPage',
            attributes: {
                name: 'Home'
            },
            state: {
                tab: tabName
            }
        });
    }
}