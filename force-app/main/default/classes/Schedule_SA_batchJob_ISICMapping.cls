global class Schedule_SA_batchJob_ISICMapping implements Schedulable {

    global void execute(SchedulableContext sc) {
        SA_batchJob_ISICMapping b = new SA_batchJob_ISICMapping();
        database.executebatch(b);        
    }


}