import { LightningElement, track } from "lwc";
import loggedInUserId from "@salesforce/user/Id";
import IS_GUEST from "@salesforce/user/isGuest";
import getUserProfile from "@salesforce/apex/MallProfileManagementController.getUserProfile";
import getProducts from "@salesforce/apex/MallProductFrontManagementController.getProducts";
import getSegmentTags from "@salesforce/apex/MallDataService.getSegmentTags";
import getActiveRootCategories from "@salesforce/apex/MallDataService.getActiveRootCategories";
import submitForApproval from "@salesforce/apex/MallProductFrontManagementController.submitForApproval";
import saveProduct from "@salesforce/apex/MallProductFrontManagementController.saveProduct";
import recallProducts from "@salesforce/apex/MallProductFrontManagementController.recallProducts";
import publishProduct from "@salesforce/apex/MallProductFrontManagementController.publishProduct";
import unpublishProduct from "@salesforce/apex/MallProductFrontManagementController.unpublishProduct";
import uploadImage from "@salesforce/apex/MallProductFrontManagementController.handleImageUpload";
import { ShowToastEvent } from "lightning/platformShowToastEvent";

const actions = [
  { label: "Edit", name: "edit" },
  { label: "View", name: "view" }
];

export default class MallProductFrontManagement extends LightningElement {
  @track columns = [
    { label: "Name", fieldName: "name" },
    { 
      type: 'button-icon',
      initialWidth: 50,
      typeAttributes:
      {
          iconName: 'utility:preview',
          name: 'view',
          class : 'icon-button-theme-colour'
      },
      cellAttributes: { alignment: 'right' }
  },
  {
      type: 'button-icon',
      initialWidth: 50,
      typeAttributes:
      {
          iconName: 'utility:edit',
          name: 'edit',
          class : 'icon-button-theme-colour'
      },
      cellAttributes: { alignment: 'right' }
  }
  ];

  showProductScreen = false;
  userProfile;
  accountId;
  products;

  maxLengthShortDescription = 100;
  lengthShortDescription = 0;
  maxLengthLongDescription = 1000;
  lengthLongDescription = 0;


  //pagination setup
  currentPage=1;
  pageSize=4;

  showCategoryPlaceholder = true;
  categoryInputPlaceholder = 'Select categories';
  @track showCategoryDropdown = false;
  @track categoryPlaceHolder='Select categories';

  @track disableAddProduct=false;
  @track productTypes = [
    {
      type: "Published",
      resultData: [],
      showTable: false,
      showPublishButton: false,
      showSubmitForApprovalButton: false,
      showRecallButton: false,
      showUnpublishButton : true,
      noServicesMessage:'There are no published services on record'

    },
    {
      type: "Approved",
      resultData: [],
      showTable: false,
      showPublishButton: true,
      showSubmitForApprovalButton: false,
      showRecallButton: false,
      showUnpublishButton : false,
      noServicesMessage:'There are no approved services on record'
    },
    {
      type: "Submitted",
      resultData: [],
      showTable: false,
      showPublishButton: false,
      showSubmitForApprovalButton: false,
      showRecallButton: true,
      showUnpublishButton : false,
      noServicesMessage : 'There are no submitted services on record'
    },
    {
      type: "Draft",
      resultData: [],
      showTable: false,
      showPublishButton: false,
      showSubmitForApprovalButton: true,
      showRecallButton: false,
      showUnpublishButton : false,
      noServicesMessage : 'There are no draft services on record'
    },
    {
      type: "Rejected",
      resultData: [],
      showTable: false,
      showPublishButton: false,
      showSubmitForApprovalButton: false,
      showRecallButton: false,
      showUnpublishButton : false,
      noServicesMessage : 'There are no rejected services on record'

    }
  ];

  @track needsOptions = [];

  @track categoryOptions = [];

  @track selectedNeed;
  @track selectedCategories=[];

  showAddProductPublishButton = false;
  showUnpublishButton=false;

  @track viewMode = false;
  @track addMode=false;
  @track formProduct;
  showSpinner=false;

  unpublishProductIds=[];
  recallProductIds=[];
  submitForApprovalRecords=[]; 
  publishRecords=[];

