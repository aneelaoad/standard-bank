import { LightningElement } from 'lwc';
import OSB_Images from '@salesforce/resourceUrl/OSB_Images_Two';
import { addAnalyticsInteractions, pageViewSinglePageApp } from 'c/osbAdobeAnalyticsWrapperLwc';

export default class osb_frdmsitepage extends LightningElement {
    logo = OSB_Images + '/OSB_Images_Two/Group_17.png';
    image1 = OSB_Images + '/OSB_Images_Two/Logos-01.png';
    image2 = OSB_Images + '/OSB_Images_Two/Logos-02.png';
    image3 = OSB_Images + '/OSB_Images_Two/Logos-03.png';
    image4 = OSB_Images + '/OSB_Images_Two/Logos-04.png';
    image5 = OSB_Images + '/OSB_Images_Two/Logos-05.png';
    image6 = OSB_Images + '/OSB_Images_Two/Logos-06.jpg';
    image7 = OSB_Images + '/OSB_Images_Two/Logos-08.png';
    image8 = OSB_Images + '/OSB_Images_Two/Coca_Cola.png';
    image9 = OSB_Images + '/OSB_Images_Two/government-of-canada-vector-logo.png';
    image10 = OSB_Images + '/OSB_Images_Two/Logos-07.png';
    image11 = OSB_Images + '/OSB_Images_Two/column_sq_02.png';

    group1 = OSB_Images + '/Group_6.png';
    group2 = OSB_Images + '/Group_4.png';
    group3 = OSB_Images + '/Group_11.png';
    
    group4 = OSB_Images + '/Group_12.png';
    group5 = OSB_Images + '/Group_8.png';
    group6 = OSB_Images + '/Group_7.png';
    group7 = OSB_Images + '/Group_5.png';

    group8 = OSB_Images + '/Group_10.png';
    group9 = OSB_Images + '/Group_9.png';
    group10 = OSB_Images + '/Group_14.png';

    organise = OSB_Images + '/Organise.PNG';
    engage = OSB_Images + '/Engage.PNG';
    enhance = OSB_Images + '/Enhance.PNG';
    report = OSB_Images + '/Report.PNG';
    improve = OSB_Images + '/Improve.PNG';

    captureOne = OSB_Images + '/CaptureOne.PNG';
    captureTwo = OSB_Images + '/CaptureTwo.PNG';
    captureThree = OSB_Images + '/CaptureThree.PNG';
    captureFour = OSB_Images + '/CaptureFour.PNG';
    captureFive = OSB_Images + '/CaptureFive.PNG';

    line = OSB_Images + '/line.PNG';
    footer = OSB_Images + '/Group_17.png';

    hwstartedImageOne = OSB_Images + '/hwStartedImage1.PNG';
    hwstartedImageTwo = OSB_Images + '/hwStartedImage2.PNG';
    hwstartedImageThree = OSB_Images + '/hwStartedImage3.PNG';
    hwstartedImageFour = OSB_Images + '/hwStartedImage4.PNG';
    hwstartedImageFive = OSB_Images + '/hwStartedImage5.PNG';

    RequestButtonAdobe;
    ReturnButtonAdobe;

    connectedCallback(){
        let pagename =  ' Frdm | Splash page';
        this.RequestButtonAdobe =  " Frdm | request access";
        this.ReturnButtonAdobe =  "Frdm | return to Onehub";
        pageViewSinglePageApp(pagename);
    }

    renderedCallback(){
        addAnalyticsInteractions(this.template);
    }
}