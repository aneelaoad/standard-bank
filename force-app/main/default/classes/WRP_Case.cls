public class WRP_Case extends WRP_SObject{
	public WRP_Case(Case record) {
		super(record);
	}

	public Case getRecord(){
		return (Case)record;
	}

	public Boolean isClosed(){
		return (getRecord()!=null && 
					(getRecord().Status == DMN_Case.STATUS_CLOSED
					|| getRecord().Status == DMN_Case.STATUS_CANCELLED
					|| getRecord().Status == DMN_Case.STATUS_REQUEST_COMPLETED) );
	}
}