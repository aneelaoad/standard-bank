/**
* @description  : Partner Portal Footer Banner Component
* User Story : SFP-4962
*
* @author Syed Ovais Ali (syed.ali@standardbank.co.za)
* @date June 2021
*/
import { LightningElement , api} from 'lwc';

export default class PpRegisterWithUsFooterBanner extends LightningElement {
  	@api textOne;
    @api textTwo;  
  	@api linkLabel;
	@api link;
}