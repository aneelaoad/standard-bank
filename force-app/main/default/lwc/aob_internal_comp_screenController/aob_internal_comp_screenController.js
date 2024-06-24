/**
 * @description       : Screen controller logic for all the components.
 * @author            : Sibonelo Ngcobo
 * @last modified on  : 07-20-2023
 * @last modified by  : Sibonelo Ngcobo
 * Modifications Log
 * Ver   Date         Author            Modification
 * 1.0   07-20-2023   Sibonelo Ngcobo   SFP-25089
**/
import { LightningElement,api,wire,track} from 'lwc';
import getApplicationData from '@salesforce/apex/AOB_internal_CTRL_Onboarding.getApplicationData';
import { MessageContext, subscribe } from 'lightning/messageService';
import messageChannel from '@salesforce/messageChannel/previousScreenMessageChannel__c';

export default class aob_internal_screenController extends LightningElement {
    @api recordId;
    currentPage;
    Bool_Personal_Details=false;
    Bool_Before_We_Begin=false;
    Bool_Residential_Address=false;
    Bool_Company_Trading_Address=false;
    Bool_Residential_Address=false;
    Bool_Employment_Details=false;
    Bool_Company_Details=false;
    Bool_Company_Trading_Address=false;
    Bool_Company_Financial_Details=false;
    Bool_Pre_Application=false;
    Bool_Marketing_Consent=false;
    Bool_Card_Selection=false;
    Bool_Notifications=false;
    Bool_Summary=false;
    Bool_Available_Bundles=false;
    Bool_PocketBiz=false;
    Bool_SnapScan=false;
    Bool_OTP=false;
    Bool_Application_Complete=false;

    Bool_application_line_item;
    Bool_application_line_item_SnapScan;

    nextscreen;
    snapscan=false;
    pocketbiz=false;
    screen;
    previousScreen;
    subscription=null;

    @wire(MessageContext)
    MessageContext;

    connectedCallback(){
    this.getApplicationDatalwc();
    this.subscribeMC();
    }
    
    subscribeMC(){
        if(this.subscription!=null){
            return this.subscription;
        }
        this.subscription=subscribe(this.MessageContext,messageChannel,(message)=>{
            this.previousScreen=message.previousScreen;
            this.handleBack(message.previousScreen);
        })
    }
        
    getApplicationDatalwc(){    
    getApplicationData({recordId: this.recordId})
    .then((data)=>{
        this.currentPage=data[0].AOB_CurrentScreen__c;         
        this.getScreen(this.currentPage);
    })
    .catch((error)=>{
        this.error=error;
    });
    }

    getScreen(currentPage){
            if(currentPage === 'Personal Details'){
               this.Bool_Personal_Details=true;
            }
            else if(currentPage==='PreApplication'){
                 this.Bool_Pre_Application=true;
            }
            else if(currentPage === 'Residential Address'){
                 this.Bool_Residential_Address=true;
            }else if(currentPage === 'Before We Begin'){
                 this.Bool_Before_We_Begin=true;
            }else if(currentPage === 'Company Trading Address'){
                 this.Bool_Company_Trading_Address=true;
                }
            else if(currentPage === 'Employment Details'){
                 this.Bool_Employment_Details=true;
                }
            else if(currentPage === 'Company Details'){
                 this.Bool_Company_Details=true;
                }  
            else if(currentPage === 'Company Trading Address'){
                 this.Bool_Company_Trading_Address=true;
                }
            else if(currentPage === 'Company Financial Details'){
                 this.Bool_Company_Financial_Details=true;
                }
            else if(currentPage==='Marketing Consent Internal'||currentPage==='Marketing Consent'){
                 this.Bool_Marketing_Consent=true;
            }
            else if(currentPage==='Card Selection'){
                 this.Bool_Card_Selection=true;
            }
            else if(currentPage==='Available Bundles'){
                 this.Bool_Available_Bundles=true;
            }
            else if(currentPage==='Notifications'){
                this.Bool_Notifications=true;
            }
            else if(currentPage==='PocketBiz'){
                this.Bool_PocketBiz=true;
            }
            else if(currentPage==='SnapScan'){
                this.Bool_SnapScan=true;
            }
            else if(currentPage==='Summary'){
                this.Bool_Summary=true;
            }
            else if(currentPage==='Application Complete'){
                this.Bool_Application_Complete=true;
            }
            }
 
