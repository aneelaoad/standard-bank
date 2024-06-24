import { LightningElement } from 'lwc';

export default class AcmRegistrationTermsAndConditions extends LightningElement {
    handleAccordion(event) {
        const acc = this.template.querySelectorAll(".accordion");
        let targetId = event.target.dataset.id;
        let elem = acc[targetId].classList.toggle("active");
        if(elem) {
            let panel = acc[targetId].nextElementSibling;
            panel.style.maxHeight = panel.scrollHeight + "px";
        } else {
            let panel = acc[targetId].nextElementSibling;
            panel.style.maxHeight = 0;
        }
        
        
        
        for (let i = 0; i < acc.length; i++) {
            if(acc[i].dataset.id != targetId) {
                acc[i].classList.remove("active");
                let panel = acc[i].nextElementSibling;
                panel.style.maxHeight = 0;
            } 
        }
    }
}