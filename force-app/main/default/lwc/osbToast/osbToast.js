import { LightningElement,api } from 'lwc';

export default class Osb_Toast extends LightningElement {

@api toasttype;
@api toastmessage;
closepopup = true;
@api top;
@api left;
@api stylevalue;
toastSuccess = false;

closeToast(){
    this.closepopup = false;
}

renderedCallback(){
    window.scrollTo(0, 0);
    let elementType = this.template.querySelector('[data-id="toast-type"]');
    let elementLocation = this.template.querySelector('[data-id="toast-location"]');
    if(this.toasttype == 'success'){
        elementType.classList.add('toast_success');
        elementLocation.classList.add('toast__success_left');
        this.toastSuccess = true;
    }else{
        elementType.classList.add('toast_warning');
        elementLocation.classList.add('toast_warning_left');
        this.toastSuccess = false;
    }
    this.template.querySelector('[data-id="main"]').setAttribute('style', "top:"+this.top+';'+"left:"+this.left);
    this.template.querySelector('[data-id="toastContainerId"]').setAttribute('style', "top:"+this.top+';'+"left:"+this.left);
    setTimeout(function() {
            this.closepopup = false;
    }, 10000);
}


}