/**
 * IB Online Opportunity api
 * US-4660
 *
 * @author Wayne Solomon
 * @date 28 Apr 2020
 */
public abstract class IBO_OpportunityServiceAbstract {
    public abstract IBOnlineOpportunitiesWrapper getOpportunities(String cif);

    public class IBOnlineOpportunitiesWrapper {
        List<IBOnlineOpportunitiesContentWrapper> opportunities;
        public IBOnlineOpportunitiesWrapper(List<IBOnlineOpportunitiesContentWrapper> opportunities){
            this.opportunities = opportunities;
        }
    }
    public class IBOnlineOpportunitiesContentWrapper {
        String cif;
        String accName;
        String oppId;
        String oppName;
        String oppStage;
        String oppOwner;
        public IBOnlineOpportunitiesContentWrapper(String cif,String accName, String oppId, String oppName,String oppStage, String oppOwner){
            this.cif = cif;
            this.accName = accName;
            this.oppId = oppId;
            this.oppName = oppName;
            this.oppStage = oppStage;
            this.oppOwner =  oppOwner;
        }
    }
}