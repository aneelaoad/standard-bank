import {
    LightningElement,
    track,api
} from 'lwc';
import PRODUCT_SCREENS from '@salesforce/resourceUrl/PBP_ThemeOverrides';
import FORM_FACTOR from "@salesforce/client/formFactor";
import Aboutus from '@salesforce/label/c.PBP_ZA_Aboutus';
import Locateus from '@salesforce/label/c.PBP_ZA_Locateus';
import ContactUs from '@salesforce/label/c.PBP_ZA_ContactUs';
import SouthAfrica from '@salesforce/label/c.PBP_ZA_SouthAfrica';
import Overview from '@salesforce/label/c.PBP_ZA_Overview';
import ProductandServices from '@salesforce/label/c.PBP_ZA_ProductandServices';
import BankwithUs from '@salesforce/label/c.PBP_ZA_Product_Bank_BreadCrumb_Bank_with_Us';
import BankAccounts from '@salesforce/label/c.PBP_ZA_BankAccounts';
import CREDITCARDS from '@salesforce/label/c.PBP_ZA_CREDITCARDS';
import SavingsAndInvestment from '@salesforce/label/c.PBP_ZA_SavingsAndInvestment';
import DigltalWallets from '@salesforce/label/c.PBP_ZA_DigltalWallets';
import ForeignExchange from '@salesforce/label/c.PBP_ZA_ForeignExchange';
import ForeignNationals from '@salesforce/label/c.PBP_ZA_ForeignNationals';
import InternationalSolutions from '@salesforce/label/c.PBP_ZA_InternationalSolutions';
import PrepaidCards from '@salesforce/label/c.PBP_ZA_PrepaidCards';
import ShariahBanking from '@salesforce/label/c.PBP_ZA_ShariahBanking';
import BorrowForYourNeeds from '@salesforce/label/c.PBP_ZA_BorrowForYourNeeds';
import HomeServices from '@salesforce/label/c.PBP_ZA_HomeServices';
import PersonalLoans from '@salesforce/label/c.PBP_ZA_PersonalLoans';
import VehicleFinancing from '@salesforce/label/c.PBP_ZA_VehicleFinancing';
import StudentsLoans from '@salesforce/label/c.PBP_ZA_StudentsLoans';
import GrowYourMoney from '@salesforce/label/c.PBP_ZA_GrowYourMoney';
import ShareTrading from '@salesforce/label/c.PBP_ZA_ShareTrading';
import FinancialPlanning from '@salesforce/label/c.PBP_ZA_FinancialPlanning';
import Personal from '@salesforce/label/c.PBP_ZA_Personal';
import InvestmentSolutions from '@salesforce/label/c.PBP_ZA_InvestmentSolutions';
import My360App from '@salesforce/label/c.PBP_ZA_My360App';
import InsureWhatMatters from '@salesforce/label/c.PBP_ZA_InsureWhatMatters';
import YourCar from '@salesforce/label/c.PBP_ZA_YourCar';
import YourHome from '@salesforce/label/c.PBP_ZA_YourHome';
import YourIncome from '@salesforce/label/c.PBP_ZA_YourIncome';
import YourFuture from '@salesforce/label/c.PBP_ZA_YourFuture';
import willis from '@salesforce/label/c.PBP_ZA_Willis';
import estates from '@salesforce/label/c.PBP_ZA_Estates';
import trusts from '@salesforce/label/c.PBP_ZA_Trusts';
import Yourdebt from '@salesforce/label/c.PBP_ZA_Yourdebt';
import WaysToBank from '@salesforce/label/c.PBP_ZA_WaysToBank';
import SelfServiceBanking from '@salesforce/label/c.PBP_ZA_SelfServiceBanking';
import snapscanfillonline from '@salesforce/label/c.PBP_ZA_SnapscanAtTheFillOnline';
import InnovativePaymentSolution from '@salesforce/label/c.PBP_ZA_InnovativePaymentSolution';
import tagyourphonewithsamsung from '@salesforce/label/c.PBP_ZA_TagYourPhoneWithSamsung';
import shoponlinewithmasterpass from '@salesforce/label/c.PBP_ZA_ShopOnlineWithMasterpass';
import HelpCentre from '@salesforce/label/c.PBP_ZA_HelpCentre';
import MyUpdates from '@salesforce/label/c.PBP_ZA_MyUpdates';
import PBP_ZA_DigiME from '@salesforce/label/c.PBP_ZA_DigiME';
import CustomerSolutions from '@salesforce/label/c.PBP_ZA_CustomerSolutions';
import DebtManagementSolutions from '@salesforce/label/c.PBP_ZA_DebtManagementSolutions';
import DebtCareCenter from '@salesforce/label/c.PBP_ZA_DebtCareCenter';
import DeceasedEstates from '@salesforce/label/c.PBP_ZA_DeceasedEstates';
import standardbankurl from '@salesforce/label/c.PBP_ZA_StandardBankUrl';
import appgalleryhuawai from '@salesforce/label/c.PBP_ZA_AppgalleryHuawai';
import Standardbankinsuranceapp from '@salesforce/label/c.PBP_ZA_Standardbankinsuranceapp';
import standardbankmobileurl from '@salesforce/label/c.PBP_ZA_StandardBankMobileUrl';
import corporateurl from '@salesforce/label/c.PBP_ZA_CorporateUrl';
import BankSafely from '@salesforce/label/c.PBP_ZA_BankSafely';
import ScamAndFraud from '@salesforce/label/c.PBP_ZA_ScamAndFraud';
import Shop from '@salesforce/label/c.PBP_ZA_Shop';
import StandardBankMobile from '@salesforce/label/c.PBP_ZA_StandardBankMobile';
import StandardBankDevices from '@salesforce/label/c.PBP_ZA_StandardBankDevices';
import UcontRewardsTravelMAll from '@salesforce/label/c.PBP_ZA_UcontRewardsTravelMAll';
import YourSelf from '@salesforce/label/c.PBP_ZA_YourSelf';
import funeralplans from '@salesforce/label/c.PBP_ZA_FuneralPlans';
import lifecover from '@salesforce/label/c.PBP_ZA_LifeCover';
import UcountRewardsRetailersOnline from '@salesforce/label/c.PBP_ZA_UcountRewardsRetailersOnline';
import UcountRewards from '@salesforce/label/c.PBP_ZA_UcountRewards';
import Learn from '@salesforce/label/c.PBP_ZA_Learn';
import Buisness from '@salesforce/label/c.PBP_ZA_Buisness';
import PBP_ZA_Institutions from '@salesforce/label/c.PBP_ZA_Institutions';
import productsAndService from '@salesforce/label/c.PBP_ZA_productsAndService';
import Product_Bank_BreadCrumb_Bank_with_Us from '@salesforce/label/c.PBP_ZA_Product_Bank_BreadCrumb_Bank_with_Us';
import Bizconnect from '@salesforce/label/c.PBP_ZA_Bizconnect2';
import Tradeclub from '@salesforce/label/c.PBP_ZA_Tradeclub';
import Covid from '@salesforce/label/c.PBP_ZA_Covid';
import CorporatesInstitutions from '@salesforce/label/c.PBP_ZA_CorporatesInstitutions';
import Wealth from '@salesforce/label/c.PBP_ZA_Wealth';
import PBP_ZA_Buisness from '@salesforce/label/c.PBP_ZA_Buisness';
import Corporates from '@salesforce/label/c.PBP_ZA_Corporates';
import YourAccounts from '@salesforce/label/c.PBP_ZA_YourAccounts';
import SignInto from '@salesforce/label/c.PBP_ZA_SignInto';
import SignIn from '@salesforce/label/c.PBP_ZA_SignIn';
import Protect_yourself from '@salesforce/label/c.PBP_ZA_Protect_yourself';
import PBP_ZA_COVID19 from '@salesforce/label/c.PBP_ZA_COVID19';
import FraudLine from '@salesforce/label/c.PBP_ZA_FraudLine';
import International from '@salesforce/label/c.PBP_ZA_International';
import LostOrStolenCards from '@salesforce/label/c.PBP_ZA_LostOrStolenCards';
import ComplimentsAndComplaints from '@salesforce/label/c.PBP_ZA_ComplimentsAndComplaints';
import GiveUsCall from '@salesforce/label/c.PBP_ZA_GiveUsCall';
import SouthAfricaNumber2 from '@salesforce/label/c.PBP_ZA_SouthAfricaNumber2';
import SouthAfricaNumber1 from '@salesforce/label/c.PBP_ZA_SouthAfricaNumber1';
import InternationalNumber from '@salesforce/label/c.PBP_ZA_InternationalNumber';
import GetInTouch from '@salesforce/label/c.PBP_ZA_GetInTouch';
import InternationalNumber2 from '@salesforce/label/c.PBP_ZA_InternationalNumber2';
import GetToKnowUs from '@salesforce/label/c.PBP_ZA_GetToKnowUs';
import SbBankApp from '@salesforce/label/c.PBP_ZA_SbBankApp';
import NewsAndMedia from '@salesforce/label/c.PBP_ZA_NewsAndMedia';
import InvestorRelations from '@salesforce/label/c.PBP_ZA_InvestorRelations';
import StandardBankGroup from '@salesforce/label/c.PBP_ZA_StandardBankGroup';
import WhoWeSponsor from '@salesforce/label/c.PBP_ZA_WhoWeSponsor';
import WhoWeAre from '@salesforce/label/c.PBP_ZA_WhoWeAre';
import FindABranch from '@salesforce/label/c.PBP_ZA_FindABranch';
import BuildACareerWithUs from '@salesforce/label/c.PBP_ZA_BuildACareerWithUs';
import JoinOurInternationalTeam from '@salesforce/label/c.PBP_ZA_JoinOurInternationalTeam';
import ViewOpportunities from '@salesforce/label/c.PBP_ZA_ViewOpportunities';
import NeedHelpWithOneOfOurProductsOr from '@salesforce/label/c.PBP_ZA_NeedHelpWithOneOfOurProductsOr';
import Start from '@salesforce/label/c.PBP_ZA_Start';
import Services from '@salesforce/label/c.PBP_ZA_Services';
import VisitOurCommunity from '@salesforce/label/c.PBP_ZA_VisitOurCommunity';
import GetDetailsOnStatus from '@salesforce/label/c.PBP_ZA_GetDetailsOnStatus';
import ToolsAndPlatforms from '@salesforce/label/c.PBP_ZA_ToolsAndPlatforms';
import StatusPage from '@salesforce/label/c.PBP_ZA_StatusPage';
import PhysicalAddress from '@salesforce/label/c.PBP_ZA_PhysicalAddress';
import SimmondsStreetselbyjonannesburg from '@salesforce/label/c.PBP_ZA_SimmondsStreet_selby_jonannesburg';
import WeWantYourFeedback from '@salesforce/label/c.PBP_ZA_WeWantYourFeedback';
import GotAComplimentOrComplaint from '@salesforce/label/c.PBP_ZA_GotAComplimentOrComplaint';
import LetUsKnow from '@salesforce/label/c.PBP_ZA_LetUsKnow';
import SecurityCentre from '@salesforce/label/c.PBP_ZA_SecurityCentre';
import Regulatory from '@salesforce/label/c.PBP_ZA_Regulatory';
import Legal from '@salesforce/label/c.PBP_ZA_Legal';
import ManageCookies from '@salesforce/label/c.PBP_ZA_ManageCookies';
import Terms from '@salesforce/label/c.PBP_ZA_Terms';
import Conditions from '@salesforce/label/c.PBP_ZA_Conditions';
import Pricing from '@salesforce/label/c.PBP_ZA_Pricing';
import StandardBankFootermsg from '@salesforce/label/c.PBP_ZA_StandardBankFootermsg';
import linkedinurl from '@salesforce/label/c.PBP_ZA_LinkedinUrl';
import youtubeurl from '@salesforce/label/c.PBP_ZA_YoutubeUrl';
import facebookurl from '@salesforce/label/c.PBP_ZA_FacebookUrl';
import twitterurl from '@salesforce/label/c.PBP_ZA_TwitterUrl';
import whatsappurl from '@salesforce/label/c.PBP_ZA_Whatsapp';
import ucountsstandardurl from '@salesforce/label/c.PBP_ZA_UcountStandardbankUrl';
import reportingstandardurl from '@salesforce/label/c.PBP_ZA_ReportingStandardUrl';
import standardbankcomurl from '@salesforce/label/c.PBP_ZA_Standardbankcomurl';
import sponsershipstandardurl from '@salesforce/label/c.PBP_ZA_SponsorshipsStandardUrl';
import communitystandardbankurl from '@salesforce/label/c.PBP_ZA_CommunityStandardbanUrl';
import statuspagestandardbankurl from '@salesforce/label/c.PBP_ZA_StatuspageStandardbank';
import googleplayurl from '@salesforce/label/c.PBP_ZA_PlayGooglePhone';
import appleurl from '@salesforce/label/c.PBP_ZA_AppsAppleStandardUrl';
import SANumber1 from '@salesforce/label/c.PBP_ZA_SouthAfricanNumberUrl';
import SAInternationalNumber1 from '@salesforce/label/c.PBP_ZA_SAInternationalNumberUrl';
import SANumber2 from '@salesforce/label/c.PBP_ZA_SANumberUrl';
import SAInternationalNumber2 from '@salesforce/label/c.PBP_ZA_Number';
import SeeAllAccounts from '@salesforce/label/c.PBP_ZA_SeeAllAccount';
import CompareAccounts from '@salesforce/label/c.PBP_ZA_CompareAccounts';
import ManagingYourAccount from '@salesforce/label/c.PBP_ZA_ManagingYourAccount';
import SavingAndInvestment from '@salesforce/label/c.PBP_ZA_SavingAndInvestment';
import PBP_ZA_SeeAllCards from '@salesforce/label/c.PBP_ZA_SeeAllCards';
import CompareCards from '@salesforce/label/c.PBP_ZA_CompareCards';
import ManagingYourCard from '@salesforce/label/c.PBP_ZA_ManagingYourCard';
import SavingAndInvestmenProduct from '@salesforce/label/c.PBP_ZA_SavingAndInvestmentProduct';
import GlobalWallet from '@salesforce/label/c.PBP_ZA_GlobalWallet';
import SnapScanWallet from '@salesforce/label/c.PBP_ZA_SnapScanWallet';
import ForeignNotes from '@salesforce/label/c.PBP_ZA_ForeignNotes';
import MoneyGram from '@salesforce/label/c.PBP_ZA_MoneyGram';
import InternationalPayments from '@salesforce/label/c.PBP_ZA_InternationlPayments';
import TemporaryResidentBanking from '@salesforce/label/c.PBP_ZA_TemporaryResidenBanking';
import NonResidentBanking from '@salesforce/label/c.PBP_ZA_NonResidentBanking';
import securitycentre from '@salesforce/label/c.PBP_ZA_Centre';
import ourrewardretailers from '@salesforce/label/c.PBP_ZA_OurRewardRetailers';
import bankMobile from '@salesforce/label/c.PBP_ZA_BankMobile';
import bankDevices from '@salesforce/label/c.PBP_ZA_BankDevices';
import ucountrewardsonline from '@salesforce/label/c.PBP_ZA_UcountRewardsRetailOnline';
import buyingahome from '@salesforce/label/c.PBP_ZA_BuyingAHome';
import homeservicespropertyguide from '@salesforce/label/c.PBP_ZA_HomeServicesPropertyGuide';
import buildingahouse from '@salesforce/label/c.PBP_Za_BuildingAHouse';
import settingupdanaccessbond from '@salesforce/label/c.PBP_Za_SettingUpAnAccessBond';
import extendingyourhomeloan from '@salesforce/label/c.PBP_ZA_ExtendingYourHomeLoan';
import managingyourbond from '@salesforce/label/c.PBP_ZA_ManagingYourBond';
import calculators from '@salesforce/label/c.PBP_ZA_Calculators';
import tieredrates from '@salesforce/label/c.PBP_ZA_TieredRates';
import pensionbackedloans from '@salesforce/label/c.PBP_ZA_PensionBackedLoans';
import seeallloans from '@salesforce/label/c.PBP_ZA_SeeAllLoans';
import comparepersonalloans from '@salesforce/label/c.PBP_ZA_ComparePersonalLoans';
import loancalculator from '@salesforce/label/c.PBP_ZA_LoanCalculator';
import overdraftwithoutquote from '@salesforce/label/c.PBP_ZA_OverdraftWithoutquote';
import vehiclefinancing from '@salesforce/label/c.PBP_ZA_VehicleFinancingCaps';
import seefinancingoptions from '@salesforce/label/c.PBP_ZA_SeeFinancingOptions';
import vehiclefinancingcalculators from '@salesforce/label/c.PBP_ZA_VehicleFinanceCalculators';
import comparecards from '@salesforce/label/c.PBP_ZA_CompareCards';
import seeallstudentloans from '@salesforce/label/c.PBP_ZA_SeeAllStudentLoans';
import savingsandinvestmentproductionfilter from '@salesforce/label/c.PBP_SavingsAndInvestmentProductFilter';
import shariahinvestmentaccount from '@salesforce/label/c.PBP_ZA_ShariahInvestmentAccount';
import carandhome from '@salesforce/label/c.PBP_ZA_CarAndHome';
import insurance from '@salesforce/label/c.PBP_ZA_Insurance';
import warranties from '@salesforce/label/c.PBP_ZA_Warranties';
import dentandscratch from '@salesforce/label/c.PBP_ZA_DentAndScratch';
import homecontents from '@salesforce/label/c.PBP_ZA_HomeContents';
import buildinginsurance from '@salesforce/label/c.PBP_ZA_BuildingInsurance';
import propertyinspection from '@salesforce/label/c.PBP_ZA_PropertyInspection';
import smartgeysersolution from '@salesforce/label/c.PBP_ZA_SmartGeyserSolution';
import salaryprotection from '@salesforce/label/c.PBP_ZA_SalaryProtection';
import disabilitycover from '@salesforce/label/c.PBP_ZA_DisabilityCover';
import seriousillnesscover from '@salesforce/label/c.PBP_ZA_SeriousIllnessCover';
import beneficiarycare from '@salesforce/label/c.PBP_ZA_BeneficiaryCare';
import shariahfiduciaryservices from '@salesforce/label/c.PBP_ZA_shariahFiduciaryServicesq';
import flexiablelifeplan from '@salesforce/label/c.PBP_ZA_FlexiableLifePlan';
import personalaccident from '@salesforce/label/c.PBP_ZA_PersonalAccident';
import legalassist from '@salesforce/label/c.PBP_ZA_LegalAssist';
import travelinsurance from '@salesforce/label/c.PBP_ZA_TravelInsurance';
import loans from '@salesforce/label/c.PBP_ZA_Loans';
import PBP_ZA_MobileApp from '@salesforce/label/c.PBP_ZA_MobileApp';
import PBP_ZA_siteUrl from '@salesforce/label/c.PBP_ZA_siteURL';
import financeshortfall from '@salesforce/label/c.PBP_ZA_CarFinanceShortfall';
import carfinanceprotection from '@salesforce/label/c.PBP_ZA_CarFinanceProtection';
import homeloanprotection from '@salesforce/label/c.PBP_ZA_HomeLoanProtection';
import onlinebanking from '@salesforce/label/c.PBP_ZA_OnlineBanking';
import smartyourcard from '@salesforce/label/c.PBP_ZA_SmartYourSmartId';
import serviceupdated from '@salesforce/label/c.PBP_ZA_ServicesUpdates';
import telephone from '@salesforce/label/c.PBP_ZA_TelePhone';
import atm from '@salesforce/label/c.PBP_ZA_ATM';
import cellphone from '@salesforce/label/c.PBP_ZA_CellPhone';
import bankingapp from '@salesforce/label/c.PBP_ZA_BankingApp';
import tagyourcardtopay from '@salesforce/label/c.PBP_ZA_TagYourCardToPay';
import sendinstantmoney from '@salesforce/label/c.PBP_ZA_SendInstantMoney';
import paywithbills from '@salesforce/label/c.PBP_ZA_PayWithMyBills';
import virtualcard from '@salesforce/label/c.PBP_ZA_VirtualCard';
import escrowservices from '@salesforce/label/c.PBP_ZA_EscrowServices';
import myupdates from '@salesforce/label/c.PBP_ZA_MyupdatesCaps';
import applepay from '@salesforce/label/c.PBP_ZA_ApplyPay';
import linkedin from '@salesforce/resourceUrl/PBP_ThemeOverrides';
import youtube from '@salesforce/resourceUrl/PBP_ThemeOverrides';
import facebook from '@salesforce/resourceUrl/PBP_ThemeOverrides';
import twitter from '@salesforce/resourceUrl/PBP_ThemeOverrides';
import whatAppIcon from '@salesforce/resourceUrl/PBP_ThemeOverrides';
import applestore from '@salesforce/resourceUrl/PBP_ThemeOverrides';
import googleplay from '@salesforce/resourceUrl/PBP_ThemeOverrides';
import Huwai from '@salesforce/resourceUrl/PBP_ThemeOverrides';
import appsnapshot from '@salesforce/resourceUrl/PBP_ThemeOverrides';
import standardbank from '@salesforce/resourceUrl/PBP_ThemeOverrides';
import fetchSearchProducts from '@salesforce/apex/AOB_Api_SearchProducts.searchTerm';
import PBP_WaysToBank from '@salesforce/label/c.PBP_ZA_WaysToBank1';
import PBP_ZA_ATTORNEYACCOUNTS from '@salesforce/label/c.PBP_ZA_ATTORNEYACCOUNTS';
import PBP_ZA_AttorneysTrustAccount from '@salesforce/label/c.PBP_ZA_AttorneysTrustAccount';
import PBP_ZA_Product_Bank_Card_Executors_Title from '@salesforce/label/c.PBP_ZA_Product_Bank_Card_Executors_Title';
import PBP_ZA_Product_Bank_Card_ThirdParty_Title from '@salesforce/label/c.PBP_ZA_Product_Bank_Card_ThirdParty_Title';
import PBP_ZA_PropertyPractitionersTrustAccount from '@salesforce/label/c.PBP_ZA_PropertyPractitionersTrustAccount';
import PBP_ZA_CompareTrustAccount from '@salesforce/label/c.PBP_ZA_CompareTrustAccount';
import PBP_ZA_BUSINESSANDCORPORATECREDITCARDS from '@salesforce/label/c.PBP_ZA_BUSINESSANDCORPORATECREDITCARDS';
import PBP_ZA_SWITCHYOURBANKACCOUNT from '@salesforce/label/c.PBP_ZA_SWITCHYOURBANKACCOUNT';
import PBP_ZA_BusinessTravelWalletCard from '@salesforce/label/c.PBP_ZA_BusinessTravelWalletCard';
import PBP_ZA_ExchangeContracts from '@salesforce/label/c.PBP_ZA_ExchangeContracts';
import PBP_ZA_ForeignNotesForBusiness from '@salesforce/label/c.PBP_ZA_ForeignNotesForBusiness';
import PBP_ZA_SHARI_AHBANKING from '@salesforce/label/c.PBP_ZA_SHARI_AHBANKING';
import PBP_ZA_ProductScreen_Business_Loans from '@salesforce/label/c.PBP_ZA_ProductScreen_Business_Loans';
import PBP_ZA_BusinessOverdraft from '@salesforce/label/c.PBP_ZA_BusinessOverdraft';
import PBP_ZA_BizFlexLoan from '@salesforce/label/c.PBP_ZA_BizFlexLoan';
import PBP_ZA_eMarketTrader from '@salesforce/label/c.PBP_ZA_eMarketTrader';
import PBP_ZA_BusinessRevolvingloan from '@salesforce/label/c.PBP_ZA_BusinessRevolvingloan';
import PBP_ZA_Businesstermloan from '@salesforce/label/c.PBP_ZA_Businesstermloan';
import PBP_ZA_Fixedrepaymentsbusinessloan from '@salesforce/label/c.PBP_ZA_Fixedrepaymentsbusinessloan';
import PBP_ZA_Agriculturalproductionloan from '@salesforce/label/c.PBP_ZA_Agriculturalproductionloan';
import PBP_ZA_ProductScreen_Vehicle from '@salesforce/label/c.PBP_ZA_ProductScreen_Vehicle';
import PBP_ZA_Foreignorlocalgoods from '@salesforce/label/c.PBP_ZA_Foreignorlocalgoods';
import PBP_ZA_CapitalEquipment from '@salesforce/label/c.PBP_ZA_CapitalEquipment';
import PBP_ZA_Commercialvehicles from '@salesforce/label/c.PBP_ZA_Commercialvehicles';
import PBP_ZA_Accessfinancecalculator from '@salesforce/label/c.PBP_ZA_Accessfinancecalculator';
import PBP_ZA_COMMERCIALPROPERTYFINANCING from '@salesforce/label/c.PBP_ZA_COMMERCIALPROPERTYFINANCING';
import PBP_ZA_PropertyFinance from '@salesforce/label/c.PBP_ZA_PropertyFinance';
import PBP_ZA_Forowneroccupiers from '@salesforce/label/c.PBP_ZA_Forowneroccupiers';
import PBP_ZA_Forinvestors from '@salesforce/label/c.PBP_ZA_Forinvestors';
import PBP_ZA_PECIALISEDFINANCING from '@salesforce/label/c.PBP_ZA_PECIALISEDFINANCING';
import PBP_ZA_Discloseddebtorfinance from '@salesforce/label/c.PBP_ZA_Discloseddebtorfinance';
import PBP_Nondiscloseddebtorfinance from '@salesforce/label/c.PBP_Nondiscloseddebtorfinance';
import PBP_ZA_BusinessBanking from '@salesforce/label/c.PBP_ZA_BusinessBanking';
import PBP_ZA_YOURBUSINESS from '@salesforce/label/c.PBP_ZA_YOURBUSINESS';
import PBP_ZA_CORPORATERISK from '@salesforce/label/c.PBP_ZA_CORPORATERISK';
import PBP_ZA_YOURAGRIBUSINESS from '@salesforce/label/c.PBP_ZA_YOURAGRIBUSINESS';
import PBP_ZA_COMMERCIALPROPERTY from '@salesforce/label/c.PBP_ZA_COMMERCIALPROPERTY';
import PBP_ZA_YOURVEHICLES from '@salesforce/label/c.PBP_ZA_YOURVEHICLES';
import PBP_ZA_ENGINEERINGRISK from '@salesforce/label/c.PBP_ZA_ENGINEERINGRISK';
import PBP_ZA_NEWCONTRACTS from '@salesforce/label/c.PBP_ZA_NEWCONTRACTS';
import PBP_ZA_NEWCONTRACTSMOBILE from '@salesforce/label/c.PBP_ZA_NEWCONTRACTSMOBILE';
import PBP_ZA_CARGO from '@salesforce/label/c.PBP_ZA_CARGO';
import PBP_ZA_CASH from '@salesforce/label/c.PBP_ZA_CASH';
import PBP_ZA_EVENTS from '@salesforce/label/c.PBP_ZA_EVENTS';
import PBP_ZA_DIRECTORSANDOFFICERS from '@salesforce/label/c.PBP_ZA_DIRECTORSANDOFFICERS';
import PBP_YourPeople from '@salesforce/label/c.PBP_YourPeople';
import PBP_ZA_COMMERCIALCYBERINSURANCE from '@salesforce/label/c.PBP_ZA_COMMERCIALCYBERINSURANCE';
import 	PBP_ZA_COMMERCIALCYBERINSURANCEMobile from '@salesforce/label/c.PBP_ZA_COMMERCIALCYBERINSURANCEMobile';
import PBP_ZA_WORKPLACESOLUTIONS from '@salesforce/label/c.PBP_ZA_WORKPLACESOLUTIONS';
import PBP_ZA_Employervaluebanking from '@salesforce/label/c.PBP_ZA_Employervaluebanking';
import PBP_ZA_InstantMoneybulkpayments from '@salesforce/label/c.PBP_ZA_InstantMoneybulkpayments';
import PBP_ZA_PayCard from '@salesforce/label/c.PBP_ZA_PayCard';
import PBP_ZA_Prepaidcardsolutions from '@salesforce/label/c.PBP_ZA_Prepaidcardsolutions';
import PBP_ZA_SalaryPayments from '@salesforce/label/c.PBP_ZA_SalaryPayments';
import PBP_ZA_PayrollandHRSolutions from '@salesforce/label/c.PBP_ZA_PayrollandHRSolutions';
import PBP_ZA_SPECIALISED from '@salesforce/label/c.PBP_ZA_SPECIALISED';
import PBP_ZA_Merchantsolutions from '@salesforce/label/c.PBP_ZA_Merchantsolutions';

