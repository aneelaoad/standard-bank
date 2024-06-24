/*************************************************************************************************************************************************************************
    @ Author        : Nitish Kumar
    @ Date          : Sept 2014
    @ Test File     : 
    @ Description   : Utility class for Opportunity Management functionality.
                      Consists of all the Wrapper class used in OMDashboardController
                      Case Description  C-00001133 : Objective is to provide a global dashboard for executives on mobile.
                      It looks at typical Sales Metrics such as pipeline, top opportunities and top clients.
                      These KPIs are defined per Franco, Sector and teams The dashboard be accessible from the SF1 app.
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    @ Last Modified By      : Prabhanshu Agrawal
    @ Last Modified On      : Feb 2015
    @ Last Modified Reason  : En-579    
*************************************************************************************************************************************************************************/
global with sharing class OMDashboardUtilityClass {

   public class omOppClosedFrancoView implements Comparable{

      public string oppFranco {
         get;
         set;
      }

      public string oppName {
         get;
         set;
      }

      public string oppId {
         get;
         set;
      }

      public string clientName {
         get;
         set;
      }

      public string clientId {
         get;
         set;
      }

      public Decimal cYearRev {
         get;
         set;
      }

      public Decimal tYearRev {
         get;
         set;
      }

      public omOppClosedFrancoView(String franco, string oName, string oId, string cName, string cId, Decimal cRev, Decimal tRev) {

         this.oppFranco = franco;
         this.oppName = oName;
         this.oppId = oId;
         this.clientName = cName;
         this.clientId = cId;
         this.cYearRev = cRev;
         this.tYearRev = tRev;

      }
      
      // Compare opportunities based on the opportunity current year revenue converted.
      public Integer compareTo(Object compare) {
        // Cast argument to OpportunityWrapper
        omOppClosedFrancoView compareTo = (omOppClosedFrancoView)compare;
        
        // The return value of 0 indicates that both elements are equal.
        Integer returnValue = 0;
        if (this.cYearRev > compareTo.cYearRev) {
            // Set return value to a positive value.
            returnValue = -1;
        } else if (this.cYearRev < compareTo.cYearRev) {
            // Set return value to a negative value.
            returnValue = 1;
        }
        
        return returnValue;       
    }
   
   }
  
   //Wrapper Object for Opportunity

   public class omOpportunity {

      public string oppFranco {
         get;
         set;
      }

      public Decimal pipeLineRev {
         get;
         set;
      }

      public Decimal ClosedWonRev {
         get;
         set;
      }

      public Decimal ClosedLostRev {
         get;
         set;
      }

      public Decimal ClosedWonRevLM {
         get;
         set;
      }

      public Decimal ClosedLostRevLM {
         get;
         set;
      }

      public Decimal convRatio {
         get;
         set;
      }

      public Decimal convRatioPM {
         get;
         set;
      }

      public Integer oppCount {
         get;
         set;
      }
      
      public Decimal totalRev {
         get;
         set;
      }
      
      public omOpportunity() {}

      public omOpportunity(String franco, Decimal pRev, Decimal wRev, Decimal lRev, Decimal wpMRev, Decimal lpMRev, Integer oCount, Decimal totRev) {

         this.oppFranco = franco;
         this.pipeLineRev = pRev;
         this.ClosedWonRev = wRev;
         this.ClosedLostRev = lRev;
         this.ClosedWonRevLM = wpMRev;
         this.ClosedLostRevLM = lpMRev;
         this.oppCount = oCount;
         if ((ClosedLostRev + ClosedWonRev) > 0) {
            this.convRatio = (ClosedWonRev) / (ClosedLostRev + ClosedWonRev);
         } else {
            this.convRatio = 0;
         }
         if ((ClosedWonRevLM + ClosedLostRevLM) > 0) {
            this.convRatioPM = (ClosedWonRevLM) / (ClosedLostRevLM + ClosedWonRevLM);
         } else {
            this.convRatioPM = 0;
         }
         this.totalRev = totRev ;
      }

   }

   public class omOpportunityDiv {

      public string oppFranco {
         get;
         set;
      }

      public Decimal cCovRev {
         get;
         set;
      }

      public Decimal gmRev {
         get;
         set;
      }

      public Decimal ibRev {
         get;
         set;
      }

      public Decimal tpsRev {
         get;
         set;
      }

      public Decimal reRev {
         get;
         set;
      }

      public Decimal beRev {
         get;
         set;
      }

      public Decimal glmRev {
         get;
         set;
      }

      public Decimal totalRev {
         get;
         set;
      }

      public Decimal currYearRev {
         get;
         set;
      }

      public Integer oppPipelineCount {
         get;
         set;
      }

      public omOpportunityDiv(String franco, Decimal cRev, Decimal gRev, Decimal iRev, Decimal tRev, Decimal rRev, Decimal bRev, Decimal glRev, Decimal totRev, Decimal cyRev, Integer pCount) {

         this.oppFranco = franco;
         this.cCovRev = cRev;
         this.gmRev = gRev;
         this.ibRev = iRev;
         this.tpsRev = tRev;
         this.reRev = rRev;
         this.beRev = bRev;
         this.glmRev = glRev;
         this.totalRev = totRev;
         this.currYearRev = cyRev;
         this.oppPipelineCount = pCount;

      }

   }

   public class omOpportunityTop implements Comparable{

      public string oppFranco {
         get;
         set;
      }

      public string oppName {
         get;
         set;
      }

      public string oppId {
         get;
         set;
      }

      public string clientName {
         get;
         set;
      }

      public string clientId {
         get;
         set;
      }

      public Decimal cYearRev {
         get;
         set;
      }
 
      public Decimal tYearRev {
         get;
         set;
      } 
 

      public omOpportunityTop(String franco, string oName, string oId, string cName, string cId, Decimal cRev, Decimal tRev) {

         this.oppFranco = franco;
         this.oppName = oName;
         this.oppId = oId;
         this.clientName = cName;
         this.clientId = cId;
         this.cYearRev = cRev;
         this.tYearRev = tRev;

      }
      
          // Compare opportunities based on the opportunity current year revenue converted.
      public Integer compareTo(Object compare) {
        // Cast argument to OpportunityWrapper
        omOpportunityTop compareTo = (omOpportunityTop)compare;
        
        // The return value of 0 indicates that both elements are equal.
        Integer returnValue = 0;
        if (this.cYearRev > compareTo.cYearRev) {
            // Set return value to a positive value.
            returnValue = -1;
        } else if (this.cYearRev < compareTo.cYearRev) {
            // Set return value to a negative value.
            returnValue = 1;
        }
        
        return returnValue;       
    }
      

   }
  
   //Wrapper Object for Closed Opportunity

   public class omOpportunityClosed {

      public string oppFranco {
         get;
         set;
      }

      public Decimal ClosedWonCYRev {
         get;
         set;
      }

      public Decimal ClosedWonPYRev {
         get;
         set;
      }

      public Decimal ClosedLostCYRev {
         get;
         set;
      }

      public Decimal ClosedLostPYRev {
         get;
         set;
      }

      public Decimal ClosedWonLM {
         get;
         set;
      }

      public Decimal ClosedLostLM {
         get;
         set;
      }

      public Decimal convRatio {
         get;
         set;
      }

      public Decimal convRatioLM {
         get;
         set;
      }
      
      public omOpportunityClosed(){}

      public omOpportunityClosed(String franco, Decimal wCYRev, Decimal wPYRev, Decimal lCYRev, Decimal lPYMRev, Decimal wpMRev, Decimal lpMRev) {

         this.oppFranco = franco;
         this.ClosedWonCYRev = wCYRev;
         this.ClosedWonPYRev = wPYRev;
         this.ClosedLostCYRev = lCYRev;
         this.ClosedLostPYRev = lPYMRev;
         this.ClosedWonLM = wpMRev;
         this.ClosedLostLM = lpMRev;
         if ((ClosedLostCYRev + ClosedWonCYRev) > 0) {
            this.convRatio = (ClosedWonCYRev) / (ClosedLostCYRev + ClosedWonCYRev);
         } else {
            this.convRatio = 0;
         }
         if ((ClosedWonLM + ClosedLostLM) > 0) {
            this.convRatioLM = (ClosedWonLM) / (ClosedLostLM + ClosedWonLM);
         } else {
            this.convRatioLM = 0;
         }

      }

   }

   //Wrapper Object for Opportunity By Sector

   public class omOpportunitySector {

      public string oppSector {
         get;
         set;
      }

      public Decimal pipeLineRev {
         get;
         set;
      }

      public Decimal ClosedWonRev {
         get;
         set;
      }

      public Decimal ClosedLostRev {
         get;
         set;
      }

      public Decimal ClosedWonRevLM {
         get;
         set;
      }

      public Decimal ClosedLostRevLM {
         get;
         set;
      }

      public Decimal convRatio {
         get;
         set;
      }

      public Decimal convRatioPM {
         get;
         set;
      }

      public Integer oppCount {
         get;
         set;
      }
      
        public Decimal totalRev {
         get;
         set;
      }
     
      public omOpportunitySector() {}

      public omOpportunitySector(String sector, Decimal pRev, Decimal wRev, Decimal lRev, Decimal wpMRev, Decimal lpMRev, Integer oCount, Decimal totRev) {

         this.oppSector = sector;
         this.pipeLineRev = pRev;
         this.ClosedWonRev = wRev;
         this.ClosedLostRev = lRev;
         this.ClosedWonRevLM = wpMRev;
         this.ClosedLostRevLM = lpMRev;
         this.oppCount = oCount;
         if ((ClosedLostRev + ClosedWonRev) > 0) {
            this.convRatio = (ClosedWonRev) / (ClosedLostRev + ClosedWonRev);
         } else {
            this.convRatio = 0;
         }
         if ((ClosedWonRevLM + ClosedLostRevLM) > 0) {
            this.convRatioPM = (ClosedWonRevLM) / (ClosedLostRevLM + ClosedWonRevLM);
         } else {
            this.convRatioPM = 0;
         }
         this.totalRev = totRev ;
      }

   }

   public class omOpportunitySecDiv {

      public string oppSector {
         get;
         set;
      }

      public Decimal cCovRev {
         get;
         set;
      }

      public Decimal gmRev {
         get;
         set;
      }

      public Decimal ibRev {
         get;
         set;
      }

      public Decimal tpsRev {
         get;
         set;
      }

      public Decimal reRev {
         get;
         set;
      }

      public Decimal beRev {
         get;
         set;
      }

      public Decimal glmRev {
         get;
         set;
      }

      public Decimal totalRev {
         get;
         set;
      }

      public Decimal currYearRev {
         get;
         set;
      }

      public Integer oppPipelineCount {
         get;
         set;
      }

      public omOpportunitySecDiv(String sector, Decimal cRev, Decimal gRev, Decimal iRev, Decimal tRev, Decimal rRev, Decimal bRev, Decimal glRev, Decimal totRev, Decimal cyRev, Integer pCount) {

         this.oppSector = sector;
         this.cCovRev = cRev;
         this.gmRev = gRev;
         this.ibRev = iRev;
         this.tpsRev = tRev;
         this.reRev = rRev;
         this.beRev = bRev;
         this.glmRev = glRev;
         this.totalRev = totRev;
         this.currYearRev = cyRev;
         this.oppPipelineCount = pCount;

      }

   }

   //Wrapper Object for Closed Opportunity

   public class omOpportunitySecClosed {

      public string oppSector {
         get;
         set;
      }

      public Decimal ClosedWonCYRev {
         get;
         set;
      }

      public Decimal ClosedWonPYRev {
         get;
         set;
      }

      public Decimal ClosedLostCYRev {
         get;
         set;
      }

      public Decimal ClosedLostPYRev {
         get;
         set;
      }

      public Decimal ClosedWonLM {
         get;
         set;
      }

      public Decimal ClosedLostLM {
         get;
         set;
      }

      public Decimal convRatio {
         get;
         set;
      }

      public Decimal convRatioLM {
         get;
         set;
      }
      
      public omOpportunitySecClosed(){}

      public omOpportunitySecClosed(String sector, Decimal wCYRev, Decimal wPYRev, Decimal lCYRev, Decimal lPYMRev, Decimal wpMRev, Decimal lpMRev) {

         this.oppSector = sector;
         this.ClosedWonCYRev = wCYRev;
         this.ClosedWonPYRev = wPYRev;
         this.ClosedLostCYRev = lCYRev;
         this.ClosedLostPYRev = lPYMRev;
         this.ClosedWonLM = wpMRev;
         this.ClosedLostLM = lpMRev;
         if ((ClosedLostCYRev + ClosedWonCYRev) > 0) {
            this.convRatio = (ClosedWonCYRev) / (ClosedLostCYRev + ClosedWonCYRev);
         } else {
            this.convRatio = 0;
         }
         if ((ClosedWonLM + ClosedLostLM) > 0) {
            this.convRatioLM = (ClosedWonLM) / (ClosedLostLM + ClosedWonLM);
         } else {
            this.convRatioLM = 0;
         }

      }

   }

   public class omOpportunityClosedFranco {

      public string oppFranco {
         get;
         set;
      }
     
       public string oppSector {
         get;
         set;
      }
      
        public Decimal WonPY {
         get;
         set;
      }
      
      public Decimal WonCY {
         get;
         set;
      }
      
       public Decimal LostPY {
         get;
         set;
      }
      
      public Decimal LostCY {
         get;
         set;
      }
      
        public Decimal convRatio {
         get;
         set;
      }
      
      public Decimal totWonCY {
         get;
         set;
      }
      
      public Decimal totLostCY {
         get;
         set;
      }
      
      public Integer oPPCount {
        get;
        set;
      }
      
       public omOpportunityClosedFranco(){}
      
      public omOpportunityClosedFranco (String franco , String sector , Decimal wpy , Decimal wcy , Decimal lpy , Decimal lcy){
        
        this.oppFranco = franco ;
        this.oppSector = sector ;
        this.WonPY = wpy ;
        this.WonCY = wcy ; 
        this.LostPY = lpy ;
        this.LostCY = lcy ;
         if (WonCY + LostCY > 0) {
            this.convRatio = (WonCY) / (WonCY + LostCY);
         } else {
            this.convRatio = 0;
         }
      }
      
        public omOpportunityClosedFranco (String franco , String sector , Decimal wpy , Decimal wcy , Decimal lpy , Decimal lcy, Decimal twcy , Decimal tlcy, Integer opcount ){
        
        this.oppFranco = franco ;
        this.oppSector = sector ;
        this.WonPY = wpy ;
        this.WonCY = wcy ; 
        this.LostPY = lpy ;
        this.LostCY = lcy ;
        this.totWonCY = twcy ;
        this.totLostCY = tlcy ;
        this.oPPCount = opcount ;
         if (WonCY + LostCY > 0) {
            this.convRatio = (WonCY) / (WonCY + LostCY);
         } else {
            this.convRatio = 0;
         }
      }
      
      
    }

   public class omOpportunitySecTop implements Comparable{

      public string oppSector {
         get;
         set;
      }

      public string oppName {
         get;
         set;
      }

      public string oppId {
         get;
         set;
      }

      public string clientName {
         get;
         set;
      }

      public string clientId {
         get;
         set;
      }

      public Decimal cYearRev {
         get;
         set;
      }

      public Decimal tYearRev {
         get;
         set;
      }


      public  omOpportunitySecTop(String sector, string oName, string oId, string cName, string cId, Decimal cRev, Decimal tRev) {

         this.oppSector = sector;
         this.oppName = oName;
         this.oppId = oId;
         this.clientName = cName;
         this.clientId = cId;
         this.cYearRev = cRev;
         this.tYearRev = tRev;

      }

          // Compare opportunities based on the opportunity current year revenue converted.
      public Integer compareTo(Object compare) {
        // Cast argument to OpportunityWrapper
        omOpportunitySecTop compareTo = (omOpportunitySecTop)compare;
        
        // The return value of 0 indicates that both elements are equal.
        Integer returnValue = 0;
        if (this.cYearRev > compareTo.cYearRev) {
            // Set return value to a positive value.
            returnValue = -1;
        } else if (this.cYearRev < compareTo.cYearRev) {
            // Set return value to a negative value.
            returnValue = 1;
        }
        
        return returnValue;       
    }
      
   }
 
   public class omOpportunityPipelineFranco {

      public string oppFranco {
         get;
         set;
      }

      public string oppSector {
         get;
         set;
      }

      public Decimal beRev {
         get;
         set;
      }

      public Decimal cCovRev {
         get;
         set;
      }

      public Decimal glmRev {
         get;
         set;
      }

      public Decimal gmRev {
         get;
         set;
      }

      public Decimal ibRev {
         get;
         set;
      }

      public Decimal reRev {
         get;
         set;
      }

      public Decimal tpsRev {
         get;
         set;
      }

      public Decimal totalRev {
         get;
         set;
      }

      public Decimal currYearRev {
         get;
         set;
      }
      
       public Decimal totalcurrYearRev {
         get;
         set;
      }

      public Integer oppPipelineCount {
         get;
         set;
      }
      
      public omOpportunityPipelineFranco(){
        
      }

      public omOpportunityPipelineFranco(String franco, String sector, Decimal beRev, Decimal cbRev, Decimal gmngRev, Decimal glmRev, Decimal ibRev, Decimal reRev, Decimal tpsRev, Decimal totRev, Decimal cyRev, Integer pCount) {

         this.oppFranco = franco;
         this.oppSector = sector;
         this.beRev = beRev;
         this.cCovRev = cbRev;
         this.glmRev = gmngRev;
         this.gmRev = glmRev;
         this.ibRev = ibRev;
         this.reRev = reRev;
         this.tpsRev = tpsRev;
         this.totalRev = totRev;
         this.currYearRev = cyRev;
         this.oppPipelineCount = pCount;
        
         //Added 
         this.totalcurrYearRev = beRev + cbRev + gmngRev + glmRev + ibRev + reRev + tpsRev ;
        
       }
    }
}