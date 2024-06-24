/**
 * API GET Rp details Configuration
 * 
 * @author Dayakar
 *
 * @date Oct 29th 2021
 */
public class AOB_DTO_GETRpDetails{
	public List<MandRelatedPart> mandRelatedPart;

	public class RelatedParties_Z {
		public String reltyp;
		public Integer minReq;
		public Integer maxNo;
	}

	public class MandRelatedPart {
		public String legalEnt;
		public Integer ruleNum;
		public String text;
		public List<RelatedParties> relatedParties;
	}

	public class RelatedParties {
		public String reltyp;
		public Integer minReq;
	}

	
	
}