import PBP_ZA_Cashsolutions from '@salesforce/label/c.PBP_ZA_Cashsolutions';
import PBP_ZA_Debitordercollections from '@salesforce/label/c.PBP_ZA_Debitordercollections';
import PBP_ZA_Franchising from '@salesforce/label/c.PBP_ZA_Franchising';
import PBP_ZA_eCommercesolutions from '@salesforce/label/c.PBP_ZA_eCommercesolutions';
import PBP_ZA_CashAdvance from '@salesforce/label/c.PBP_ZA_CashAdvance';
import PBP_ZA_FLEETMANAGEMENT from '@salesforce/label/c.PBP_ZA_FLEETMANAGEMENT';
import PBP_ZA_Manageyourfleet from '@salesforce/label/c.PBP_ZA_Manageyourfleet';
import PBP_Fleetvalueaddedservices from '@salesforce/label/c.PBP_Fleetvalueaddedservices';
import PBP_ZA_Onlineaccountforms from '@salesforce/label/c.PBP_ZA_Onlineaccountforms';
import PBP_ZA_INDUSTRY from '@salesforce/label/c.PBP_ZA_INDUSTRY';
import PBP_ZA_Agribusiness from '@salesforce/label/c.PBP_ZA_Agribusiness';
import PBP_ZA_Property from '@salesforce/label/c.PBP_ZA_Property';
import PBP_ZA_Manufacturing from '@salesforce/label/c.PBP_ZA_Manufacturing';
import PBP_ZA_Retailandwholesale from '@salesforce/label/c.PBP_ZA_Retailandwholesale';
import PBP_ZA_Naturalresources from '@salesforce/label/c.PBP_ZA_Naturalresources';
import PBP_ZA_Transportandlogistics from '@salesforce/label/c.PBP_ZA_Transportandlogistics';
import PBP_ZA_Construction from '@salesforce/label/c.PBP_ZA_Construction';
import PBP_ZA_TRADEPOINT from '@salesforce/label/c.PBP_ZA_TRADEPOINT';
import PBP_TradeClub2 from '@salesforce/label/c.PBP_TradeClub2';
import PBP_ZA_TradeSuite from '@salesforce/label/c.PBP_ZA_TradeSuite';
import PBP_ZA_Online from '@salesforce/label/c.PBP_ZA_Online';
import PBP_ZA_Personalinformation from '@salesforce/label/c.PBP_ZA_Personalinformation';

