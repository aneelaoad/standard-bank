global class ClientOperCountry implements Comparable{

        public Client_Operating_Countries__c coCountry {
            get;
            set;
        }
        public String cocStatus {
            get;
            set;
        }
        
        public String cocCountry {
            get;
            set;
        }
        
        public boolean cibPresence {
            get;
            set;
        }
		
		// COnstructor for custom wrapper class.
        public ClientOperCountry(Client_Operating_Countries__c coc, String status , String country,Boolean presence ) {
            coCountry = coc;
            cocStatus = status;
            cocCountry = country ;
            cibPresence = presence;
            coCountry.status__c = status;
            coCountry.cib_presence__c = presence;
            coCountry.country__c = country;
        }
        // overloaded constructor of custom wrapper class.
         public ClientOperCountry(Client_Operating_Countries__c coc,  String country, Boolean presence) {
            coCountry = coc;
            cocCountry = country ;
            cibPresence = presence;
            coCountry.country__c = country;
            coCountry.cib_presence__c = presence;
        }
        
        global Integer compareTo(Object other) {
        	ClientOperCountry otherOpCountry = (ClientOperCountry)other;
        		return  this.cocCountry.compareTo(otherOpCountry.cocCountry);
        		/*
        		if(this.cocCountry>otherOpCountry.cocCountry)
        		  return 1;
        		  else if(this.cocCountry<otherOpCountry.cocCountry)
        		   return -1;
        		   else
        		   return 0;
        		   */
        	}
        
        
    }