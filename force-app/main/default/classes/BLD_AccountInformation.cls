@IsTest
public class BLD_AccountInformation extends ABS_ObjectBuilderBase {
	
	public BLD_AccountInformation() { 
        this(getNewUnitOfWork());        
    }

    public BLD_AccountInformation(fflib_SObjectUnitOfWork workUnit) { 
        super(Account_Information__c.SObjectType, workUnit);
    }

    public BLD_AccountInformation(Account_Information__c sObj, fflib_SObjectUnitOfWork workUnit) {
        super(sObj,workUnit); 
    }

   	protected override void setDefaultData(){

    }

    public BLD_AccountInformation client(ABS_ObjectBuilderBase accountBld){
		return (BLD_AccountInformation)setField(Account_Information__c.Account_Name__c, ((Account)accountBld.getRecord()).Name)
                            .setRelation(Account_Information__c.Client__c, accountBld);
	}

	public BLD_AccountInformation client(Id accId){
		return (BLD_AccountInformation)setField(Account_Information__c.Client__c, accId);
	}

    public BLD_AccountInformation accountName(String accountName){
        return (BLD_AccountInformation)setField(Account_Information__c.Account_Name__c, accountName);
    }

    public BLD_AccountInformation currentBalance(Decimal currentBalance){
        return (BLD_AccountInformation)setField(Account_Information__c.Current_Balance__c, currentBalance);
    }

    public BLD_AccountInformation currentLimit(Integer currentLimit){
        return (BLD_AccountInformation)setField(Account_Information__c.Current_Limit__c, currentLimit);
    }

    public BLD_AccountInformation erl(Integer erl){
        return (BLD_AccountInformation)setField(Account_Information__c.ERL__c, erl);
    }

    public BLD_AccountInformation expectedMonthlyTurnover(Integer expMonthlyTurnover){
        return (BLD_AccountInformation)setField(Account_Information__c.Expected_Monthly_Turnover__c, expMonthlyTurnover);
    }

    public BLD_AccountInformation headroom(Integer headroom){
        return (BLD_AccountInformation)setField(Account_Information__c.Headroom__c, headroom);
    }

    public BLD_AccountInformation name(String name){
        return (BLD_AccountInformation)setField(Account_Information__c.Name, name);
    }

    public BLD_AccountInformation pmtExtractDate(Date extractDate){
        return (BLD_AccountInformation)setField(Account_Information__c.PMT_Extract_Date__c, extractDate);
    }

    public BLD_AccountInformation productCategory(String category){
        return (BLD_AccountInformation)setField(Account_Information__c.Product_Category__c, category);
    }
}