import PBP_ZA_TradeFinance from '@salesforce/label/c.PBP_ZA_TradeFinance';
import PBP_ZA_AfricaChinaTrade from '@salesforce/label/c.PBP_ZA_AfricaChinaTrade';
import PBP_ZA_ATMs from '@salesforce/label/c.PBP_ZA_ATMs';
import PBP_ZA_BusinessOnline from '@salesforce/label/c.PBP_ZA_BusinessOnline';
import PBP_ZA_ProductScreen_Internet_Banking from '@salesforce/label/c.PBP_ZA_ProductScreen_Internet_Banking';
import PBP_ZA_Telephonebanking from '@salesforce/label/c.PBP_ZA_Telephonebanking';
import PBP_ZA_DIGITALBANKING from '@salesforce/label/c.PBP_ZA_DIGITALBANKING';
import PBP_ZA_INNOVATIVEPAYMENT from '@salesforce/label/c.PBP_ZA_INNOVATIVEPAYMENT';
import PBP_ZA_OntheATM from '@salesforce/label/c.PBP_ZA_OntheATM';
import PBP_ZA_Onyourcellphone from '@salesforce/label/c.PBP_ZA_Onyourcellphone';
import PBP_ZA_GuardyourPIN from '@salesforce/label/c.PBP_ZA_GuardyourPIN';
import PBP_ZA_Debitorders from '@salesforce/label/c.PBP_ZA_Debitorders';
import PBP_ZA_AccountVerficationServices from '@salesforce/label/c.PBP_ZA_AccountVerficationServices';
import PBP_ZA_SCAMSANDFRAUD from '@salesforce/label/c.PBP_ZA_SCAMSANDFRAUD';
import PBP_ZA_Scams from '@salesforce/label/c.PBP_ZA_Scams';
import PBP_ZA_Cardfraud from '@salesforce/label/c.PBP_ZA_Cardfraud';
import PBP_ZA_TradeBarometer from '@salesforce/label/c.PBP_ZA_TradeBarometer';
import PBP_ZA_OnlineShareTrade from '@salesforce/label/c.PBP_ZA_OnlineShareTrade';
import PBP_ZA_ForeignExchangeRates from '@salesforce/label/c.PBP_ZA_ForeignExchangeRates';
import PBP_ZA_INSURANCEONLINE from '@salesforce/label/c.PBP_ZA_INSURANCEONLINE';
import PBP_ZA_STOCKBROKING from '@salesforce/label/c.PBP_ZA_STOCKBROKING';
import PBP_ZA_MARKETDATA from '@salesforce/label/c.PBP_ZA_MARKETDATA';
import PBP_ZA_WEBTRADER from '@salesforce/label/c.PBP_ZA_WEBTRADER';
import PBP_ZA_LIFEINSURANCEONLINE from '@salesforce/label/c.PBP_ZA_LIFEINSURANCEONLINE';
import PBP_ZA_MERCHANTONLINE from '@salesforce/label/c.PBP_ZA_MERCHANTONLINE';
import PBP_ZA_TRADEONLINE from '@salesforce/label/c.PBP_ZA_TRADEONLINE';
import PBP_ZA_INTERNATIONALBANKING from '@salesforce/label/c.PBP_ZA_INTERNATIONALBANKING';
import PBP_ZA_STANLIBONLINE from '@salesforce/label/c.PBP_ZA_STANLIBONLINE';
import PBP_ZA_SecuritiesStandardbankUrl from '@salesforce/label/c.PBP_ZA_SecuritiesStandardbankUrl';
import PBP_ZA_GetforexServeltUrl from '@salesforce/label/c.PBP_ZA_GetforexServeltUrl';
import PBP_ZA_LandingUrl from '@salesforce/label/c.PBP_ZA_LandingUrl';
import PBP_ZA_STOCKBROKINGURL from '@salesforce/label/c.PBP_ZA_STOCKBROKINGURL';
import PBP_ZA_MARKETDATAURL from '@salesforce/label/c.PBP_ZA_MARKETDATAURL';
import PBP_ZA_WEBTRADERURL from '@salesforce/label/c.PBP_ZA_WEBTRADERURL';
import PBP_ZA_LIFEINSURANCEONLINEURL from '@salesforce/label/c.PBP_ZA_LIFEINSURANCEONLINEURL';
import PBP_ZA_MERCHANTONLINEURL from '@salesforce/label/c.PBP_ZA_MERCHANTONLINEURL';
import PBP_ZA_TRADEONLINEURL from '@salesforce/label/c.PBP_ZA_TRADEONLINEURL';
import PBP_ZA_INTERNATIONALBANKINGURL from '@salesforce/label/c.PBP_ZA_INTERNATIONALBANKINGURL';
import PBP_ZA_STANLIBONLINEURL from '@salesforce/label/c.PBP_ZA_STANLIBONLINEURL';
import PBP_ZA_Bankersacceptance from '@salesforce/label/c.PBP_ZA_Bankersacceptance';
import FlagImages from '@salesforce/resourceUrl/PBP_ThemeOverrides';
import PBP_ZA_chooseURcountry from '@salesforce/label/c.PBP_ZA_chooseURcountry';
import PBP_ZA_Africa from '@salesforce/label/c.PBP_ZA_Africa';
import PBP_ZA_Europe from '@salesforce/label/c.PBP_ZA_Europe';
import PBP_ZA_Asia from '@salesforce/label/c.PBP_ZA_Asia'
import PBP_ZA_America from '@salesforce/label/c.PBP_ZA_America';
import PBP_ZA_CommericalProperty from '@salesforce/label/c.PBP_ZA_CommericialProperty';
import PBP_ZA_CommericalPropertyInsurance from '@salesforce/label/c.PBP_ZA_CommericalCyberInsurance';
import PBP_ZA_BUSINESSSAVINGANDINVESTMENTACCOUNTS from '@salesforce/label/c.PBP_ZA_BUSINESSSAVINGANDINVESTMENTACCOUNTS';
import PBP_ZA_CommercialProperlyfinance from '@salesforce/label/c.PBP_ZA_CommericialProperlyFinance';
import PBP_ZA_TrustAccounts from '@salesforce/label/c.PBP_ZA_TrustAccounts';
import PBP_ZA_breadcrumbtile from '@salesforce/label/c.PBP_ZA_Product_BreadCrumb_Title';
import PBP_ZA_sbinsuranceapp from '@salesforce/label/c.PBP_ZA_SBInsurancApp';

import PBP_ZA_Scam_And_Fraud from '@salesforce/label/c.PBP_ZA_Scam_And_Fraud';
import PBP_ZA_innovative from '@salesforce/label/c.PBP_ZA_innovative';
import PBP_ZA_DigitalBankings from '@salesforce/label/c.PBP_ZA_DigitalBankings';
import PBP_ZA_IndustryMobile from '@salesforce/label/c.PBP_ZA_IndustryMobile';
import PBP_ZA_FleetManagementMobile from '@salesforce/label/c.PBP_ZA_FleetManagementMobile';
import PBP_ZA_SpecialisedMobile from '@salesforce/label/c.PBP_ZA_SpecialisedMobile';
import PBP_ZA_WorkplaceSolutionsMobile from '@salesforce/label/c.PBP_ZA_WorkplaceSolutionsMobile';
import PBP_ZA_YourPeopleMobile from '@salesforce/label/c.PBP_ZA_YourPeopleMobile';
import PBP_ZA_DirectorsAndOfficersMobile from '@salesforce/label/c.PBP_ZA_DirectorsAndOfficersMobile';
import PBP_ZA_EventsMobile from '@salesforce/label/c.PBP_ZA_EventsMobile';
import PBP_ZA_CashMobile from '@salesforce/label/c.PBP_ZA_CashMobile';
import PBP_ZA_CargoMobile from '@salesforce/label/c.PBP_ZA_CargoMobile';
import PBP_ZA_EngineeringRiskMobile from '@salesforce/label/c.PBP_ZA_EngineeringRiskMobile';
import PBP_ZA_YourVehiclesMobile from '@salesforce/label/c.PBP_ZA_YourVehiclesMobile';
import PBP_ZA_YourAgriBusinessMobile from '@salesforce/label/c.PBP_ZA_YourAgriBusinessMobile';
import PBP_ZA_CorporateRiskMobile from '@salesforce/label/c.PBP_ZA_CorporateRiskMobile';
import PBP_ZA_LoansMobile from '@salesforce/label/c.PBP_ZA_LoansMobile';
import PBP_ZA_Your_BusinessMobile from '@salesforce/label/c.PBP_ZA_Your_BusinessMobile';
import PBP_ZA_BusinessSavingsMobile from '@salesforce/label/c.PBP_ZA_BusinessSavingsMobile';
import PBP_ZA_LoanCalculatorMobile from '@salesforce/label/c.PBP_ZA_LoanCalculatorMobile';
import PBP_ZA_SpecialisedFinancingMobile from '@salesforce/label/c.PBP_ZA_SpecialisedFinancingMobile';
import PBP_ZA_VehicleAndAssetMobile from '@salesforce/label/c.PBP_ZA_VehicleAndAssetMobile';
import PBP_ZA_BusinessLoansMobile from '@salesforce/label/c.PBP_ZA_BusinessLoansMobile';
import PBP_ZA_ShariahBankingMobile from '@salesforce/label/c.PBP_ZA_ShariahBankingMobile';
import PBP_ZA_SwitchYourBankAccountMobile from '@salesforce/label/c.PBP_ZA_SwitchYourBankAccountMobile';
import PBP_ZA_BusinessAndCorporateCreditCardsMobile from '@salesforce/label/c.PBP_ZA_BusinessAndCorporateCreditCardsMobile';
import PBP_ZA_BusinessBankAccountsMobile from '@salesforce/label/c.PBP_ZA_BusinessBankAccountsMobile';
import PBP_ZA_STANDARDBANKDEVICESMobile from '@salesforce/label/c.PBP_ZA_STANDARDBANKDEVICESMobile';
import PBP_ZA_STANDARDBANKMOBILEMobile from '@salesforce/label/c.PBP_ZA_STANDARDBANKMOBILEMobile';
import PBP_ZA_DeceasedEstatesMobile from '@salesforce/label/c.PBP_ZA_DeceasedEstatesMobile';
import PBP_ZA_DebtCareCentreMobile from '@salesforce/label/c.PBP_ZA_DebtCareCentreMobile';
import PBP_ZA_DebtManagementSolutionsMobile from '@salesforce/label/c.PBP_ZA_DebtManagementSolutionsMobile';
import PBP_ZA_CUSTOMERSOLUTIONSMobile from '@salesforce/label/c.PBP_ZA_CUSTOMERSOLUTIONSMobile';
import PBP_ZA_HelpCentreMobile from '@salesforce/label/c.PBP_ZA_HelpCentreMobile';
import PBP_ZA_StandardBankInsuranceAppMobile from '@salesforce/label/c.PBP_ZA_StandardBankInsuranceAppMobile';
import PBP_ZA_YourDebtMobile from '@salesforce/label/c.PBP_ZA_YourDebtMobile';
import PBP_ZA_YourFutureMobile from '@salesforce/label/c.PBP_ZA_YourFutureMobile';
import PBP_ZA_MyAppMobile from '@salesforce/label/c.PBP_ZA_MyAppMobile';
import PBP_ZA_SavingsAndInvestmentMobile from '@salesforce/label/c.PBP_ZA_SavingsAndInvestmentMobile';
import PBP_ZA_StudentLoansMobile from '@salesforce/label/c.PBP_ZA_StudentLoansMobile';
import PBP_ZA_PrepaidCardsMobile from '@salesforce/label/c.PBP_ZA_PrepaidCardsMobile';
import PBP_ZA_ForeignNationalsMobile from '@salesforce/label/c.PBP_ZA_ForeignNationalsMobile';
import PBP_ZA_WEALTHMANAGEMENTMobile from '@salesforce/label/c.PBP_ZA_WEALTHMANAGEMENTMobile';
import PBP_ZA_INVESTMENTSMobile from '@salesforce/label/c.PBP_ZA_INVESTMENTSMobile';
import PBP_ZA_INSURANCEMobile from '@salesforce/label/c.PBP_ZA_INSURANCEMobile';
import PBP_InternationalSolutionsMobileMobile from '@salesforce/label/c.PBP_InternationalSolutionsMobileMobile';
import PBP_ZA_CommericalCyberInsuranceMobile from '@salesforce/label/c.PBP_ZA_CommericalCyberInsuranceMobile';

export default class Pbp_comp_product_business_pages_theme_tablet_layout extends LightningElement {
    AfricaflagsFilter = [];
    EuropeflagsFilter = [];
    AsiaMiddleEastflagsFilter = [];
    AmericaflagsFilter = [];
    downArrowIcon = PRODUCT_SCREENS + '/assets/images/icon-arrow-accordian.svg';
    greaterThan_Icon = PRODUCT_SCREENS + '/assets/images/flechita.png';
    contianer_Custom;
    innerhtmlscer = false;
    result;

    baby_city = PRODUCT_SCREENS + '/assets/images/baby_city.png'; 
    car_service_city = PRODUCT_SCREENS + '/assets/images/car_service_city.png';
    Coastal_hire= PRODUCT_SCREENS + '/assets/images/Coastal_hire.png';
    Courier_Connexion= PRODUCT_SCREENS + '/assets/images/Courier_Connexion.png';
    Dis_Chem_Logo= PRODUCT_SCREENS + '/assets/images/Dis-Chem_Logo.png';
    ez_shuttle= PRODUCT_SCREENS + '/assets/images/ez_shuttle.png';
    fresh_stop= PRODUCT_SCREENS + '/assets/images/fresh_stop.png';
    Hirschs_logo= PRODUCT_SCREENS + '/assets/images/Hirschs_logo.png';
    KFC= PRODUCT_SCREENS + '/assets/images/KFC.png';
    makro= PRODUCT_SCREENS + '/assets/images/makro.png';
    makro_liquor= PRODUCT_SCREENS + '/assets/images/makro_liquor.png';
    Game_Logo= PRODUCT_SCREENS + '/assets/images/Game_Logo.png';
    altech_netstar= PRODUCT_SCREENS + '/assets/images/altech_netstar.png';
    netflorist= PRODUCT_SCREENS + '/assets/images/netflorist.png';
    Olympic_Cycles_logo= PRODUCT_SCREENS + '/assets/images/Olympic_Cycles_logo.png';
    Samsung_logo_white= PRODUCT_SCREENS + '/assets/images/Samsung_logo_white.png';
    showmax= PRODUCT_SCREENS + '/assets/images/showmax.png';
    Sweep_South= PRODUCT_SCREENS + '/assets/images/Sweep_South.png';
    The_Cross_Trainer_Logo= PRODUCT_SCREENS + '/assets/images/The_Cross_Trainer_Logo.png';
    tiger_wheel= PRODUCT_SCREENS + '/assets/images/tiger_wheel.png';
    wellness= PRODUCT_SCREENS + '/assets/images/wellness.png';
    wine= PRODUCT_SCREENS + '/assets/images/wine.png';
    Xtrend_Logo= PRODUCT_SCREENS + '/assets/images/Xtrend_Logo.png';
    XKIDS_Logo= PRODUCT_SCREENS + '/assets/images/XKIDS_Logo.png';
    zando= PRODUCT_SCREENS + '/assets/images/zando.png';
    