  @track disablePublishButton = true;
  @track disableSubmitButton = true;
  @track disableRecallButton = true;
  @track disableUnpublishButton = true;
  imageHelperText =
    "<p>The image needs to have a height of 208px and width of 208px, the image should adhere to a safe zone of 208px width and 156px height</p>";

  imageGuide = true;
  acceptedImageFormats = [".png", ".jpg", ".jpeg"];

  connectedCallback() {
    if (!IS_GUEST) {
      this.fetchUserProfile();
    }
    getSegmentTags()
      .then((result) => {
        for (let i = 0; i < result.length; i++) {
          this.needsOptions.push({
            label: result[i].name=='Individual'?'Personal':result[i].name,
            value: result[i].id
          });
        }
        this.selectedNeed = this.needsOptions[0].value;
      })
      .catch((error) => {
        console.log("error");
      });

    getActiveRootCategories()
      .then((result) => {
        for (let i = 0; i < result.length; i++) {
          this.categoryOptions.push({
            label: result[i].name,
            value: result[i].name,
            selected : false,
            id:result[i].id
          });
        }
      })
      .catch((error) => {
        console.log("error");
      });
    this.resetFormProduct();
  }

  handleCategorySelection(event) {
    event.stopPropagation();
    this.categoryOptions = event.detail;
    this.selectedCategories=[];
    event.detail.forEach(item=>{
        if(item.selected)
        this.selectedCategories.push(item.id);
    })
    this.formProduct.categoryIds=this.selectedCategories;
}

  fetchUserProfile() {
    getUserProfile({ currentUserId: loggedInUserId })
      .then((result) => {
        this.userProfile = result;
        this.accountId = this.userProfile.user.AccountId;
        getProducts({ accountId: this.accountId })
          .then((result) => {
            this.products = result;
            if(!this.products[0].shopPublished){
              this.disableAddProduct=true;
            }
            this.prepareProductsForDataTable();
          })
          .catch((error) => {
            console.log("error");
          });
      })
      .catch((error) => {
        console.log("error");
      });
  }

  handleClear(){
    this.handleRemoveImage();
    this.template.querySelectorAll("lightning-input").forEach(item=>{
            item.value=undefined;
    })
    this.template.querySelectorAll("lightning-input-rich-text").forEach(item=>{
       item.value='';
    })
    this.template.querySelectorAll("lightning-textarea").forEach(item=>{
      item.value=undefined;
    })
    this.categoryOptions.forEach(item=>{
      item.selected=false;
    })
  }

  handleRemoveImage(){
      this.formProduct.uploadedImageUrl=undefined;
      this.formProduct.imageUploaded=undefined;
  }

  handlePaginationChange(event) {
    event.preventDefault();
    event.stopPropagation();
    const startIndex = (event.detail.selectedPage - 1) * this.pageSize;
    const endIndex = startIndex + this.pageSize;
    for(let i=0;i<this.productTypes.length;i++){
          if(this.productTypes[i].type==event.detail.type){
              this.productTypes[i].currentPage=event.detail.selectedPage;
              this.productTypes[i].displayedData=(this.productTypes[i].resultData).slice(startIndex, endIndex);
          }
      }
 }

  resetFormProduct() {
    this.formProduct = {
      productId: undefined,
      categoryIds: undefined,
      publishedFrom: undefined,
      publishedUntil: undefined,
      uploadedImageUrl: undefined,
      productUrl: undefined,
      segmentId: undefined,
      cutId: undefined,
      categoryTagProductId: undefined,
      segmentTagProductId: undefined,
      publishingUnitId: undefined,
      linkId: undefined,
      productStatus: undefined,
      name: undefined,
      imageUrl: undefined,
      comment: undefined,
      accountId: this.accountId,
      longDesc:undefined,
      shortDesc:undefined
    };
  }

