import { LightningElement } from 'lwc';
import PDF_RESOURCE from '@salesforce/resourceUrl/acmproducerjourneypdf';

export default class acmProducerjourney extends LightningElement {
    generatePdf() {
       
        const a = document.createElement('a');
        a.href = PDF_RESOURCE;
        a.download = 'acmProducerJourneyPDFGenerator.pdf';
        a.style.display = 'none';
        document.body.appendChild(a);
        a.click();
        document.body.removeChild(a);
    }
}