    rowstring_cls;
    cls = "slds-backdrop slds-backdrop_open";
    isOpenSection = false;
    isDesktopDevice = false;
    isTabletDevice = false;
    isMobileDevice = false;
    isCustomerSolutionBus = false;
    isSecurityCentreBusiness = false;
    showSec1 = false;
    personalIcon = false;
    businessIcon = false;
    prodAndServicesBusiness = false;
    shopPersonal = false;
    personalSec = false;
    isBankWithUs = false;
    isBorrowNeeds = false;
    isGrowYourMoney = false;
    isInsureWhatMatters = false;
    isWaysToBank = false;
    isCustomerSol = false;
    isSecurityCentre = false;
    isMouseOver = false;
    ismouseoversigninto = false;
    isHandleShop = false;
    isGrowyourMoneyleft = false;
    isWhatmatters = false;
    ismodalpopcountrycode = false;
    isWaysTobankleft = false;
    isCustomerSolutions = false;
    isSecurityCentreleft = false;
    isBorrowNeedsleft = false;
    ismouseOverdefault = false;
    @track searchkey;
    searchValue = '';
    @track isLoading = false;
    personalIcon = false;
    businessIconmb = false;
    isBizConnect = false;
    showSecMobile = false;
    isWealthcheck = false;
    isBankWithUsBusiness = false;
    isBorrowForyourNeeds = false;
    isGrowYourBusinessbus = false;
    isInsureWhatMattersBusiness =false;
    isWaysToBankBusiness = false;
    showResults;
    updatedcolshtmlcls1;
    updatedcolshtmlcls2;
    label = {
        PBP_ZA_Scam_And_Fraud,
        PBP_ZA_YourFutureMobile,
        PBP_ZA_innovative,
        PBP_ZA_DigitalBankings,
        PBP_ZA_IndustryMobile,
        PBP_ZA_FleetManagementMobile,
        PBP_ZA_SpecialisedMobile,
        PBP_ZA_WorkplaceSolutionsMobile,
        PBP_ZA_YourPeopleMobile,
        PBP_ZA_DirectorsAndOfficersMobile,
        PBP_ZA_EventsMobile,
        PBP_ZA_CashMobile,
        PBP_ZA_CargoMobile,
        PBP_ZA_EngineeringRiskMobile,
        PBP_ZA_YourVehiclesMobile,
        PBP_ZA_YourAgriBusinessMobile,
        PBP_ZA_CorporateRiskMobile,
        PBP_ZA_LoansMobile,
        PBP_ZA_Your_BusinessMobile,
        PBP_ZA_BusinessSavingsMobile,
        PBP_ZA_LoanCalculatorMobile,
        PBP_ZA_SpecialisedFinancingMobile,
        PBP_ZA_VehicleAndAssetMobile,
        PBP_ZA_BusinessLoansMobile,
        PBP_ZA_ShariahBankingMobile,
        PBP_ZA_BusinessAndCorporateCreditCardsMobile,
        PBP_ZA_SwitchYourBankAccountMobile,
        PBP_ZA_BusinessBankAccountsMobile,
        PBP_ZA_STANDARDBANKDEVICESMobile,
        PBP_ZA_STANDARDBANKMOBILEMobile,
        PBP_ZA_DeceasedEstatesMobile,
        PBP_ZA_DebtCareCentreMobile,
        PBP_ZA_DebtManagementSolutionsMobile,
        PBP_ZA_CUSTOMERSOLUTIONSMobile,
        PBP_ZA_HelpCentreMobile,
        PBP_ZA_StandardBankInsuranceAppMobile,
        PBP_ZA_YourDebtMobile,
        PBP_ZA_MyAppMobile,
        PBP_ZA_SavingsAndInvestmentMobile,
        PBP_ZA_StudentLoansMobile,
        PBP_ZA_PrepaidCardsMobile,
        PBP_InternationalSolutionsMobileMobile,
        PBP_ZA_ForeignNationalsMobile,
        PBP_ZA_WEALTHMANAGEMENTMobile,
        PBP_ZA_INVESTMENTSMobile,
        PBP_ZA_INSURANCEMobile,
        PBP_ZA_CommericalCyberInsuranceMobile,
        PBP_ZA_ATTORNEYACCOUNTS,
        Standardbankinsuranceapp,
        HelpCentre,
        PBP_ZA_breadcrumbtile,
        PBP_ZA_TrustAccounts,
        PBP_ZA_CommercialProperlyfinance,
        PBP_ZA_CommericalPropertyInsurance,
        PBP_ZA_CommericalProperty,
        InnovativePaymentSolution,
        PBP_ZA_CORPORATERISK,
        PBP_ZA_DigiME,
        PBP_ZA_sbinsuranceapp,
        PBP_ZA_Agribusiness,
        PBP_ZA_INTERNATIONALBANKINGURL,
        PBP_ZA_MARKETDATA,
        PBP_ZA_MARKETDATAURL,
        PBP_ZA_STOCKBROKINGURL,
        PBP_ZA_TRADEONLINEURL,
        PBP_ZA_TradeBarometer,
        PBP_ZA_INSURANCEONLINE,
        PBP_ZA_MERCHANTONLINEURL,
        PBP_ZA_WEBTRADERURL,
        PBP_ZA_LIFEINSURANCEONLINEURL,
        PBP_ZA_Scams,
        PBP_ZA_STANLIBONLINEURL,
        PBP_ZA_Bankersacceptance,
        PBP_ZA_Cardfraud,
        PBP_ZA_MERCHANTONLINE,
        PBP_ZA_STANLIBONLINE,
        PBP_ZA_INTERNATIONALBANKING,
        PBP_Fleetvalueaddedservices,
        PBP_ZA_Franchising,
        PBP_ZA_TRADEONLINE,
        PBP_ZA_Naturalresources,
        PBP_ZA_STOCKBROKING,
        PBP_ZA_LIFEINSURANCEONLINE,
        PBP_ZA_WEBTRADER,
        PBP_ZA_Transportandlogistics,
        PBP_ZA_TradeSuite,
        PBP_ZA_GetforexServeltUrl,
        PBP_ZA_LandingUrl,
        PBP_ZA_AfricaChinaTrade,
        PBP_ZA_OnlineShareTrade,
        PBP_ZA_TradeFinance,
        PBP_ZA_ForeignExchangeRates,
        PBP_ZA_eCommercesolutions,
        PBP_ZA_Onlineaccountforms,
        PBP_ZA_BUSINESSSAVINGANDINVESTMENTACCOUNTS,
        PBP_ZA_Manufacturing,
        PBP_ZA_Retailandwholesale,
        PBP_ZA_SecuritiesStandardbankUrl,
        PBP_ZA_SalaryPayments,
        PBP_ZA_PayrollandHRSolutions,
        PBP_ZA_Manageyourfleet,
        PBP_ZA_Construction,
        PBP_ZA_Personalinformation,
        PBP_ZA_AccountVerficationServices,
        PBP_ZA_SCAMSANDFRAUD,
        PBP_ZA_Debitorders,
        PBP_ZA_DIGITALBANKING,
        PBP_ZA_INNOVATIVEPAYMENT,
        PBP_ZA_GuardyourPIN,
        PBP_ZA_OntheATM,
        PBP_ZA_Online,
        PBP_ZA_INDUSTRY,
        PBP_ZA_TRADEPOINT,
        PBP_ZA_ProductScreen_Internet_Banking,
        PBP_ZA_MobileApp,
        PBP_ZA_ATMs,
        PBP_TradeClub2,
        PBP_ZA_Onyourcellphone,
        PBP_ZA_CARGO,
        PBP_ZA_CashAdvance,
        PBP_ZA_FLEETMANAGEMENT,
        PBP_ZA_CASH,
        PBP_ZA_EVENTS,
        PBP_ZA_Cashsolutions,
        PBP_ZA_Debitordercollections,
        PBP_ZA_Prepaidcardsolutions,
        PBP_ZA_DIRECTORSANDOFFICERS,
        PBP_YourPeople,
        PBP_ZA_BusinessOnline,
        PBP_ZA_Telephonebanking,
        PBP_ZA_SPECIALISED,
        PBP_ZA_Merchantsolutions,
        PBP_ZA_BusinessBanking,
        PBP_ZA_Employervaluebanking,
        PBP_ZA_ProductScreen_Business_Loans,
        PBP_ZA_SWITCHYOURBANKACCOUNT,
        PBP_ZA_PropertyFinance,
        PBP_ZA_Property,
        PBP_ZA_InstantMoneybulkpayments,
        PBP_ZA_PayCard,
        PBP_ZA_COMMERCIALCYBERINSURANCE,
        PBP_ZA_WORKPLACESOLUTIONS,
        PBP_ZA_Forowneroccupiers,
        PBP_ZA_PECIALISEDFINANCING,
        PBP_ZA_NEWCONTRACTS,
        PBP_ZA_NEWCONTRACTSMOBILE,
        PBP_ZA_YOURVEHICLES,
        PBP_ZA_YOURBUSINESS,
        PBP_ZA_Discloseddebtorfinance,
        PBP_Nondiscloseddebtorfinance,
        PBP_ZA_YOURAGRIBUSINESS,
        PBP_ZA_ENGINEERINGRISK,
        PBP_ZA_Forinvestors,
        PBP_ZA_BizFlexLoan,
        PBP_ZA_BusinessTravelWalletCard,
        PBP_ZA_Commercialvehicles,
        PBP_ZA_ProductScreen_Vehicle,
        PBP_ZA_Foreignorlocalgoods,
        PBP_ZA_COMMERCIALPROPERTYFINANCING,
        PBP_ZA_COMMERCIALPROPERTY,
        PBP_ZA_Businesstermloan,
        PBP_ZA_Accessfinancecalculator,
        PBP_ZA_CapitalEquipment,
        PBP_ZA_eMarketTrader,
        PBP_ZA_ForeignNotesForBusiness,
        PBP_ZA_SHARI_AHBANKING,
        PBP_ZA_BusinessOverdraft,
        PBP_ZA_Fixedrepaymentsbusinessloan,
        PBP_ZA_BusinessRevolvingloan,
        PBP_ZA_Agriculturalproductionloan,
        PBP_WaysToBank,
        PBP_ZA_Product_Bank_Card_Executors_Title,
        homeloanprotection,
        PBP_ZA_AttorneysTrustAccount,
        PBP_ZA_Product_Bank_Card_ThirdParty_Title,
        PBP_ZA_PropertyPractitionersTrustAccount,
        PBP_ZA_CompareTrustAccount,
        PBP_ZA_BUSINESSANDCORPORATECREDITCARDS,
        PBP_ZA_ExchangeContracts,
        applepay,
        myupdates,
        virtualcard,
        shoponlinewithmasterpass,
        escrowservices,
        snapscanfillonline,
        tagyourphonewithsamsung,
        paywithbills,
        sendinstantmoney,
        tagyourcardtopay,
        serviceupdated,
        smartyourcard,
        telephone,
        atm,
        cellphone,
        onlinebanking,
        ourrewardretailers,
        bankingapp,
        carfinanceprotection,
        financeshortfall,
        loans,
        funeralplans,
        personalaccident,
        legalassist,
        travelinsurance,
        lifecover,
        shariahfiduciaryservices,
        flexiablelifeplan,
        beneficiarycare,
        estates,
        willis,
        trusts,
        seriousillnesscover,
        smartgeysersolution,
        disabilitycover,
        salaryprotection,
        propertyinspection,
        buildinginsurance,
        calculators,
        buyingahome,
        homeservicespropertyguide,
        carandhome,
        vehiclefinancingcalculators,
        savingsandinvestmentproductionfilter,
        dentandscratch,
        homecontents,
        warranties,
        insurance,
        shariahinvestmentaccount,
        seeallstudentloans,
        comparecards,
        comparepersonalloans,
        seefinancingoptions,
        vehiclefinancing,
        overdraftwithoutquote,
        loancalculator,
        pensionbackedloans,
        seeallloans,
        tieredrates,
        managingyourbond,
        extendingyourhomeloan,
        settingupdanaccessbond,
        buildingahouse,
        ucountrewardsonline,
        bankDevices,
        PBP_ZA_COMMERCIALCYBERINSURANCEMobile,
        bankMobile,
        SeeAllAccounts,
        CompareAccounts,
        ManagingYourAccount,
        SavingAndInvestment,
        PBP_ZA_SeeAllCards,
        CompareCards,
        ManagingYourCard,
        SavingAndInvestmenProduct,
        GlobalWallet,
        SnapScanWallet,
        ForeignNotes,
        MoneyGram,
        InternationalPayments,
        TemporaryResidentBanking,
        NonResidentBanking,
        Aboutus,
        Locateus,
        ContactUs,
        SouthAfrica,
        Overview,
        ProductandServices,
        BankwithUs,
        BankAccounts,
        CREDITCARDS,
        SavingsAndInvestment,
        DigltalWallets,
        ForeignExchange,
        ForeignNationals,
        InternationalSolutions,
        PrepaidCards,
        ShariahBanking,
        BorrowForYourNeeds,
        HomeServices,
        PersonalLoans,
        VehicleFinancing,
        StudentsLoans,
        GrowYourMoney,
        ShareTrading,
        FinancialPlanning,
        Personal,
        InvestmentSolutions,
        My360App,
        InsureWhatMatters,
        YourCar,
        YourHome,
        YourIncome,
        YourFuture,
        Yourdebt,
        WaysToBank,
        SelfServiceBanking,
        InnovativePaymentSolution,
        HelpCentre,
        MyUpdates,
        CustomerSolutions,
        DebtManagementSolutions,
        DebtCareCenter,
        DeceasedEstates,
        BankSafely,
        ScamAndFraud,
        Shop,
        StandardBankMobile,
        StandardBankDevices,
        UcontRewardsTravelMAll,
        UcountRewardsRetailersOnline,
        UcountRewards,
        Learn,
        Buisness,
        productsAndService,
        Product_Bank_BreadCrumb_Bank_with_Us,
        Bizconnect,
        Tradeclub,
        Covid,
        CorporatesInstitutions,
        Wealth,
        Corporates,
        YourAccounts,
        SignInto,
        SignIn,
        YourSelf,
        Protect_yourself,
        PBP_ZA_Buisness,
        PBP_ZA_Institutions,
        PBP_ZA_COVID19,
        standardbankurl,
        standardbankmobileurl,
        linkedinurl,
        youtubeurl,
        facebookurl,
        twitterurl,
        whatsappurl,
        ucountsstandardurl,
        corporateurl,
        standardbankcomurl,
        googleplayurl,
        appleurl,
        FraudLine,
        International,
        LostOrStolenCards,
        ComplimentsAndComplaints,
        GiveUsCall,
        SouthAfricaNumber2,
        SouthAfricaNumber1,
        InternationalNumber,
        GetInTouch,
        InternationalNumber2,
        GetToKnowUs,
        NewsAndMedia,
        InvestorRelations,
        StandardBankGroup,
        WhoWeSponsor,
        WhoWeAre,
        FindABranch,
        BuildACareerWithUs,
        JoinOurInternationalTeam,
        ViewOpportunities,
        NeedHelpWithOneOfOurProductsOr,
        Start,
        Services,
        VisitOurCommunity,
        GetDetailsOnStatus,
        ToolsAndPlatforms,
        StatusPage,
        PhysicalAddress,
        SimmondsStreetselbyjonannesburg,
        WeWantYourFeedback,
        GotAComplimentOrComplaint,
        LetUsKnow,
        securitycentre,
        SecurityCentre,
        Regulatory,
        Legal,
        ManageCookies,
        Conditions,
        Terms,
        Pricing,
        StandardBankFootermsg,
        SbBankApp,
        reportingstandardurl,
        sponsershipstandardurl,
        communitystandardbankurl,
        statuspagestandardbankurl,
        SANumber1,
        SAInternationalNumber1,
        SANumber2,
        SAInternationalNumber2,
        appgalleryhuawai,
        PBP_ZA_chooseURcountry,
        PBP_ZA_Africa,
        PBP_ZA_Europe,
        PBP_ZA_Asia,
        PBP_ZA_America,
    };
    standardbankurlpersonalhome = standardbankurl + '/southafrica/personal/home';
    standardbankurlaboutus = standardbankurl + '/southafrica/personal/about-us';
    standardbankurlwealth = standardbankurl + '/southafrica/wealth';
    standardbankurlnewsandmedia = standardbankurl + '/southafrica/news-and-media';
    standardbankurlbusiness = PBP_ZA_siteUrl + '/southafrica/business';
    standardbankurlproducts = standardbankurl + '/southafrica/business/products-and-services/bank-with-us';
    standardbankurlbarrowyourneeds = standardbankurl + '/southafrica/business/products-and-services/borrow-for-your-needs';
    standardbankurlgrowyourmoney = standardbankurl + '/southafrica/business/products-and-services/grow-your-money';
    standardbankurlbizconnect = standardbankurl + '/southafrica/business/bizconnect';
    standardbankurltradeclub = standardbankurl + '/southafrica/business/products-and-services/business-solutions/trade-point';
    standardbankurlcovid = standardbankurl + '/southafrica/business/covid-19';
    standardbankurlcontactus = standardbankurl + '/southafrica/personal/contact-us';
    standardbankurlbranchlocator = standardbankurl + '/southafrica/personal/branch-locator';
    standardbankurlcontactusdetail = standardbankurl + '/southafrica/personal/contact-us/contact-us-details#';
    standardbankurlbanksafely = standardbankurl + '/southafrica/personal/products-and-services/security-centre/bank-safely';
    standardbankurlregulatory = standardbankurl + '/southafrica/personal/about-us/regulatory';
    standardbankurllearn = standardbankurl + '/southafrica/personal/learn';
    standardbankurllegal = standardbankurl + '/southafrica/personal/about-us/legal';
    standardbankurlmanagecookies = standardbankurl + '/southafrica/personal/about-us/legal/manage-cookies';
    standardbankurltermsandconditions = standardbankurl + '/southafrica/personal/about-us/terms-and-conditions';
    standardbankurlpricing = standardbankurl + '/southafrica/personal/about-us/pricing';
    ucountsstandardurlbusiness = ucountsstandardurl + '/business/';
    ucountsstandardurlpersonal = ucountsstandardurl + '/personal/';
    ucountsstandardurlucountmall = ucountsstandardurl + '/personal/promotion/online-shopping/?intcmp=coza-sitewide-headernav-shop-ucountMall';
    standardbankmobileurlshopmobile = standardbankmobileurl + '/?intcmp=coza-sitewide-headernav-shop-mobile';
    standardbankmobileurlshopdevices = standardbankmobileurl + '/products/devices?intcmp=coza-sitewide-headernav-shop-devices';
    standardbankmobileurlheadershopdevices = standardbankmobileurl + '/?intcmp=coza-sitewide-headernav-shop-devices"';
    standardbankcomurlgroupatglance = standardbankcomurl + 'sbg/standard-bank-group/who-we-are/our-group-at-a-glance';
    standardbankcomurlcareers = standardbankcomurl + 'sbg/careers';
    standardbankurltrustaccount = standardbankurl + '/southafrica/business/products-and-services/bank-with-us/attorney-accounts/attorney-trust-account';
    standardbankurlcurrentacccount = standardbankurl + '/southafrica/business/products-and-services/bank-with-us/attorney-accounts/executor-current-account';
    standardbankurlthirdpartyfund = standardbankurl + '/southafrica/business/products-and-services/bank-with-us/trust-accounts/third-party-fund-administration';
    standardbankurlpractitionerstrustaccount = standardbankurl + '/southafrica/business/products-and-services/bank-with-us/attorney-accounts/property-practitioners-trust-account';
    standardbankurlcomparetrustaccount = standardbankurl + '/southafrica/business/products-and-services/bank-with-us/attorney-accounts/compare-trust-account';
    standardbankurlcompanycardsourcards = standardbankurl + '/southafrica/business/products-and-services/bank-with-us/company-cards/our-cards';
    standardbankurlswitchbankaccount = standardbankurl + '/southafrica/business/products-and-services/bank-with-us/switch-your-bank-account';
    standardbankurlforeignexchange = standardbankurl + '/southafrica/business/products-and-services/bank-with-us/foreign-exchange';
    standardbankurlinternationalpayments = standardbankurl + '/southafrica/business/products-and-services/bank-with-us/foreign-exchange/business-international-payments';
    standardbankurltravelwalletcard = standardbankurl + '/southafrica/business/products-and-services/bank-with-us/foreign-exchange/business-travelwallet-card';
    standardbankurlshariahcompliantforwardexchangecontracts = standardbankurl + '/southafrica/business/products-and-services/business-solutions/specialised/merchant-solutions/shariah-compliant-forward-exchange-contracts';
    standardbankurlemarkettrader = standardbankurl + '/southafrica/business/products-and-services/bank-with-us/foreign-exchange/emarkettrader';
    standardbankurlnotesforyourbusiness = standardbankurl + '/southafrica/business/products-and-services/bank-with-us/foreign-exchange/foreign-notes-for-your-business';
    standardbankulrSHARÍAHBANKING = standardbankurl + '/southafrica/business/products-and-services/bank-with-us/shari%CC%81ah-banking';
    standardbankulrcashflowsolution = standardbankurl + '/southafrica/business/products-and-services/borrow-for-your-needs/cash-flow-solutions';
    standardbankulrcashflowsolutionbusinessoverdraft = standardbankurl + '/southafrica/business/products-and-services/borrow-for-your-needs/cash-flow-solutions/business-overdraft';
    standardbankulrcashflowsolutionrevolvingcreditplan = standardbankurl + '/southafrica/business/products-and-services/borrow-for-your-needs/cash-flow-solutions/revolving-credit-plan';
    standardbankulrcashflowsolutionagriculturalproductionloans = standardbankurl + '/southafrica/business/products-and-services/borrow-for-your-needs/cash-flow-solutions/agricultural-production-loan';
    standardbankulrcashflowsolutionfixedrepaymentsbusiness = standardbankurl + '/southafrica/business/products-and-services/borrow-for-your-needs/cash-flow-solutions/fixed-repayments-business-loan';
    standardbankulrcashflowsolutionbusinesstermloan = standardbankurl + '/southafrica/business/products-and-services/borrow-for-your-needs/cash-flow-solutions/business-term-loan';
    standardbankulbizflexloan = standardbankurl + '/southafrica/business/products-and-services/borrow-for-your-needs/cash-flow-solutions/bizflex-loan';
    standardbankulvehicleassetfinance = standardbankurl + '/southafrica/business/products-and-services/borrow-for-your-needs/vehicle-and-asset-finance';
    standardbankulvehicleassetfinancevehiclefinancing = standardbankurl + '/southafrica/business/products-and-services/borrow-for-your-needs/vehicle-and-asset-finance/vehicle-financing';
    standardbankulvehicleassetfinanceassetfinancing = standardbankurl + '/southafrica/business/products-and-services/borrow-for-your-needs/vehicle-and-asset-finance/asset-financing';
    standardbankulvehicleassetfinancebridgingfinance = standardbankurl + '/southafrica/business/products-and-services/borrow-for-your-needs/vehicle-and-asset-finance/bridging-finance';
    standardbankulvehicleassetfinanceaccessfinancing = standardbankurl + '/southafrica/business/products-and-services/borrow-for-your-needs/vehicle-and-asset-finance/access-finance-calculator';
    standardbankurlcommercialpropertyfinancing = standardbankurl + '/southafrica/business/products-and-services/borrow-for-your-needs/commercial-property-financing';
    standardbankurlsavingandinvestmentaccountsouraccounts = standardbankurl + '/southafrica/business/products-and-services/grow-your-money/saving-and-investment-accounts/our-accounts';
    standardbankurlsavingandinvestmentaccountscompareaccounts = standardbankurl + '/southafrica/business/products-and-services/grow-your-money/saving-and-investment-accounts/compare-accounts';
    standardbankurlsavingandinvestmentaccountsshariahbusinessbanking = standardbankurl + '/southafrica/business/products-and-services/grow-your-money/saving-and-investment-accounts/shariah-business-banking';
    standardbankurlsmallbusinessinsurance = standardbankurl + '/southafrica/business/products-and-services/insure-what-matters/small-business-insurance';
    standardbankurlsmallbusinessinsurance = standardbankurl + '/southafrica/business/products-and-services/insure-what-matters/small-business-insurance';


