/**
 * Builder class for Vote SObject
 *
 * @author      Ephetehe Mokgopanyane (ephetehe.mokgopanyane@tetrad.co.za)
 * @date        May 2020
 */
@IsTest
public with sharing class BLD_Vote extends ABS_ObjectBuilderBase{
    
	public BLD_Vote() {
        this(getNewUnitOfWork());
    }

    public BLD_Vote(fflib_SObjectUnitOfWork uow) {
        super(Vote.SObjectType, uow);
    }

    public BLD_Vote(Vote vote, fflib_SObjectUnitOfWork uow) {
        super(vote, uow);
    }
	
    public BLD_Vote parentId(Id parentId) {
        return(BLD_Vote)setField(Vote.ParentId, parentId);
    }
    
    public BLD_Vote voteType(String voteType) {
        return(BLD_Vote)setField(Vote.Type, voteType);
    }
}