import { LightningElement, wire } from "lwc";
import Minimall from "@salesforce/resourceUrl/OSB_MiniMall";
import { MessageContext, publish } from "lightning/messageService";
import messageChannel from "@salesforce/messageChannel/osbMenuEvents__c";
import getProductMap from "@salesforce/apex/OSB_OD_ProductCatalogue_CTRL.getProductMap";

export default class OsbapiProductCatalogue extends LightningElement {
    filterLogo = Minimall + '/filterIcon.svg';
    categories = [];
    productMap;
    category;
    selectedCategories = [];
    showLoader = false;
    isOpen = true;

    arrowClass = "dropdown-arrow";
    itemContainerClass = "product-filter-item-container";

    @wire(MessageContext)
    messageContext;

    @wire(getProductMap)
    WiredGetProductMap({ data }) {
        this.showLoader = true;
        if (data) {
            this.productMap = this.setSortedProducts(data);
            this.getCategoryList();
            this.handleProductItems();
            this.showLoader = false;
        }
    }

    get dynamicHeight() {
        return "height: " + (this.categories.length * 2.5 + 6.5) + "rem";
    }

    get setBoxShadowHeight() {
        if (this.isOpen)
            return "height: " + (this.categories.length * 2.5 + 6.5) + "rem";
        return "height: " + 6.5 + "rem";
    }

    handleProductItems() {
        const payload = {
            ComponentName: "osbapiProductCatalogue",
            Details: {
                productMap: this.productMap
            }
        };
        publish(this.messageContext, messageChannel, payload);
    }

    sendProductMap() {
        if (this.productMap) {
            this.template
                .querySelector("c-osbapi-product-gallery")
                .initializeComponent(this.productMap);
        }
    }

    getCategoryList() {
        const uniqueCategories = [
            ...new Set(this.productMap.map((product) => product.Category))
        ];
        this.categories = uniqueCategories;
    }

    sortProducts(a, b) {
        if (a.Name < b.Name) {
            return -1;
        }
        if (a.Name > b.Name) {
            return 1;
        }
        return 0;
    }

    setSortedProducts(products) {
        let productArray = JSON.parse(JSON.stringify(products));
        productArray.sort(this.sortProducts);
        return productArray;
    }

    handleCheckbox(event) {
        if (event.target.checked) {
            this.selectedCategories.push(event.target.value);
        } else {
            const index = this.selectedCategories.indexOf(event.target.value);
            this.selectedCategories.splice(index, 1);
        }
        this.template
            .querySelector("c-osbapi-product-gallery")
            .handleFilter(this.selectedCategories);
    }

    handDropdown() {
        this.isOpen = !this.isOpen;
        this.template
            .querySelector('[data-id="dropdown-arow"]')
            .classList.toggle("open");
        this.template
            .querySelector('[data-id="product-filter-container"]')
            .classList.toggle("open");
        this.template
            .querySelector('[data-id="product-filter"]')
            .classList.toggle("closed");
    }

    slideIt() {
        this.template.querySelectorAll(".arrow").toggleClass("active");
    }

    renderedCallback() {
        this.sendProductMap();
    }
}