    standardbankurlinvestorpropertyfinancing = standardbankurl + '/southafrica/business/products-and-services/borrow-for-your-needs/commercial-property-financing/investor-property-financing';
    standardbankurlowneroccupiedpropertyfinancing = standardbankurl + '/southafrica/business/products-and-services/borrow-for-your-needs/commercial-property-financing/owner-occupied-property-financing';
    standardbankurlshariahcompliantcommercialpropertyfinance = standardbankurl + '/southafrica/business/products-and-services/borrow-for-your-needs/commercial-property-financing/shariah-compliant-commercial-property-finance';
    standardbankurlborrowforyourneedsspecialisedfinancing = standardbankurl + '/southafrica/business/products-and-services/borrow-for-your-needs/specialised-financing';
    standardbankurlborrowforyourneedsspecialisedfinancingdiscloseddebtorfinance = standardbankurl + '/southafrica/business/products-and-services/borrow-for-your-needs/specialised-financing/disclosed-debtor-finance';
    standardbankurlborrowforyourneedsspecialisedfinancingnondiscloseddebtorfinance = standardbankurl + '/southafrica/business/products-and-services/borrow-for-your-needs/specialised-financing/non-disclosed-debtor-finance';
    standardbankurlborrowforyourneedsspecialisedfinancingbankersacceptance = standardbankurl + '/southafrica/business/products-and-services/borrow-for-your-needs/specialised-financing/bankers-acceptance';
    standardbankurlborrowforyourneedsLoancalculator = standardbankurl + '/southafrica/business/products-and-services/borrow-for-your-needs/Loan-calculator';
    standardbankurlownerloanprotectionplan = standardbankurl + '/southafrica/business/products-and-services/insure-what-matters/owner-loan-protection-plan';
    standardbankurlcorporateriskmanagementandinsurance = standardbankurl + '/southafrica/business/products-and-services/insure-what-matters/corporate-risk-management-and-insurance';
    standardbankurlyouragribusiness = standardbankurl + '/southafrica/business/products-and-services/insure-what-matters/your-agri-business';
    standardbankurlyourvehicles = standardbankurl + '/southafrica/business/products-and-services/insure-what-matters/your-vehicles';
    standardbankurlcommercialpropertyinsurance = standardbankurl + '/southafrica/business/products-and-services/insure-what-matters/commercial-property-insurance';

    standardbankurlengineeringrisk = standardbankurl + '/southafrica/business/products-and-services/insure-what-matters/engineering-risk';
    standardbankurlbondsandguarantees = standardbankurl + '/southafrica/business/products-and-services/insure-what-matters/bonds-and-guarantees';
    standardbankurlmarineinsuranceforcargobyairlandorsea = standardbankurl + '/southafrica/business/products-and-services/insure-what-matters/marine-insurance-for-cargo-by-air-land-or-sea';
    standardbankurlcashinsurance = standardbankurl + '/southafrica/business/products-and-services/insure-what-matters/cash-insurance';
    standardbankurleventsliabilityinsurance = standardbankurl + '/southafrica/business/products-and-services/insure-what-matters/events-liability-insurance';
    standardbankurldirectorsandofficersliabilityinsurance = standardbankurl + '/southafrica/business/products-and-services/insure-what-matters/directors-and-officers-liability-insurance';
    standardbankurlemployeeprotectionplan = standardbankurl + '/southafrica/business/products-and-services/insure-what-matters/employee-protection-plan';
    standardbankurlcommercialcyberinsurance = standardbankurl + '/southafrica/business/products-and-services/insure-what-matters/commercial-cyber-insurance';
    standardbankurlworkplacesolutions = standardbankurl + '/southafrica/business/products-and-services/business-solutions/workplace-solutions';
    standardbankurlemployervaluebanking = standardbankurl + '/southafrica/business/products-and-services/business-solutions/workplace-solutions/employer-value-banking';
    standardbankurlinstantmoneybulkpayments = standardbankurl + '/southafrica/business/products-and-services/business-solutions/workplace-solutions/instant-money-bulk-payments';
    standardbankurlpaycard = standardbankurl + '/southafrica/business/products-and-services/business-solutions/workplace-solutions/paycard';
    standardbankurlprepaidcardsolutions = standardbankurl + '/southafrica/business/products-and-services/business-solutions/workplace-solutions/prepaid-card-solutions';
    standardbankurlfinancialplanning = standardbankurl + '/southafrica/business/products-and-services/business-solutions/workplace-solutions/financial-planning';
    standardbankurlsalarypayments = standardbankurl + '/southafrica/business/products-and-services/business-solutions/workplace-solutions/salary-payments';
    standardbankurlpayspacepayrollandhrsolutions = standardbankurl + '/southafrica/business/products-and-services/business-solutions/workplace-solutions/payspace-payroll-and-hr-solutions';
    standardbankurlspecialised = standardbankurl + '/southafrica/business/products-and-services/business-solutions/specialised';
    standardbankurlspecialisedmerchantsolutions = standardbankurl + '/southafrica/business/products-and-services/business-solutions/specialised/merchant-solutions';
    standardbankurlspecialisedcashsolutions = standardbankurl + '/southafrica/business/products-and-services/business-solutions/specialised/cash-solutions';
    standardbankurlspecialiseddebitordercollection = standardbankurl + '/southafrica/business/products-and-services/business-solutions/specialised/debit-order-collection';
    standardbankurlspecialisedfranchising = standardbankurl + '/southafrica/business/products-and-services/business-solutions/specialised/franchising';
    standardbankurlspecialisedsimplyblu = standardbankurl + '/southafrica/business/products-and-services/business-solutions/specialised/simplyblu';
    standardbankurlspecialisedshariahcompliantmerchantcapitalcashadvance = standardbankurl + '/southafrica/business/products-and-services/business-solutions/specialised/shariah-compliant-merchant-capital-cash-advance';
    standardbankurlfleetmanagement = standardbankurl + '/southafrica/business/products-and-services/business-solutions/fleet-management';
    standardbankurlfleetmanagementManageyourfleet = standardbankurl + '/southafrica/business/products-and-services/business-solutions/fleet-management/Manage-your-fleet';
    standardbankurlfleetmanagementFleetvalueaddedservices = standardbankurl + '/southafrica/business/products-and-services/business-solutions/fleet-management/Fleet-value-added-services';
    standardbankurlfleetmanagementOnlineaccountforms = standardbankurl + '/southafrica/business/products-and-services/business-solutions/fleet-management/Online-account-forms';
    standardbankurlindustry = standardbankurl + '/southafrica/business/products-and-services/business-solutions/industry';
    standardbankurlindustryagribusiness = standardbankurl + '/southafrica/business/products-and-services/business-solutions/industry/agribusiness';
    standardbankurlindustryagriproperty = standardbankurl + '/southafrica/business/products-and-services/business-solutions/industry/property';
    standardbankurlindustrymanufacturing = standardbankurl + '/southafrica/business/products-and-services/business-solutions/industry/manufacturing';
    standardbankurlindustryretailandwholesale = standardbankurl + '/southafrica/business/products-and-services/business-solutions/industry/retail-and-wholesale';
    standardbankurlindustrynaturalresources = standardbankurl + '/southafrica/business/products-and-services/business-solutions/industry/natural-resources';
    standardbankurlindustrytransportandlogistics = standardbankurl + '/southafrica/business/products-and-services/business-solutions/industry/transport-and-logistics';
    standardbankurlindustryconstruction = standardbankurl + '/southafrica/business/products-and-services/business-solutions/industry/construction';
    standardbankurltradepoint = standardbankurl + '/southafrica/business/products-and-services/business-solutions/trade-point';
    standardbankurltradepointtradeclub = standardbankurl + '/southafrica/business/products-and-services/business-solutions/trade-point/trade-club';
    standardbankurltradepointtradesuite = standardbankurl + '/southafrica/business/products-and-services/business-solutions/trade-point/trade-suite';
    standardbankurltradepointtradefinance = standardbankurl + '/southafrica/business/products-and-services/business-solutions/trade-point/trade-finance';
    standardbankurltradepointtradebarometer = standardbankurl + '/southafrica/business/products-and-services/business-solutions/trade-point/trade-barometer';
    standardbankurltradepointafricachinatrade = standardbankurl + '/southafrica/business/products-and-services/business-solutions/trade-point/africa-china-trade';
    standardbankurlselfservicebanking = standardbankurl + '/southafrica/business/products-and-services/ways-to-bank/self-service-banking';
    standardbankurlselfservicebankingonlinebanking = standardbankurl + '/southafrica/business/products-and-services/ways-to-bank/self-service-banking/onlinebanking';
    standardbankurlselfservicebankingcellphonebanking = standardbankurl + '/southafrica/business/products-and-services/ways-to-bank/self-service-banking/cellphone-banking';
    standardbankurlselfservicebankingmobileappbanking = standardbankurl + '/southafrica/business/products-and-services/ways-to-bank/self-service-banking/mobile-app-banking';
    standardbankurlescrow = standardbankurl + '/escrow';
    standardbankurlatmbanking = standardbankurl + '/southafrica/business/products-and-services/ways-to-bank/self-service-banking/atm-banking';
    standardbankurlbusinessonline = standardbankurl + '/southafrica/business/products-and-services/ways-to-bank/self-service-banking/businessonline';
    standardbankurltelephoneandspeechbanking = standardbankurl + '/southafrica/business/products-and-services/ways-to-bank/self-service-banking/telephone-and-speech-banking';
    standardbankurldigitalbanking = standardbankurl + '/southafrica/business/products-and-services/ways-to-bank/digital-banking';
    standardbankurlmyupdates = standardbankurl + '/southafrica/business/products-and-services/ways-to-bank/myupdates';
    standardbankurlbanksafely = standardbankurl + '/southafrica/business/products-and-services/security-centre/bank-safely';
    standardbankurlbanksafelyonline = standardbankurl + '/southafrica/personal/products-and-services/security-centre/bank-safely/online';
    standardbankurlbanksafelyattheatm = standardbankurl + '/southafrica/personal/products-and-services/security-centre/bank-safely/at-the-atm';
    standardbankurlbanksafelyonyourcellphone = standardbankurl + '/southafrica/personal/products-and-services/security-centre/bank-safely/on-your-cellphone';
    standardbankurlpersonalmyupdates = standardbankurl + '/southafrica/personal/products-and-services/ways-to-bank/myupdates';
    standardbankurlbanksecurelywithadigitalid = standardbankurl + '/southafrica/personal/products-and-services/security-centre/bank-safely/bank-securely-with-a-digital-id';