        handleEvent(event){
             let nextscreen=event.detail;
             this.screen=nextscreen;
            if(nextscreen === 'Personal Details'){
                this.Bool_Personal_Details=true;
            }
            else if(nextscreen === 'Residential Address'){
                this.Bool_Personal_Details=false;
                this.Bool_Residential_Address=true;
            }
            else if (nextscreen === 'Employment Details') {
                this.Bool_Residential_Address = false;
                this.Bool_Employment_Details = true;
            } 
            else if(nextscreen === 'Company Details'){
                this.Bool_Employment_Details=false;
                this.Bool_Company_Details=true;
            }
            else if(nextscreen === 'Company Trading Address'){
                this.Bool_Company_Details=false;
                this.Bool_Company_Trading_Address=true;
                }
            else if(nextscreen === 'Company Financial Details'){
                this.Bool_Company_Trading_Address=false;
                this.Bool_Company_Financial_Details=true;
                 }
            else if(nextscreen === 'Marketing Consent Internal'||nextscreen === 'Marketing Consent'){
                    this.Bool_Company_Financial_Details=false;
                    this.Bool_Marketing_Consent=true;
            }
            else if(nextscreen=== 'Card Selection'){
                this.Bool_Marketing_Consent=false;
                this.Bool_Card_Selection=true;
            }
            else if(nextscreen=== 'Notifications'){
                this.Bool_Card_Selection=false;
                this.Bool_Notifications=true;
            }
            else if(nextscreen=== 'Available Bundles'){
                this.Bool_Notifications=false;
                this.Bool_Available_Bundles=true;
            }
            else if(nextscreen=='bothProducts'){
                this.Bool_PocketBiz=true;
                this.Bool_Available_Bundles=false;
                this.snapscan=true;
            }
            else if(nextscreen==='PocketBiz'){
                this.Bool_Available_Bundles=false;
                this.Bool_SnapScan=false;
                this.Bool_PocketBiz=true;
            }
            else if(nextscreen==='SnapScan'){
                this.Bool_Available_Bundles=false;
                this.Bool_PocketBiz=false;
                this.Bool_SnapScan=true;
            }
            else if(nextscreen==='Summary'){
                this.Bool_Available_Bundles=false;
                this.Bool_PocketBiz=false;
                this.Bool_SnapScan=false;
                this.Bool_Summary=true;
            }
            else if(nextscreen==='Application Complete'){
                this.Bool_Summary=false;
                this.Bool_Application_Complete=true;
            }
        }
        
        handleBack(previousScreen){
            if(previousScreen === 'Personal Details'){
                this.Bool_Residential_Address = false;
                this.Bool_Personal_Details = true;
            }
            if(previousScreen === 'Residential Address'){
               this.Bool_Residential_Address = true;
               this.Bool_Employment_Details = false;
           }
           else if (previousScreen === 'Employment Details') {
            this.Bool_Employment_Details=true;
            this.Bool_Company_Details=false;
           } 
           else if(previousScreen === 'Company Details'){
            this.Bool_Company_Details=true;
            this.Bool_Company_Trading_Address=false;
           }
           else if(previousScreen === 'Company Trading Address'){
            this.Bool_Company_Trading_Address=true;
            this.Bool_Company_Financial_Details=false;
               }
           else if(previousScreen === 'Company Financial Details'){
            this.Bool_Company_Financial_Details=true;
            this.Bool_Marketing_Consent=false;
                }
           else if(previousScreen === 'Marketing Consent Internal'||previousScreen === 'Marketing Consent'){
            this.Bool_Marketing_Consent=true;
            this.Bool_Card_Selection=false;
           }
           else if(previousScreen=== 'Card Selection'){
               this.Bool_Card_Selection=true;
               this.Bool_Notifications=false;
           }
           else if(previousScreen=== 'Notifications'){
            this.Bool_Notifications=true;
            this.Bool_Available_Bundles=false;
           }
           else if(previousScreen=== 'Available Bundles'){
            this.Bool_Available_Bundles=true;
            this.Bool_PocketBiz=false;
            this.Bool_SnapScan=false;
            this.Bool_Summary=false;
           }
           else if(previousScreen==='bothProducts'){
            this.Bool_SnapScan=true;
            this.Bool_Summary=false;
            this.pocketbiz=true;
        }
           else if(previousScreen==='PocketBiz'){
            this.Bool_PocketBiz=true;
            this.Bool_Summary=false;
            this.Bool_SnapScan=false;
           }
           else if(previousScreen==='SnapScan'){
            this.Bool_SnapScan=true;
            this.Bool_Summary=false;
           }
           else if(previousScreen==='Summary'){
            this.Bool_Summary=true;
            this.Bool_Application_Complete=false;
           }
           else if(previousScreen==='Application Complete'){
               this.Bool_Summary=true;
               this.Bool_Application_Complete=false;
           }
       } 
}