  prepareProductsForDataTable() {
    for (let i = 0; i < this.products.length; i++) {
      if (this.products[i].productStatus == "Published" && this.products[i].clonedProductStatus=="Published") {
        for (let j = 0; j < this.productTypes.length; j++) {
          if (this.productTypes[j].type == "Published") {
            this.productTypes[j].resultData.push(this.products[i]);
            this.productTypes[j].showTable = true;
          }
        }
      } else if (this.products[i].productStatus == "Submitted") {
        for (let j = 0; j < this.productTypes.length; j++) {
          if (this.productTypes[j].type == "Submitted") {
            this.productTypes[j].resultData.push(this.products[i]);
            this.productTypes[j].showTable = true;
          }
        }
      } else if (this.products[i].productStatus == "Rejected") {
        for (let j = 0; j < this.productTypes.length; j++) {
          if (this.productTypes[j].type == "Rejected") {
            this.productTypes[j].resultData.push(this.products[i]);
            this.productTypes[j].showTable = true;
          }
        }
      } else if (this.products[i].productStatus == "Draft") {
        for (let j = 0; j < this.productTypes.length; j++) {
          if (this.productTypes[j].type == "Draft") {
            this.productTypes[j].resultData.push(this.products[i]);
            this.productTypes[j].showTable = true;
          }
        }
      } else if (this.products[i].productStatus == "Approved") {
        for (let j = 0; j < this.productTypes.length; j++) {
          if (this.productTypes[j].type == "Approved") {
            this.productTypes[j].resultData.push(this.products[i]);
            this.productTypes[j].showTable = true;
          }
        }
      }
    }

    
    //prepare pagination data
    const startIndex = 0;
    const endIndex = startIndex + this.pageSize;
    for(let j = 0; j < this.productTypes.length; j++){
          this.productTypes[j].totalPages=Math.ceil(this.productTypes[j].resultData.length/this.pageSize);
          this.productTypes[j].currentPage=1;
          this.productTypes[j].displayedData=(this.productTypes[j].resultData).slice(startIndex,endIndex);
          this.productTypes[j].showPagination=this.productTypes[j].displayedData.length<this.productTypes[j].resultData.length;
    }
  }

  async handleImageUploadFinished(event) {
    const uploadedFiles = event.detail.files;
    let singleFile;
    if (uploadedFiles && uploadedFiles.length > 0) {
      singleFile = uploadedFiles[0];
    }
    if (singleFile) {
      uploadImage({ imageId: singleFile.contentVersionId })
      .then((result) => {
        this.formProduct.uploadedImageUrl = result;
        this.formProduct.imageUploaded = true;
        this.formProduct.imageUrl = result;
      })
      .catch((error) => {
        console.log("error");
      });
    }
  }

  handleAddProduct() {
    this.showProductScreen = true;
    this.addMode=true;
    this.formTitle='Add Service';
    this.resetFormProduct();
  }

  handleSubmitValidation() {
    let errors = [];
    if(!this.formProduct.name) {
        errors.push(' Name');
    }
    if(!this.formProduct.productUrl) {
        errors.push(' Service URL');
    }
    if(!this.formProduct.publishedFrom) {
        errors.push(' published from date');
    }
    if(!this.formProduct.publishedUntil) {
        errors.push(' published until date');  
    }
    if(!this.formProduct.categoryIds.length) {
      errors.push(' Category');   
    }
    if(!this.formProduct.shortDesc) {
      errors.push(' Short description');  
    }
    if(!this.formProduct.longDesc) {
      errors.push(' Long description');  
    }
    if(!this.formProduct.uploadedImageUrl && !this.formProduct.imageUploaded) {
      errors.push(' Service image');   
    }
    
    return errors.join(', ');

}