    standardbankurlguardyourpin = standardbankurl + '/southafrica/personal/products-and-services/security-centre/bank-safely/guard-your-pin';
    standardbankurlshopsafelyonline = standardbankurl + '/southafrica/personal/products-and-services/security-centre/bank-safely/shop-safely-online';
    standardbankurlprotectyouridandpersonalinfo = standardbankurl + '/southafrica/personal/products-and-services/security-centre/bank-safely/protect-your-id-and-personal-info';
    standardbankurldebicheck = standardbankurl + '/southafrica/personal/products-and-services/security-centre/bank-safely/debicheck';
    standardbankurlaccountverificationservices = standardbankurl + '/southafrica/business/products-and-services/security-centre/protect-yourself/account-verification-services';
    standardbankurlscams = standardbankurl + '/southafrica/personal/products-and-services/security-centre/bank-safely/scams';
    standardbankurlcardfraud = standardbankurl + '/southafrica/personal/products-and-services/security-centre/bank-safely/card-fraud';
    standardbankurlouraccounts = PBP_ZA_siteUrl + '/southafrica/business/products-and-services/bank-with-us/business-bank-accounts/our-accounts';
    standardbankurcompareaccounts = standardbankurl + '/southafrica/business/products-and-services/bank-with-us/business-bank-accounts/compare-accounts';
    productandservices=standardbankurl+'/southafrica/business/products-and-services';
    standardbanklinklearn = standardbankurl+'/southafrica/personal/learn';
    standardbankwelathinsurance =standardbankurl+'/southafrica/personal/products-and-services/insure-what-matters/yourself';
    standardbankwelathFiduciary = standardbankurl+'/southafrica/personal/products-and-services/insure-what-matters/your-future';
    standardbankwealthinvestments = standardbankurl+'/southafrica/personal/products-and-services/grow-your-money/investment-solutions';
    standardbankwealthmanagement  ='https://wealthandinvestment.standardbank.com/';
    standardbankbusinessoverview = 'https://www.standardbank.co.za/southafrica/business';
    bankaccounturl= standardbankurl + '/southafrica/personal/products-and-services/bank-with-us/bank-accounts/our-accounts';
    creditcardurl= standardbankurl + '/southafrica/personal/products-and-services/bank-with-us/credit-cards/our-cards';
    saveinginvestmenturl = standardbankurl +  '/southafrica/personal/products-and-services/grow-your-money/savings-and-investment/our-accounts';
    digitalwalleturl = standardbankurl + '/southafrica/personal/products-and-services/bank-with-us/digital-wallets';
    foreignexchangeurl=standardbankurl +'/southafrica/personal/products-and-services/bank-with-us/foreign-exchange';
    foreignnationalsurl=standardbankurl +'/southafrica/personal/products-and-services/bank-with-us/foreign-nationals';
    internationalsolutionsurl=standardbankurl +'/southafrica/personal/products-and-services/bank-with-us/international-solutions';
    prepaidcardsurl=standardbankurl +'/southafrica/personal/products-and-services/bank-with-us/prepaid-gift-cards';
    shariahurl=standardbankurl +'/southafrica/personal/products-and-services/bank-with-us/sharíah-banking';
    homeserviceurl=standardbankurl +'/southafrica/personal/products-and-services/borrow-for-your-needs/home-loans';
    personalloanurl=standardbankurl +'/southafrica/personal/products-and-services/borrow-for-your-needs/personal-loans/our-loans';
    vechilefinancingurl=standardbankurl +'/southafrica/personal/products-and-services/borrow-for-your-needs/vehicle-financing/see-financing-options';
    creditcardurls=standardbankurl +'/southafrica/personal/products-and-services/bank-with-us/credit-cards/our-cards/';
    studentloans=standardbankurl +'/southafrica/personal/products-and-services/borrow-for-your-needs/student-loans/student-loans';
    savingandinvestment = standardbankurl +'/southafrica/personal/products-and-services/grow-your-money/savings-and-investment/our-accounts';
    sharertadingurl= standardbankurl + 'southafrica/personal/products-and-services/grow-your-money/share-trading/online-share-trading';
    financialplannigurl=standardbankurl + '/southafrica/personal/products-and-services/grow-your-money/financial-planning';
    investmentsolutionurl=standardbankurl +'/southafrica/personal/products-and-services/grow-your-money/investment-solutions';
    my360appurl= standardbankurl +'/southafrica/personal/products-and-services/grow-your-money/my360-app';
    yourcarurl=standardbankurl +'/southafrica/personal/products-and-services/insure-what-matters/your-car';
    yourhomeurl=standardbankurl +'/southafrica/personal/products-and-services/insure-what-matters/your-home';
    yourincomeurl=standardbankurl +'/southafrica/personal/products-and-services/insure-what-matters/your-income';
    yourfutureurl=standardbankurl +'/southafrica/personal/products-and-services/insure-what-matters/your-future';
    youselfurl=standardbankurl +'/southafrica/personal/products-and-services/insure-what-matters/yourself';
    yourdebturl=standardbankurl +'/southafrica/personal/products-and-services/insure-what-matters/your-debt';
    standardbankinsurnceurl=standardbankurl +'/southafrica/personal/products-and-services/insure-what-matters/standard-bank-insurance-app';
    selfservicingurl= standardbankurl +'/southafrica/personal/products-and-services/ways-to-bank/self-service-banking';
    innovativeurl=standardbankurl +'/southafrica/personal/products-and-services/ways-to-bank/innovative-payment-solutions';
    myupdateurl = standardbankurl + '/southafrica/personal/products-and-services/ways-to-bank/myupdates';
    helpcentreurl=standardbankurl +'/southafrica/personal/products-and-services/ways-to-bank/help-centre';
    debtmangementurl=standardbankurl +'/southafrica/personal/products-and-services/customer-solutions/debt-management-solutions';
    debtcareurl=standardbankurl +'/southafrica/personal/products-and-services/customer-solutions/debt-care-centre';
    decesedurl=standardbankurl +'/southafrica/personal/products-and-services/customer-solutions/deceased-estates';
    banksafleyurl=standardbankurl +'/southafrica/personal/products-and-services/security-centre/bank-safely';
    protectionurl=standardbankurl +'/southafrica/personal/products-and-services/security-centre/bank-safely/guard-your-pin';
    scamandfraudurl=standardbankurl +'/southafrica/personal/products-and-services/security-centre/bank-safely/scams';
    ucountrewardsurl='https://ucounttravel.standardbank.co.za/';
    retailonlineurl = 'https://ucounttravel.standardbank.co.za/?intcmp=coza-sitewide-headernav-shop-devices';
    ucountrewardurl='https://ucount.standardbank.co.za/personal/';
    learnurl=standardbankurl +'/southafrica/personal/learn';
    bankwithusurl=standardbankurl +'/southafrica/business/products-and-services/bank-with-us/business-bank-accounts/our-accounts';
    trustaccounturl=standardbankurl +'/southafrica/business/products-and-services/bank-with-us/trust-accounts/attorney-trust-account';
    switchyouraccounturl=standardbankurl +'/southafrica/business/products-and-services/bank-with-us/switch-your-bank-account';
    foreginexnurl=standardbankurl +'/southafrica/business/products-and-services/bank-with-us/foreign-exchange';
    sharianurl=standardbankurl +'/southafrica/business/products-and-services/bank-with-us/sharíah-banking';
    bussinessloansurl=standardbankurl +'/southafrica/business/products-and-services/borrow-for-your-needs/cash-flow-solutions';
    vechileandassisturl=standardbankurl +'/southafrica/business/products-and-services/borrow-for-your-needs/vehicle-and-asset-finance';
    commericalurl=standardbankurl +'/southafrica/business/products-and-services/borrow-for-your-needs/commercial-property-financing';
    loancalculator =standardbankurl + '/southafrica/business/products-and-services/borrow-for-your-needs/Loan-calculator';
    bussinessinvestmenturl=standardbankurl + '/southafrica/business/products-and-services/grow-your-money/saving-and-investment-accounts/our-accounts';
    yourbussinessurl=standardbankurl +'/southafrica/business/products-and-services/insure-what-matters/small-business-insurance';
    loansurl=standardbankurl +'/southafrica/business/products-and-services/insure-what-matters/owner-loan-protection-plan';
    coparaterisk=standardbankurl +'/southafrica/business/products-and-services/insure-what-matters/corporate-risk-management-and-insurance'
     agribussinessurl=standardbankurl +'/southafrica/business/products-and-services/insure-what-matters/your-agri-business';
     insurancevechileurl=standardbankurl +'/southafrica/business/products-and-services/insure-what-matters/your-vehicles';
     commericalpropertyurl=standardbankurl +'/southafrica/business/products-and-services/insure-what-matters/commercial-property-insurance';
     engineeringriskurl=standardbankurl +'/southafrica/business/products-and-services/insure-what-matters/engineering-risk';
     newcontracturl=standardbankurl +'/southafrica/business/products-and-services/insure-what-matters/bonds-and-guarantees';
     cargourl=standardbankurl +'/southafrica/business/products-and-services/insure-what-matters/marine-insurance-for-cargo-by-air-land-or-sea';
     cashurl=standardbankurl +'/southafrica/business/products-and-services/insure-what-matters/cash-insurance';
     eventurl=standardbankurl +'/southafrica/business/products-and-services/insure-what-matters/events-liability-insurance';
     directorurl=standardbankurl +'/southafrica/business/products-and-services/insure-what-matters/directors-and-officers-liability-insurance';
     yourpeopleurl=standardbankurl +'/southafrica/business/products-and-services/insure-what-matters/employee-protection-plan';
     cyberinsuranceurl=standardbankurl +'/southafrica/business/products-and-services/insure-what-matters/commercial-cyber-insurance';
     selfservicebankingurl=standardbankurl +'/southafrica/business/products-and-services/ways-to-bank/self-service-banking';
     digitalbankingurl = standardbankurl +'/southafrica/business/products-and-services/ways-to-bank/digital-banking';
      innovativepaymentsolutionurl=standardbankurl +'/southafrica/personal/products-and-services/ways-to-bank/innovative-payment-solutions/escrow-service';
      myupdates= standardbankurl+ '/southafrica/business/products-and-services/ways-to-bank/myupdates';
      scamAndfraud = standardbankurl+'/southafrica/personal/products-and-services/security-centre/bank-safely/scams';
      workplacesolutions=standardbankurl +'/southafrica/business/products-and-services/business-solutions/workplace-solutions';
      specialisedurl=standardbankurl +'/southafrica/business/products-and-services/borrow-for-your-needs/specialised-financing';
      fleetmanagementurl=standardbankurl +'/southafrica/business/products-and-services/business-solutions/fleet-management';
      tradepointurl=standardbankurl +'/southafrica/business/products-and-services/business-solutions/trade-point';
      cargourl=standardbankurl +'/southafrica/business/products-and-services/insure-what-matters/marine-insurance-for-cargo-by-air-land-or-sea';
      eventurl=standardbankurl +'/southafrica/business/products-and-services/insure-what-matters/events-liability-insurance';
      directorurl=standardbankurl +'/southafrica/business/products-and-services/insure-what-matters/directors-and-officers-liability-insurance';
      yourpeopleurl=standardbankurl +'/southafrica/business/products-and-services/insure-what-matters/employee-protection-plan';
      cyberinsuranceurl=standardbankurl +'/southafrica/business/products-and-services/insure-what-matters/commercial-cyber-insurance';
      selfservicebankingurl=standardbankurl +'/southafrica/business/products-and-services/ways-to-bank/self-service-banking';
      digitalbankingurl = standardbankurl +'/southafrica/business/products-and-services/ways-to-bank/digital-banking';
       innovativepaymentsolutionurl=standardbankurl +'/southafrica/personal/products-and-services/ways-to-bank/innovative-payment-solutions/escrow-service';
       myupdates= standardbankurl+ '/southafrica/business/products-and-services/ways-to-bank/myupdates';
       BankSafely = standardbankurl+'/southafrica/business/products-and-services/security-centre/bank-safely';
       scamAndfraud = standardbankurl+'/southafrica/personal/products-and-services/security-centre/bank-safely/scams';
       protectyourself =standardbankurl +'/southafrica/personal/products-and-services/security-centre/bank-safely/guard-your-pin';
       workplacesolutions=standardbankurl +'/southafrica/business/products-and-services/business-solutions/workplace-solutions';
       fleetmanagementurl=standardbankurl +'/southafrica/business/products-and-services/business-solutions/fleet-management';
       industryurl=standardbankurl +'/southafrica/business/products-and-services/business-solutions/industry';
       insuranceurl=standardbankurl +'/southafrica/personal/products-and-services/insure-what-matters/yourself';
       corporateslink = 'https://corporateandinvestment.standardbank.com/cib/global';
 
    isEventFired;
    adobePageTag = {
        pageName: "business:Home: Our Products & & Services: Bank with us: Business Bank Account: see all accounts ",
        dataId: "link_content",
        dataIntent: "informationall",
        dataScope: "product card",
        visitourcommunityButtonText: "mymobiz business account | visit our community button click",
        letusknowButtonText: "mymobiz business account | let us know button click",
    };
    linkedin = linkedin + '/assets/images/linkedin.png';
    youtube = youtube + '/assets/images/youtube.png';
    Huwai = Huwai + '/assets/images/huawei-app-gallery.svg';
    facebook = facebook + '/assets/images/facebook.png';
    twitter = twitter + '/assets/images/twitter.png';
    whatsapp = whatAppIcon + '/assets/images/whatsappimg.svg';

    applestore = applestore + '/assets/images/app-store-badge1.png';
    googleplay = googleplay + '/assets/images/google-play-badge1.png';
    appsnapshot = appsnapshot + '/assets/images/app.png';
    whatAppIcon = whatAppIcon + '/assets/images/whatAppIcon.png';
    standardBankLogo = standardbank + "/assets/images/3-d-logo-copy.png";
    standardBankText = standardbank + "/assets/images/standard-bank-copy.png";
    searchIcon = standardbank + "/assets/images/Search.png";
    searchIconb = standardbank + "/assets/images/search-blue.png";
    profilePic = standardbank + "/assets/images/Contact.png";
    Cart = standardbank + "/assets/images/Cart.png";
    imageSouthAfrica = standardbank + "/assets/images/ImageSA.png";
    gotopageicon = standardbank + "/assets/images/icon-external-link-original.svg";
    gotoPageIcon = standardbank + '/assets/images/gotopageicon.png';
    hamburgermenu = standardbank + "/assets/images/hamburgermenu.png";
    babyCity = standardbank + "/assets/images/baby_city.png";
    carServiceCity = standardbank + "/assets/images/car_service_city.png";
    courierConnexion = standardbank + "/assets/images/Courier_Connexion.png";
    courierChemLogo = standardbank + "/assets/images/Dis-Chem_Logo.png";
    freshStopLogo = standardbank + "/assets/images/fresh_stop.png";
    gameLogo = standardbank + "/assets/images/Game_Logo.png";
    hirSchsLogo = standardbank + "/assets/images/Hirschs_logo.png";
    kfcLogo = standardbank + "/assets/images/KFC.png";
    macroLogo = standardbank + "/assets/images/makro.png";
    netFloristLogo = standardbank + "/assets/images/netflorist.png";
    olymPicCyclesLogo = standardbank + "/assets/images/Olympic_Cycles_logo.png";
    samsungLogo = standardbank + "/assets/images/Samsung_logo_white.png";
    showMaxLogo = standardbank + "/assets/images/showmax.png";
    sweepSouthLogo = standardbank + "/assets/images/Sweep_South.png";
    tigerWheelLogo = standardbank + "/assets/images/tiger_wheel.png";
    wineLogo = standardbank + "/assets/images/wine.png";
    xTrendLogo = standardbank + "/assets/images/Xtrend_Logo.png";
    xKidsLogo = standardbank + "/assets/images/XKIDS_Logo.png";
    zandoLogo = standardbank + "/assets/images/zando.png";
    coastalHireLogo = standardbank + "/assets/images/Coastal_hire.png";
    altechNetstarLogo = standardbank + "/assets/images/altech_netstar.png";
    theCrossTrainerLogo = standardbank + "/assets/images/The_Cross_Trainer_Logo.png";
    cloudicon = PRODUCT_SCREENS + "/assets/images/cloud.svg";
    monitoricon = PRODUCT_SCREENS + "/assets/images/screen.svg";

    Angola = FlagImages + '/assets/images/Angola.png';
    Botswana = FlagImages + '/assets/images/Botswana.png';
    cotedlvoire = FlagImages + '/assets/images/Cote-divoire.png';
    drc = FlagImages + '/assets/images/DRC.png';
    Eswatini = FlagImages + '/assets/images/Eswatini.png';
    Ghana = FlagImages + '/assets/images/Ghana.png';
    Kenya = FlagImages + '/assets/images/Kenya.png';
    Lesotho = FlagImages + '/assets/images/Lesotho.png';
    Malawi = FlagImages + '/assets/images/Malawi.png';
    Mauritius = FlagImages + '/assets/images/Mauritius.png';
    Mozambique = FlagImages + '/assets/images/Mozambique.png';
    Namibia = FlagImages + '/assets/images/Namibia.png';
    Nigiria = FlagImages + '/assets/images/Nigeria.png';
    Tanzania = FlagImages + '/assets/images/Tanzania.png';
    Uganda = FlagImages + '/assets/images/Uganda.png';
    Zambia = FlagImages + '/assets/images/Zambia.png';
    Zimbabwe = FlagImages + '/assets/images/Zimbabwe.png';
    IsleofMan = FlagImages + '/assets/images/IsleofMan.png';
    Jersey = FlagImages + '/assets/images/Jersey.png';
    UK = FlagImages + '/assets/images/UK.png';
    China = FlagImages + '/assets/images/China.png';
    USA = FlagImages + '/assets/images/USA.png';
    Brazil = FlagImages + '/assets/images/Brazil.png';
    UAE = FlagImages + '/assets/images/UAE.png';
    ImageSA = FlagImages + '/assets/images/ImageSA.png';
    sadropdown = FlagImages + '/assets/images/flechita.png';

