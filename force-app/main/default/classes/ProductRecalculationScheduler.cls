/**
 * Schedulable class to call queue the BCH_ProductCyRecalculation
 * batch at the start of each year
 *
 * @author		Youssef Ibrahim (yibrahim@deloittece.com)
 * @date		March 2021
*/
public with sharing class ProductRecalculationScheduler implements Schedulable{

    /**
    * Overridden execute Schedulable method
    *
    * @param scContext default reference to SchedulableContext
    */
    public void execute(SchedulableContext scContext) {
        BCH_ProductCyRecalculation  bch = new BCH_ProductCyRecalculation();
        Database.executeBatch(bch,50);
    }
}