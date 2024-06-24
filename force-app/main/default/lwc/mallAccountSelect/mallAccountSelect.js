import { LightningElement, api } from 'lwc';

export default class MallAccountSelect extends LightningElement {
    userOptionsLst;
    accountOptionsLst;
    selectedProfileId;
    selectedProfileName;
    selectAccountId;
    selectedAccountName;

    @api set userOptions(collection) {
        this.userOptionsLst = collection;
        if(collection && collection.length) {
            this.selectedProfileId = collection[0].value;
            this.selectedProfileName = collection[0].label;
        }
    }

    get userOptions() {
        return this.userOptionsLst;
    }

    @api set accountOptions(collectionAccount) {
        this.accountOptionsLst = collectionAccount;
        if(collectionAccount && collectionAccount.length) {
            this.selectAccountId = collectionAccount[0].value;
            this.selectedAccountName = collectionAccount[0].label;
            if(this.selectedProfileId && this.selectAccountId) {
                const accountSelectEvent = new CustomEvent("accountselection", {
                    detail: {profileId : this.selectedProfileId, accountId : this.selectAccountId}
                });
                this.dispatchEvent(accountSelectEvent);
            }
        }
    }

    get accountOptions() {
        return this.accountOptionsLst;
    }

    connectedCallback() {
        window.addEventListener("closeDropdowns", () => {
            let dropdowns = this.template.querySelectorAll(".dropdown [aria-expanded]")
      
            dropdowns.forEach((item) => {
              item.setAttribute("aria-expanded", false);
            })
          });
      
          window.addEventListener("click", () => {
            if (window.dropdownIntentToOpen !== true) {
              window.dispatchEvent(new CustomEvent("closeDropdowns"));
            }
            window.dropdownIntentToOpen = false;
          });
    }

    toggleDropdown(event) {
		event.stopPropagation();
		let selector;
		if (event.target.classList.contains("[aria-expanded]")) {
			selector = event.target;
		}
		else {
			selector = event.target.closest("[aria-expanded]");
		}
		if (selector) {
			let state = selector.getAttribute("aria-expanded") === "true" ? true : false;
			this.triggerCloseDropdowns();
			selector.setAttribute("aria-expanded", !state);
		}
	}

	triggerCloseDropdowns() {
		window.dispatchEvent(new CustomEvent("closeDropdowns"));
	}

    handleProfileChange(event) {
        const profileId = event.currentTarget.dataset.value;
        const profileName = event.currentTarget.dataset.category;

        if(profileId != this.selectedProfileId) {
            this.selectedProfileId = profileId;
        }

        if(profileName != this.selectedProfileName) {
            this.selectedProfileName = profileName;
        }

        const accountSelectEvent = new CustomEvent("profileselection", {
            detail: {profileId : this.selectedProfileId, accountId : this.selectAccountId}
        });
        this.dispatchEvent(accountSelectEvent);
    }

    handleAccountChange(event) {
        const accountId = event.currentTarget.dataset.value;
        const accountName = event.currentTarget.dataset.category;

        if(accountId != this.selectAccountId) {
            this.selectAccountId = accountId;
        }

        if(accountName != this.selectAccountName) {
            this.selectAccountName = accountName;
        }

        const accountSelectEvent = new CustomEvent("accountselection", {
            detail: {profileId : this.selectedProfileId, accountId : this.selectAccountId}
        });
        this.dispatchEvent(accountSelectEvent);
    }
}