    Africaflags = [{ 'image': FlagImages + '/assets/images/Angola.png', 'Name': "Angola", 'URL': 'https://www.standardbank.co.ao/' },
    { 'image': FlagImages + '/assets/images/Botswana.png', 'Name': "Botswana", 'URL': 'https://www.stanbicbank.co.bw/' },
    { 'image': FlagImages + '/assets/images/Cote-divoire.png', 'Name': "Cote-d'lvoire", 'URL': 'https://www.stanbicbank.com.ci/' },
    { 'image': FlagImages + '/assets/images/DRC.png', 'Name': "DRC", 'URL': 'https://www.standardbank.cd/' },
    { 'image': FlagImages + '/assets/images/Eswatini.png', 'Name': "Eswatini", 'URL': 'https://www.standardbank.co.sz/' },
    { 'image': FlagImages + '/assets/images/Ghana.png', 'Name': "Ghana", 'URL': 'https://www.stanbicbank.com.gh/gh/personal' },
    { 'image': FlagImages + '/assets/images/Kenya.png', 'Name': "Kenya", 'URL': 'https://www.stanbicbank.co.ke/' },
    { 'image': FlagImages + '/assets/images/Lesotho.png', 'Name': "Lesotho", 'URL': 'https://www.standardlesothobank.co.ls/' },
    { 'image': FlagImages + '/assets/images/Malawi.png', 'Name': "Malawi", 'URL': 'https://www.standardbank.co.mw/' },
    { 'image': FlagImages + '/assets/images/Mauritius.png', 'Name': "Mauritius", 'URL': 'https://www.standardbank.mu/' },
    { 'image': FlagImages + '/assets/images/Mozambique.png', 'Name': "Mozambique", 'URL': 'https://www.standardbank.co.mz/' },
    { 'image': FlagImages + '/assets/images/Namibia.png', 'Name': "Namibia", 'URL': 'https://www.standardbank.com.na/' },
    { 'image': FlagImages + '/assets/images/Nigeria.png', 'Name': "Nigeria", 'URL': 'https://www.stanbicibtcbank.com/nigeriabank/personal' },
    { 'image': FlagImages + '/assets/images/ImageSA.png', 'Name': "South Africa", 'URL': 'https://www.standardbank.co.za/southafrica/personal/home' },
    { 'image': FlagImages + '/assets/images/Tanzania.png', 'Name': "Tanzania", 'URL': 'https://www.stanbicbank.co.tz/' },
    { 'image': FlagImages + '/assets/images/Uganda.png', 'Name': "Uganda", 'URL': 'https://www.stanbicbank.co.ug/' },
    { 'image': FlagImages + '/assets/images/Zambia.png', 'Name': "Namibia", 'URL': 'https://www.stanbicbank.co.zm/' },
    { 'image': FlagImages + '/assets/images/Zimbabwe.png', 'Name': "Zimbabwe", 'URL': 'https://www.stanbicbank.co.zw/' }

    ];
    Europeflags = [{ 'image': FlagImages + '/assets/images/IsleofMan.png', 'Name': "Isle of Man", 'URL': 'https://international.standardbank.com/international/personal' },
    { 'image': FlagImages + '/assets/images/Jersey.png', 'Name': "Jersey", 'URL': 'https://international.standardbank.com/international/personal' },
    { 'image': FlagImages + '/assets/images/UK.png', 'Name': "United Kingdom", 'URL': 'https://corporateandinvestment.standardbank.com/cib/global/country-presence/europe/united-kingdom' }];
    AsiaMiddleEastflags = [{ 'image': FlagImages + '/assets/images/China.png', 'Name': "China", 'URL': 'https://corporateandinvestment.standardbank.com//cib/global/country-presence/asia/china' },
    { 'image': FlagImages + '/assets/images/UAE.png', 'Name': "United Arab Emirates", 'URL': 'https://corporateandinvestment.standardbank.com/cib/global/country-presence/asia/united-arab-emirates' }];
    Americaflags = [{ 'image': FlagImages + '/assets/images/Brazil.png', 'Name': "Brazil", 'URL': 'https://www.standardbank.com.br/' },
    { 'image': FlagImages + '/assets/images/USA.png', 'Name': "United States of America", 'URL': 'https://corporateandinvestment.standardbank.com/cib/global/country-presence/americas/usa' }];
    searchAccountAction(event) {
        this.AfricaflagsFilter = [];
        this.EuropeflagsFilter = [];
        this.AsiaMiddleEastflagsFilter = [];
        this.AmericaflagsFilter = [];
        this.searchValue = event.target.value;
        for (var i = 0; i < this.Africaflags.length; i++) {
            if (this.Africaflags[i].Name.toLowerCase().includes(event.target.value.toLowerCase())) {
                this.AfricaflagsFilter.push(this.Africaflags[i]);
            }
        }
        for (var i = 0; i < this.Europeflags.length; i++) {
            if (this.Europeflags[i].Name.toLowerCase().includes(event.target.value.toLowerCase())) {
                this.EuropeflagsFilter.push(this.Europeflags[i]);
            }
        }
        for (var i = 0; i < this.AsiaMiddleEastflags.length; i++) {
            if (this.AsiaMiddleEastflags[i].Name.toLowerCase().includes(event.target.value.toLowerCase())) {
                this.AsiaMiddleEastflagsFilter.push(this.AsiaMiddleEastflags[i]);
            }
        }
        for (var i = 0; i < this.Americaflags.length; i++) {
            if (this.Americaflags[i].Name.toLowerCase().includes(event.target.value.toLowerCase())) {
                this.AmericaflagsFilter.push(this.Americaflags[i]);
            }
        }
    }
    handleclick(event) {
        window.fireButtonClickEvent(this, event);
    }
    handleSection() {
        this.isOpenSection = true;
    }
    constructor() {
        super();
        if (FORM_FACTOR && FORM_FACTOR === 'Large') {
            this.isDesktopDevice = true;
            this.isTabletDevice = false;
            this.isMobileDevice = false;
        } else if (FORM_FACTOR && FORM_FACTOR === 'Medium') {
            this.isDesktopDevice = false;
            this.isTabletDevice = true;
            this.isMobileDevice = false;
        } else if (FORM_FACTOR && FORM_FACTOR === 'Small') {
            this.isDesktopDevice = false;
            this.isTabletDevice = false;
            this.isMobileDevice = true;
        }
    }

