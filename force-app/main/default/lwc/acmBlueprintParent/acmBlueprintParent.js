import { LightningElement, api } from 'lwc'
export default class AcmBlueprintParent extends LightningElement {
  @api rowheading;
  @api card1IsRecommended;
  @api card1Heading;
  @api card1Description ;
  @api card1ButtonLabel;
  @api card1ButtonUrl;
    
  @api card2IsRecommended ;
  @api card2Heading;
  @api card2Description;
  @api card2ButtonLabel;
  @api card2ButtonUrl;

  @api card3IsRecommended;
  @api card3Heading;
  @api card3Description;
  @api card3ButtonLabel ;
  @api card3ButtonUrl ;

  isCardRendered(heading) {
    return !!heading.trim();
  }

}