  handleRowAction(event) {
    const actionName = event.detail.action.name;
    const row = event.detail.row;
    switch (actionName) {
      case "view":
        this.viewMode = true;
        this.showProductScreen = true;
        this.formProduct = row;
        this.showAddProductPublishButton = false;
        this.showUnpublishButton = false;
        this.selectedNeed = row.segmentId;
        this.categoryPlaceHolder='';
        this.formTitle='View Service';
        this.addMode=false;
        this.categoryOptions.forEach(item=>{
            if(row.categoryIds.includes(item.id)){
               item.selected=true;
            }
            else{
              item.selected=false;
            }
        })
        const element = this.template.querySelector('.rich-text-container');
        element.classList.add('disabled-rich-text');
        break;
      case "edit":
        this.viewMode = (row.productStatus == "Approved" || row.productStatus == "Published" || row.productStatus == "Submitted") ? true : false;
        this.showProductScreen = true;
        this.formProduct = row;
        this.showAddProductPublishButton =
          row.productStatus == "Approved" ? true : false;
        this.showUnpublishButton = row.productStatus == "Published" ? true : false;
        this.selectedNeed = row.segmentId;
        this.formTitle='Edit Service';
        this.categoryPlaceHolder='';
        this.addMode=false;
        this.categoryOptions.forEach(item=>{
          if(row.categoryIds.includes(item.id)){
             item.selected=true;
          }
          else{
            item.selected=false;
          }
      })
        break;
      default:
    }
  }

  handleCancel() {
    this.resetVariables();
  }

  closeModal() {
    this.resetVariables();
  }

  handleSave() {
    this.formProduct.accountId = this.accountId;
    if (!this.formProduct.segmentId) {
      this.formProduct.segmentId = this.selectedNeed;
    }
    if (!this.formProduct.categoryIds) {
      this.formProduct.categoryIds = this.selectedCategories;
    }
    let errors=this.handleSubmitValidation();
    if(errors){
      this.showToast("Please fill up following information : ", errors , "error");
      return;
    }
    let productData = JSON.stringify(this.formProduct);
    this.showSpinner=true;
    saveProduct({ productInfoStrings: [productData] })
      .then((result) => {
        this.showToast("Saved successfully!", "", "success");
        this.resetVariables();
        this.showSpinner=false;
        location.reload();
      })
      .catch((error) => {
        console.log("error");
      });
  }

  handlePublish() {
    let productData = JSON.stringify(this.formProduct);
    this.showSpinner=true;
    publishProduct({ productInfoStrings: [productData] })
      .then((result) => {
        this.showToast("Published Sucessfully!", "", "success");
        this.resetVariables();
        this.showSpinner=false;
        location.reload();
      })
      .catch((error) => {
        console.log("error");
      });
  }

  handleUnpublishProduct(){
    let productIdsToUnpublish=[this.formProduct.productId];
    this.showSpinner=true;
    unpublishProduct({ productIds: productIdsToUnpublish })
    .then((result) => {
      this.showToast("Product Unpublished!", "", "success");
      this.resetVariables();
      this.showSpinner=false;
      location.reload();
    })
    .catch((error) => {
      console.log("error");
    });
  }

  handleSubmitForApproval() {
    this.formProduct.accountId = this.accountId;
    if (!this.formProduct.segmentId) {
      this.formProduct.segmentId = this.selectedNeed;
    }
    if (!this.formProduct.categoryIds) {
      this.formProduct.categoryIds = this.selectedCategories;
    }
    let errors=this.handleSubmitValidation();
    if(errors){
      this.showToast("Please fill up following information : ", errors , "error");
      return;
    }
    let productData = JSON.stringify(this.formProduct);
    this.showSpinner=true;
    submitForApproval({ productInfoStrings: [productData] })
      .then((result) => {
        this.showToast("Submitted for approval!", "", "success");
        this.resetVariables();
        this.showSpinner=false;
        location.reload();
      })
      .catch((error) => {
        console.log("error");
      });
  }

  handleNameChange(event) {
    this.formProduct.name = event.target.value;
  }

  handleUrlChange(event) {
    this.formProduct.productUrl = event.target.value;
  }

  handleFrom(event) {
    this.formProduct.publishedFrom = event.target.value;
  }

  handleUntil(event) {
    this.formProduct.publishedUntil = event.target.value;
  }

  handleNeedsChange(event) {
    this.formProduct.segmentId = event.target.value;
  }

  handleApprovalComment(event) {
    this.formProduct.comment = event.target.value;
  }

  handleShortDesc(event){
    if(this.formProduct.shortDesc && this.formProduct.shortDesc.length >= this.maxLengthShortDescription) {
      return;
    }
    this.formProduct.shortDesc=event.target.value;
    this.lengthShortDescription = this.formProduct.shortDesc ? this.formProduct.shortDesc.length : 0;
    
  }