    connectedCallback() {
        this.AfricaflagsFilter = this.Africaflags;
        this.EuropeflagsFilter = this.Europeflags;
        this.AsiaMiddleEastflagsFilter = this.AsiaMiddleEastflags;
        this.AmericaflagsFilter = this.Americaflags;
    }
    getAllTabs() {
        return [...this.template.querySelectorAll('.slds-tabs_default__item')];
    }
    getCurrentTab() {
        return this.getAllTabs().findIndex((tab) => tab.classList.contains('slds-is-active'));
    }
    nextTab() {
        this.setNewTab(
            (this.getCurrentTab() + 1) % this.getAllTabs().length
        );
    }
    tabClick(e) {
        const allTabs = this.getAllTabs();
        const newIndex = allTabs.findIndex((tab) => tab === e.currentTarget);
        this.setNewTab(newIndex);
    }
    setNewTab(index) {
        const allTabs = this.getAllTabs();
        const tabElement = allTabs[index];
        allTabs.forEach((tab) => tab.classList.remove('slds-is-active'));
        tabElement.classList.add('slds-is-active');
        const tabContent = this.template.querySelectorAll('.slds-tabs_default__content');
        tabContent.forEach((elm) => {
            elm.classList.remove("slds-show");
            elm.classList.add("slds-hide");
        });
        tabContent[index].classList.remove("slds-hide");
        tabContent[index].classList.add("slds-show");
    }
    businessonline() {
        window.open("https://www.businessonline.standardbank.co.za/bolsa/businessonline", "_blank");
    }
    internetbanking() {
        window.open("https://onlinebanking.standardbank.co.za/#/landing-page", "_blank");
    }
    modelpopcountrycode() {
        this.ismodalpopcountrycode = true;
    }
    closemodalcountrycode() {
        this.ismodalpopcountrycode = false;
    }
    closeModal(event) {
        this.isOpenSection = false;
        this.showResults = false;
    }
    HandleShowingSection() {
        this.showSecMobile = !this.showSecMobile;
    }
    onBtnClick(){
        this.classList.toggle('opened');
    }
   toggleRotation(){
    this.iconClass = this.iconClass ? '' : 'rotated';
   }
   HandleShowingSectionMobile(){
    var menu_btn;
    if(this.showSecMobile == false){
        this.showSecMobile = true;
        var burger_menu = this.template.querySelector('.hamburger-menu');
        console.log('burger_menu ',burger_menu);
        burger_menu.className += ' close';
        burger_menu.className = burger_menu.className.replace('hamburgeroriginal','');
        // if(burger_menu.className.includes('hamburgeroriginal')){
        //     this.showSecMobile = false;
        // }
    }else{
        this.showSecMobile = false;
        this.prodAndServicesBusiness = false;
        var convertorginalhamburger = this.template.querySelector('.hamburger-menu');
        console.log('burger_menu orginal ',convertorginalhamburger);
        convertorginalhamburger.className += ' hamburgeroriginal';
        convertorginalhamburger.className = convertorginalhamburger.className.replace('close','');           
    }
}
    HandlePersonalIcon() {
        if(this.personalIcon == false){
            this.personalIcon = true;
            this.businessIconmb = false;
            this.isWealthcheck = false;
            this.iconClass = this.iconClass ? '' : 'rotated'; 
            var arrowicn = this.template.querySelector('.arrow_icon');
            arrowicn.className +=' arrowiconrotate';
            var rotateicn = this.template.querySelector('.rotate_icon');
            rotateicn.className += ' rotaticn2';
            arrowicn.className = arrowicn.className.replace('arrowiconoriginal','');
            rotateicn.className = rotateicn.className.replace('rotaticnoriginal','');
        }else{
            this.personalIcon = false;
            var arrowicn = this.template.querySelector('.arrow_icon');
            arrowicn.className += 'arrowiconoriginal';
            var rotateicn = this.template.querySelector('.rotate_icon');
            rotateicn.className += ' rotaticnoriginal';
            arrowicn.className = arrowicn.className.replace('arrowiconrotate','');
            rotateicn.className = rotateicn.className.replace('rotaticn2','');
        }
    }
    HandleBusinessIcon(event) {
        if(this.businessIconmb == false){
            this.businessIconmb = true;
            this.personalIcon = false;
            this.isWealthcheck = false;
            var arrowicn = this.template.querySelector('.arrow_iconbusiness');
            arrowicn.className +=' arrowiconrotate';
            var rotateicn = this.template.querySelector('.rotateiconbusiness');
            rotateicn.className += ' rotaticn2';
            arrowicn.className = arrowicn.className.replace('arrowiconoriginal','');
            rotateicn.className = rotateicn.className.replace('rotaticnoriginal','');

            var arrowicnpersonal = this.template.querySelector('.arrow_icon');
            var rotateicnpersonal = this.template.querySelector('.rotate_icon');        
        }else{
            this.businessIconmb = false;  
            var arrowicn = this.template.querySelector('.arrow_iconbusiness');
            arrowicn.className += 'arrowiconoriginal';
            var rotateicn = this.template.querySelector('.rotateiconbusiness');
            rotateicn.className += ' rotaticnoriginal';
            arrowicn.className = arrowicn.className.replace('arrowiconrotate','');
            rotateicn.className = rotateicn.className.replace('rotaticn2','');
        }   
    }
    handleWealth(){
        if(this.isWealthcheck == false){
            this.isWealthcheck = true;
            this.businessIconmb = false;
            this.personalIcon = false;
            var arrowicn = this.template.querySelector('.arrow_iconwealth');
            arrowicn.className +=' arrowiconrotate';
            var rotateicn = this.template.querySelector('.rotate_wealth');
            rotateicn.className += ' rotaticn2';
            arrowicn.className = arrowicn.className.replace('arrowiconoriginal','');
            rotateicn.className = rotateicn.className.replace('rotaticnoriginal','');
       
        }else{
            this.isWealthcheck = false;
            var arrowicn = this.template.querySelector('.arrow_iconwealth');
            arrowicn.className += 'arrowiconoriginal';
            var rotateicn = this.template.querySelector('.rotate_wealth');
            rotateicn.className += ' rotaticnoriginal';
            arrowicn.className = arrowicn.className.replace('arrowiconrotate','');
            rotateicn.className = rotateicn.className.replace('rotaticn2','');
        }
    }
    handlePersonalSections(event) {
        if(this.personalSec == false){
            this.personalSec = true;
            this.showSecMobile = false;
            event.target.iconName='utility:chevronup';
        }else{
            this.personalSec = false;
            event.target.iconName = 'utility:chevronright';
        }  
    }
    handleBizConnectClose(){
        this.isBizConnect = false;
        this.showSecMobile = true;
    }
    HandleProdAndServBusiness(event) {
        if(this.prodAndServicesBusiness == false){
            this.prodAndServicesBusiness = true;
            this.showSecMobile = false;
            event.target.iconName='utility:chevronup';
        }else{
            this.prodAndServicesBusiness = false;
            event.target.iconName='utility:chevronright';
        }  
    }
    HandleProdAndSerPersonalclose(event){
        this.prodAndServicesBusiness = false;
        this.businessIconmb = true;
        this.showSecMobile = true;
        event.target.iconName='utility:chevronup';
    }
    HandleProdAndSerBusinessclose(){
        this.prodAndServicesBusiness = false;
        this.showSecMobile = true;
    }
    HandleShopPersonal(event) {
        if(  this.shopPersonal  == false){
            this.shopPersonal = true;
            this.showSecMobile = false;
            event.target.iconName='utility:chevronup';
        }else{
            this.shopPersonal = false;
            event.target.iconName='utility:chevronright';
        } 
    }
    HandleShopclose(){
        this.showSecMobile = true;
        this.shopPersonal = false;
    }
    HandleProdAndSerPersonalclose(){
        this.showSecMobile = true;
        this.personalSec = false;
        this.prodAndServicesBusiness=false;
    }
    HandleBankWithUsbusiness(){
        if(this.isBankWithUsBusiness == false){
            this.isBankWithUsBusiness = true;
            this.isBorrowForyourNeeds = false;
            this.isGrowYourBusinessbus = false;
            this.isInsureWhatMattersBusiness = false;
            this.isCustomerSolutionBus = false;
            this.isWaysToBankBusiness = false;
            this.isSecurityCentreBusiness = false;         
            var rotateicn = this.template.querySelector('.rotateiconinnerbwus');
            rotateicn.className += ' rotaticn2innerclrchange';
            var arrowicn = this.template.querySelector('.arrowiconinnerbwus');   
            arrowicn.className +=' arrowiconrotateinner';
        } else{
            this.isBankWithUsBusiness = false;
            var rotateicn = this.template.querySelector('.rotateiconinnerbwus');
            rotateicn.className += ' rotaticn2innerclrchangeoriginal';
            var arrowicn = this.template.querySelector('.arrowiconinnerbwus');   
            arrowicn.className +=' arrowiconrotateinneroriginal';
        }   
    }
    HandleSecurityCentreBusiness(){
        if(this.isSecurityCentreBusiness== false){
            this.isSecurityCentreBusiness = true;
            this.isBorrowForyourNeeds = false;
            this.isGrowYourBusinessbus = false;
            this.isInsureWhatMattersBusiness = false;
            this.isCustomerSolutionBus = false;
            this.isWaysToBankBusiness = false;
            this.isBankWithUsBusiness = false;
            var rotateicn = this.template.querySelector('.rotateiconinnerscb');
            rotateicn.className += ' rotaticn2innerclrchange';
            var arrowicn = this.template.querySelector('.arrowiconinnerscb');   
            arrowicn.className +=' arrowiconrotateinner';
        }else{
            this.isSecurityCentreBusiness = false;
            var rotateicn = this.template.querySelector('.rotateiconinnerscb');
            rotateicn.className += ' rotaticn2innerclrchangeoriginal';
            var arrowicn = this.template.querySelector('.arrowiconinnerscb');   
            arrowicn.className +=' arrowiconrotateinneroriginal';
        }
    }
    HandleBorrowNeedsBusiness(){
        if(this.isBorrowForyourNeeds == false){
            this.isBorrowForyourNeeds = true;
            this.isSecurityCentreBusiness = false;
            this.isGrowYourBusinessbus = false;
            this.isInsureWhatMattersBusiness = false;
            this.isCustomerSolutionBus = false;
            this.isWaysToBankBusiness = false;
            this.isBankWithUsBusiness = false;
            var rotateicn = this.template.querySelector('.rotateiconinnerbfyn');
            rotateicn.className += ' rotaticn2innerclrchange';
            var arrowicn = this.template.querySelector('.arrowiconinnerbfyn');   
            arrowicn.className +=' arrowiconrotateinner';
        }else{
            this.isBorrowForyourNeeds = false;  
            var rotateicn = this.template.querySelector('.rotateiconinnerbfyn');
            rotateicn.className += ' rotaticn2innerclrchangeoriginal';
            var arrowicn = this.template.querySelector('.arrowiconinnerbfyn');   
            arrowicn.className +=' arrowiconrotateinneroriginal';
        }
    }
    HandleWaysToBankBusiness(){
        if(this.isWaysToBankBusiness == false){
            this.isWaysToBankBusiness = true;
            this.isBorrowForyourNeeds = false;
            this.isSecurityCentreBusiness = false;
            this.isGrowYourBusinessbus = false;
            this.isInsureWhatMattersBusiness = false;
            this.isCustomerSolutionBus = false;
            this.isBankWithUsBusiness = false;
            var rotateicn = this.template.querySelector('.rotateiconinnerwtbb');
            rotateicn.className += ' rotaticn2innerclrchange';
            var arrowicn = this.template.querySelector('.arrowiconinnerwtbb');   
            arrowicn.className +=' arrowiconrotateinner';
        }else{
            this.isWaysToBankBusiness = false;
            var rotateicn = this.template.querySelector('.rotateiconinnerwtbb');
            rotateicn.className += ' rotaticn2innerclrchangeoriginal';
            var arrowicn = this.template.querySelector('.arrowiconinnerwtbb');   
            arrowicn.className +=' arrowiconrotateinneroriginal';
        }
    }
    HandleGrowYourMoneyBusiness(){
        if(this.isGrowYourBusinessbus == false){
            this.isGrowYourBusinessbus = true;
            this.isWaysToBankBusiness = false;
            this.isBorrowForyourNeeds = false;
            this.isSecurityCentreBusiness = false;
            this.isInsureWhatMattersBusiness = false;
            this.isCustomerSolutionBus = false;
            this.isBankWithUsBusiness = false;
            var rotateicn = this.template.querySelector('.rotateiconinnergymb');
            rotateicn.className += ' rotaticn2innerclrchange';
            var arrowicn = this.template.querySelector('.arrowiconinnergymb');   
            arrowicn.className +=' arrowiconrotateinner';
        }else{
            this.isGrowYourBusinessbus = false;
            var rotateicn = this.template.querySelector('.rotateiconinnergymb');
            rotateicn.className += ' rotaticn2innerclrchangeoriginal';
            var arrowicn = this.template.querySelector('.arrowiconinnergymb');   
            arrowicn.className +=' arrowiconrotateinneroriginal';
        }
    }
    HandleInsureWhatMattersBusiness(){
        if(this.isInsureWhatMattersBusiness == false){
            this.isInsureWhatMattersBusiness = true;
            this.isGrowYourBusinessbus = false;
            this.isWaysToBankBusiness = false;
            this.isBorrowForyourNeeds = false;
            this.isSecurityCentreBusiness = false;
            this.isCustomerSolutionBus = false;
            this.isBankWithUsBusiness = false;
            var rotateicn = this.template.querySelector('.rotateiconinneriwmb');
            rotateicn.className += ' rotaticn2innerclrchange';
            var arrowicn = this.template.querySelector('.arrowiconinneriwmb');   
            arrowicn.className +=' arrowiconrotateinner';
        }else{
            this.isInsureWhatMattersBusiness = false;
            var rotateicn = this.template.querySelector('.rotateiconinneriwmb');
            rotateicn.className += ' rotaticn2innerclrchangeoriginal';
            var arrowicn = this.template.querySelector('.arrowiconinneriwmb');   
            arrowicn.className +=' arrowiconrotateinneroriginal';
        }
    }
    HandleCustomerSolutionsBusiness(){
        if(this.isCustomerSolutionBus == false){
            this.isCustomerSolutionBus = true;
            this.isInsureWhatMattersBusiness = false;
            this.isGrowYourBusinessbus = false;
            this.isWaysToBankBusiness = false;
            this.isBorrowForyourNeeds = false;
            this.isSecurityCentreBusiness = false;
            this.isBankWithUsBusiness = false;
            var rotateicn = this.template.querySelector('.rotateiconinnercsb');
            rotateicn.className += ' rotaticn2innerclrchange';
            var arrowicn = this.template.querySelector('.arrowiconinnercsb');   
            arrowicn.className +=' arrowiconrotateinner';
        }else{
            this.isCustomerSolutionBus = false;
            var rotateicn = this.template.querySelector('.rotateiconinnercsb');
            rotateicn.className += ' rotaticn2innerclrchangeoriginal';
            var arrowicn = this.template.querySelector('.arrowiconinnercsb');   
            arrowicn.className +=' arrowiconrotateinneroriginal';
        }
    }
    HandleBankWithUs() {
        if(this.isBankWithUs == false){
            this.isBankWithUs = true;
            this.showSecMobile = false;
            this.isBorrowNeeds = false;
            this.isGrowYourMoney = false;
            this.isInsureWhatMatters = false;
            this.isWaysToBank = false;
            this.isCustomerSol = false;
            this.isSecurityCentre = false;
            var rotateicn = this.template.querySelector('.rotateiconinner');
            rotateicn.className += ' rotaticn2innerclrchange';
            rotateicn.classList.add('bg-nav-collapse');
            var arrowicn = this.template.querySelector('.arrowiconinner');   
            arrowicn.className +=' arrowiconrotateinner';
            arrowicn.className = arrowicn.className.replace('arrowiconrotateinneroriginal','');
            rotateicn.className = rotateicn.className.replace('rotaticn2innerclrchangeoriginal','');
        }else{
            this.isBankWithUs = false;
            var rotateicn = this.template.querySelector('.rotateiconinner');
            rotateicn.className += ' rotaticn2innerclrchangeoriginal';
            var arrowicn = this.template.querySelector('.arrowiconinner');   
            arrowicn.className +=' arrowiconrotateinneroriginal';
            arrowicn.className = arrowicn.className.replace('arrowiconrotateinner','');
            rotateicn.className = rotateicn.className.replace('rotaticn2innerclrchange','');
        }  
    }
    HandleBorrowNeeds() {
        if(this.isBorrowNeeds == false){
            this.isBorrowNeeds = true;
            this.showSecMobile = false;
            this.isGrowYourMoney = false;
            this.isInsureWhatMatters = false;
            this.isWaysToBank = false;
            this.isCustomerSol = false;
            this.isSecurityCentre = false;
            this.isBankWithUs = false;
            var rotateicn = this.template.querySelector('.rotateiconinnerbn');
            rotateicn.className += ' rotaticn2innerclrchange';
            var arrowicn = this.template.querySelector('.arrowiconinnerbn');   
            arrowicn.className +=' arrowiconrotateinner';
            arrowicn.className = arrowicn.className.replace('arrowiconrotateinneroriginal','');
            rotateicn.className = rotateicn.className.replace('rotaticn2innerclrchangeoriginal','');
        }else{
            this.isBorrowNeeds = false;
            var rotateicn = this.template.querySelector('.rotateiconinnerbn');
            rotateicn.className += ' rotaticn2innerclrchangeoriginal';
            var arrowicn = this.template.querySelector('.arrowiconinnerbn');   
            arrowicn.className +=' arrowiconrotateinneroriginal';
            arrowicn.className = arrowicn.className.replace('arrowiconrotateinner','');
            rotateicn.className = rotateicn.className.replace('rotaticn2innerclrchange','');
        }
    }
    HandleGrowYourMoney() {
        if(this.isGrowYourMoney == false){
            this.isGrowYourMoney = true;
            this.isBorrowNeeds = false;
            this.showSecMobile = false;
            this.isInsureWhatMatters = false;
            this.isWaysToBank = false;
            this.isCustomerSol = false;
            this.isSecurityCentre = false;
            this.isBankWithUs = false;
            var rotateicn = this.template.querySelector('.rotateiconinnergym');
            rotateicn.className += ' rotaticn2innerclrchange';
            var arrowicn = this.template.querySelector('.arrowiconinnergym');   
            arrowicn.className +=' arrowiconrotateinner';
            arrowicn.className = arrowicn.className.replace('arrowiconrotateinneroriginal','');
            rotateicn.className = rotateicn.className.replace('rotaticn2innerclrchangeoriginal','');
        }else{
            this.isGrowYourMoney = false;
            var rotateicn = this.template.querySelector('.rotateiconinnergym');
            rotateicn.className += ' rotaticn2innerclrchangeoriginal';
            var arrowicn = this.template.querySelector('.arrowiconinnergym');   
            arrowicn.className +=' arrowiconrotateinneroriginal';
            arrowicn.className = arrowicn.className.replace('arrowiconrotateinner','');
            rotateicn.className = rotateicn.className.replace('rotaticn2innerclrchange','');            
        }        
    }
    HandleInsureWhatMatters() {
        if(this.isInsureWhatMatters == false){
            this.isInsureWhatMatters = true;
            this.isGrowYourMoney = false;
            this.isBorrowNeeds = false;
            this.showSecMobile = false;
            this.isWaysToBank = false;
            this.isCustomerSol = false;
            this.isSecurityCentre = false;
            this.isBankWithUs = false;

            var rotateicn = this.template.querySelector('.rotateiconinneriwm');
            rotateicn.className += ' rotaticn2innerclrchange';
            var arrowicn = this.template.querySelector('.arrowiconinneriwm');   
            arrowicn.className +=' arrowiconrotateinner';
            arrowicn.className = arrowicn.className.replace('arrowiconrotateinneroriginal','');
            rotateicn.className = rotateicn.className.replace('rotaticn2innerclrchangeoriginal','');
        }else{
            this.isInsureWhatMatters = false;
            var rotateicn = this.template.querySelector('.rotateiconinneriwm');
            rotateicn.className += ' rotaticn2innerclrchangeoriginal';
            var arrowicn = this.template.querySelector('.arrowiconinneriwm');   
            arrowicn.className +=' arrowiconrotateinneroriginal';
            arrowicn.className = arrowicn.className.replace('arrowiconrotateinner','');
            rotateicn.className = rotateicn.className.replace('rotaticn2innerclrchange','');
        }   
    }
    handleBizConnect(event){
        if(this.isBizConnect == false){
            this.isBizConnect = true;
            this.showSecMobile = false;
            event.target.iconName='utility:chevronup';
        }else{
            this.isBizConnect = false;
            event.target.iconName='utility:chevronright';
        }
    }
    HandleWaysToBank() {
        if(this.isWaysToBank == false){
            this.isWaysToBank = true;
            this.isInsureWhatMatters = false;
            this.isGrowYourMoney = false;
            this.isBorrowNeeds = false;
            this.showSecMobile = false;
            this.isCustomerSol = false;
            this.isSecurityCentre = false;
            this.isBankWithUs = false;
            var rotateicn = this.template.querySelector('.rotateiconinnerhwb');
            rotateicn.className += ' rotaticn2innerclrchange';
            var arrowicn = this.template.querySelector('.arrowiconinnerhwb');   
            arrowicn.className +=' arrowiconrotateinner';
            arrowicn.className = arrowicn.className.replace('arrowiconrotateinneroriginal','');
            rotateicn.className = rotateicn.className.replace('rotaticn2innerclrchangeoriginal','');
        }else{
            this.isWaysToBank = false;
            var rotateicn = this.template.querySelector('.rotateiconinnerhwb');
            rotateicn.className += ' rotaticn2innerclrchangeoriginal';
            var arrowicn = this.template.querySelector('.arrowiconinnerhwb');   
            arrowicn.className +=' arrowiconrotateinneroriginal';
            arrowicn.className = arrowicn.className.replace('arrowiconrotateinner','');
            rotateicn.className = rotateicn.className.replace('rotaticn2innerclrchange','');
        }    
    }
    HandleCustomerSolutions() {
        if(this.isCustomerSol == false){
            this.isCustomerSol = true;
            this.isInsureWhatMatters = false;
            this.isGrowYourMoney = false;
            this.isBorrowNeeds = false;
            this.showSecMobile = false;
            this.isWaysToBank = false;
            this.isSecurityCentre = false;
            this.isBankWithUs = false;
            var rotateicn = this.template.querySelector('.rotateiconinnercs');
            rotateicn.className += ' rotaticn2innerclrchange';
            var arrowicn = this.template.querySelector('.arrowiconinnercs');   
            arrowicn.className +=' arrowiconrotateinner';
            arrowicn.className = arrowicn.className.replace('arrowiconrotateinneroriginal','');
            rotateicn.className = rotateicn.className.replace('rotaticn2innerclrchangeoriginal','');         
        }else{
            this.isCustomerSol = false;
            var rotateicn = this.template.querySelector('.rotateiconinnercs');
            rotateicn.className += ' rotaticn2innerclrchangeoriginal';
            var arrowicn = this.template.querySelector('.arrowiconinnercs');   
            arrowicn.className +=' arrowiconrotateinneroriginal';
            arrowicn.className = arrowicn.className.replace('arrowiconrotateinner','');
            rotateicn.className = rotateicn.className.replace('rotaticn2innerclrchange','');
        } 
    }
    HandleSecurityCentre() {
        if(this.isSecurityCentre == false){
            this.isSecurityCentre = true;
            this.isInsureWhatMatters = false;
            this.isGrowYourMoney = false;
            this.isBorrowNeeds = false;
            this.showSecMobile = false;
            this.isWaysToBank = false;
            this.isCustomerSol = false;
            this.isBankWithUs = false;
            var rotateicn = this.template.querySelector('.rotateiconinnersc');
            rotateicn.className += ' rotaticn2innerclrchange';
            var arrowicn = this.template.querySelector('.arrowiconinnersc');   
            arrowicn.className +=' arrowiconrotateinner';
            arrowicn.className = arrowicn.className.replace('arrowiconrotateinneroriginal','');
            rotateicn.className = rotateicn.className.replace('rotaticn2innerclrchangeoriginal','');
        }else{
            this.isSecurityCentre = false;
            var rotateicn = this.template.querySelector('.rotateiconinnersc');
            rotateicn.className += ' rotaticn2innerclrchangeoriginal';
            var arrowicn = this.template.querySelector('.arrowiconinnersc');   
            arrowicn.className +=' arrowiconrotateinneroriginal';
            arrowicn.className = arrowicn.className.replace('arrowiconrotateinner','');
            rotateicn.className = rotateicn.className.replace('rotaticn2innerclrchange','');
        } 
    }
    handleMouseover() {

        this.ismouseOverdefault = true;
        this.isMouseOver = true;
        this.isHandleShop = false;
        this.isBorrowNeedsleft = false;
        this.isGrowyourMoneyleft = false;
        this.isWhatmatters = false;
        this.isWaysTobankleft = false;
        this.isCustomerSolutions = false;
        this.isSecurityCentreleft = false;
    }
    handleMouseOutProductServices(event) {
        this.isMouseOver = false;
    }
    handleMouseOversigninto(event) {
        this.ismouseoversigninto = true;
    }
    handleMouseOutSigninto(event) {
        this.ismouseoversigninto = false;
    }
    handleMouseStandardbank() {
        this.isMouseOver = false;
        this.isHandleShop = false;
    }
    handleMouseUcountRewards() {
        this.isHandleShop = false;
    }
   
    HandleCallSearchApi(event) {
        event.stopPropagation();
        this.searchkey = event.target.value;
        this.isLoading = event.target.value.length >= 3;
        fetchSearchProducts({
            searchString: this.searchkey
        }).then(result => {  
            this.innerhtmlscer = true;
            if( FORM_FACTOR && FORM_FACTOR === 'Large'){
                this.showResults = result;
                this.showResults = this.showResults.replaceAll("row", 'slds-grid slds-wrap');
                this.showResults = this.showResults.replaceAll("col-md-6", 'slds-col slds-size_1-of-2');
                this.showResults = this.showResults.replaceAll("d-block", "slds-show");
                this.showResults = this.showResults.replaceAll('<h4>', '<h4 class="slds-text-heading_large">');
                this.showResults = this.showResults.replaceAll('<img', '<img class="slds-media_small slds-media__figure"' + 'style="width:18vw;height=18vh"');
                this.showResults = this.showResults.replaceAll('<p>', '<p class="slds-media__body">');
                this.showResults = this.showResults.replaceAll("pl-lg-3", 'slds-media__body');
                this.showResults = this.showResults.replaceAll("d-md-none", "slds-hidden slds-hide");
                this.showResults = this.showResults.replaceAll('"overflow-hidden mb-2"', '"slds-scrollable_none slds-m-bottom_medium"' + ' style="margin-bottom:-4%;"');
                this.showResults = this.showResults.replaceAll("float-md-right", "slds-float_right");
                this.showResults = this.showResults.replaceAll("font-weight-bold", "slds-text-heading_medium");
                this.showResults = this.showResults;
                this.isLoading = false;
            }else if(FORM_FACTOR && FORM_FACTOR === 'Small'){
                this.showResults = result;
                this.showResults = this.showResults.replaceAll("d-block", "slds-show");
                this.showResults = this.showResults.replaceAll('<h4>', '<h4 class="slds-text-heading_medium">');
                this.showResults = this.showResults.replaceAll("font-weight-bold", "slds-text-heading_medium");
                this.showResults = this.showResults.replaceAll("col-md-6\"", '" style="margin:20px";');    
                this.showResults = this.showResults.replaceAll("search-block\"", '" style="margin-bottom:15px";');    
                this.showResults = this.showResults.replaceAll("order-md-0\"", '" style="margin:20px";');            
                this.showResults = this.showResults.replaceAll("search-item\"", '" style="display:block";');  
                this.showResults = this.showResults.replaceAll("font-weight-bold", "slds-text-heading_medium");
                this.showResults = this.showResults.replaceAll("mb-2\"", '" style="margin-bottom: 5px";');  
                this.isLoading = false;
            }else if( FORM_FACTOR && FORM_FACTOR === 'Medium'){
                this.showResults = result;
                this.showResults = this.showResults.replaceAll("row", 'slds-grid slds-wrap');
                this.showResults = this.showResults.replaceAll("col-md-6", 'slds-col slds-size_1-of-2');
                this.showResults = this.showResults.replaceAll("d-block", "slds-show");
                this.showResults = this.showResults.replaceAll('<h4>', '<h4 class="slds-text-heading_large">');
                this.showResults = this.showResults.replaceAll('<img', '<img class="slds-media_small slds-media__figure"' + 'style="width:18vw;height=18vh"');
                this.showResults = this.showResults.replaceAll('<p>', '<p class="slds-media__body">');
                this.showResults = this.showResults.replaceAll("pl-lg-3", 'slds-media__body');
                this.showResults = this.showResults.replaceAll("d-md-none", "slds-hidden slds-hide");
                this.showResults = this.showResults.replaceAll('"overflow-hidden mb-2"', '"slds-scrollable_none slds-m-bottom_medium"' + ' style="margin-bottom:-4%;"');
                this.showResults = this.showResults.replaceAll("float-md-right", "slds-float_right");
                this.showResults = this.showResults.replaceAll("font-weight-bold", "slds-text-heading_medium");
                this.showResults = this.showResults;
                this.isLoading = false;
            }    
        }).catch(error => {

        })
    }
}