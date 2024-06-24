import { LightningElement, api } from "lwc";
import bannerPath from '@salesforce/resourceUrl/mallBanners';

const DEFAULT_VALUE_PROP = '[{"id": 1,"title": "Purpose Driven","description":"Exclusive access to discounts through personalized recommendations.","image":"/mall/s/sfsites/c/resource/sbgVisualAssets/sbg-purpose.svg"},{"id": 2,"title": "Specialists","description":"Trusted expertise from the largest bank in Africa.","image":"/mall/s/sfsites/c/resource/sbgVisualAssets/sbg-heart.svg"},{"id": 3,"title": "Value","description":"Conveniently bringing you a variety of high quality products and services to choose from.","image":"/mall/s/sfsites/c/resource/sbgVisualAssets/sbg-value.svg"}]'
export default class MallAboutUsContent extends LightningElement {

  //Banner properties
  @api bannerHeading;
  @api bannerDescription;
  @api bannerSubText;
  @api bannerAction;
  @api bannerDestinationUrl;
  @api bannerVariant;
  @api bannerButtonLabel;
  @api bannerDisabled;
  @api bannerButtonTitle;
  @api bannerWClass;
  @api bannerShowButton;
  @api bannerImagePath;
  @api bannerImagePathTablet;
  @api bannerImagePathDesktop;
  @api bannerCustomBannerStyles;
  @api bannerCustomBackgroundColour;
  @api bannerApplyColourContrastInversion;
  @api bannerInteractionTextBefore;
  @api bannerInteractionScope;
  @api bannerInteractionText;

  @api titleShopper;
  @api contentShopper;
  @api titleSeller;
  @api contentSeller;
  @api titleAbout;
  @api contentAbout;

  @api valuePropositionJson;

  imgAbout = bannerPath + '/about-us-1.jpg';
  imgSeller = bannerPath + '/about-us-2.jpg';
}