  handleLongDesc(event){
    if(this.formProduct.longDesc && this.formProduct.longDesc.length >= this.maxLengthLongDescription) {
      return;
    }
    this.formProduct.longDesc=event.target.value;
    this.lengthLongDescription = this.formProduct.longDesc ? this.formProduct.longDesc.length : 0;
  }

  resetVariables() {
    this.showProductScreen = false;
    this.viewMode = false;
    this.showAddProductPublishButton = false;
    this.selectedNeed = this.needsOptions[0].value;
    this.categoryOptions.forEach(item=>{
         item.selected=false;
    })
    this.selectedCategories=[];
    this.showUnpublishButton=false;
    this.resetFormProduct();
  }

  showToast(title, message, variant) {
    const event = new ShowToastEvent({
      title: title,
      message: message,
      variant: variant
    });
    this.dispatchEvent(event);
  }

  /* This Method Displays that fieldName of the selected rows */
  handleRowSelection(event) {
    this.disableRecallButton = true;
    this.disablePublishButton = true;
    this.disableSubmitButton = true;
    this.disableUnpublishButton=true;
    this.unpublishProductIds=[];
    this.recallProductIds=[];
    this.submitForApprovalRecords=[];
    this.publishRecords=[];
    const selectedRows = event.detail.selectedRows;
    for (let i = 0; i < selectedRows.length; i++) {
      if (selectedRows[i].productStatus == "Submitted") {
        this.disableRecallButton = false;
        this.recallProductIds.push(selectedRows[i].productId);
      } else if (selectedRows[i].productStatus == "Approved") {
        this.disablePublishButton = false;
        this.publishRecords.push(JSON.stringify(selectedRows[i]));
      } else if (selectedRows[i].productStatus == "Draft") {
        this.disableSubmitButton = false;
        this.submitForApprovalRecords.push(JSON.stringify(selectedRows[i]));
      } else if (selectedRows[i].productStatus == "Published") {
        this.disableUnpublishButton = false;
        this.unpublishProductIds.push(selectedRows[i].productId);
      }
    }
  }
  showImageGuide() {
    this.imageGuide = !this.imageGuide;
  }

  handleBulkPublish(event) {
    event.preventDefault();
    event.stopPropagation();
    /*Add bulk update publish*/
    if(this.publishRecords.length>0){
      this.showSpinner=true;
      publishProduct({ productInfoStrings: this.publishRecords})
      .then((result) => {
        this.showToast("Service(s) published sucessfully!", "", "success");
        this.resetVariables();
        this.showSpinner=false;
        location.reload();
      })
      .catch((error) => {
        console.log("error");
      });
    }
  }

  handleBulkSubmitForApproval(event) {
    event.preventDefault();
    event.stopPropagation();
    /*Add bulk update submit for approval*/
    if(this.submitForApprovalRecords.length>0){
      this.showSpinner=true;
      submitForApproval({ productInfoStrings: this.submitForApprovalRecords})
      .then((result) => {
        this.showToast("Service(s) submitted for approval!", "", "success");
        this.resetVariables();
        this.showSpinner=false;
        location.reload();
      })
      .catch((error) => {
        console.log("error");
      });
    }
  }

  handleBulkRecall(event) {
    event.preventDefault();
    event.stopPropagation();
    /*bulk update recall*/
      if(this.recallProductIds.length>0){
        this.showSpinner=true;
        recallProducts({ productIds: this.recallProductIds})
        .then((result) => {
          this.showToast("Service(s) recalled!", "", "success");
          this.resetVariables();
          this.showSpinner=false;
          location.reload();
        })
        .catch((error) => {
          console.log("error");
        });
    }

  }

  handleBulkUnpublish(){
    if(this.unpublishProductIds.length>0){
      this.showSpinner=true;
        unpublishProduct({ productIds: this.unpublishProductIds})
        .then((result) => {
          this.showToast("Service(s) Unpublished!", "", "success");
          this.resetVariables();
          this.showSpinner=false;
          location.reload();
        })
        .catch((error) => {
          console.log("error");
        });
    }
  }
}