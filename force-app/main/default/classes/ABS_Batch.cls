/**
* @author Artur Kepczynski
* @date   May 2018
* @description Base class for batches, allows easier Batch managment
* @usage use it as a base for batch classes via [batchName] extends ABS_Batch
 *
*/
public virtual without sharing class ABS_Batch implements Schedulable {
    
    protected String runTime{
        get{
            if(runTime == null){
                runTime = buildTimeCode();
            }
            return runTime;
        }
        set;
    }
    private static Integer hour =0, minutes = 0, idx = 0;
    private String currentClassName{
        get{
            if(currentClassName == null){
                currentClassName = String.valueOf(this).split(':')[0];
            }
            return currentClassName;
        }
        set;
    }
    
    private String buildTimeCode(){
        
        String runTime = '0 ' + minutes + ' ' + hour + ' * * ? *' ;
    
        hour += minutes == 0 ? 0 : 1;
        minutes = minutes == 0 ? 30 : 0;
        
        return runTime;
    }
    
    /**
     * Run curent batch instance
     **/
    public void run(){
        run(null);
    }
    
    private void run(String className){
        Object obj;
        if (className != null) {
            obj = buildNewInstance(className);
        } else {
            obj = this;
        }
    
        if(obj instanceof  Database.Batchable<Sobject>){
            Database.Batchable<Sobject> batch = (Database.Batchable<Sobject>)obj;
            Database.executebatch(batch);
        }
        else{
            throw new ABS_BatchException('This class can only be extended by classes implemention Batchable interface!');
        }
    }
    
    /**
     * Run list classes that extends ABS_Batch class
     **/
    public static void runAll(){
        for(ApexClass ac : getAllchildClasses()){
            if(ac.Name != 'ABS_Batch'){
                new ABS_Batch().run(ac.Name);
            }
        }
    }
    
    private static Object buildNewInstance(String className){
        Type customType = Type.forName(className);
        return customType.newInstance();
    }
    
    /**
     * Schedule current class
     **/
    public void schedule(){
        schedule(currentClassName);
    }
    
    private void schedule(String className){
        ABS_Batch SC = (ABS_Batch)buildNewInstance(className);
        System.schedule(className, runTime, SC);
    }
    
    /**
     * Schedule list of classes that extends ABS_Batch class
     **/
    public static void scheduleAll(){
        for(ApexClass ac : getAllchildClasses()){
            if(ac.Name != 'ABS_Batch'){
                new ABS_Batch().schedule(ac.Name);
            }
        }
    }
    
    /**
     * Execute method implementation for Schedulable interface
     **/
    public void execute(SchedulableContext sc) {
        run();
    }
    
    private static ApexClass[] getAllchildClasses(){
        return [FIND 'extends ABS_Batch'
                IN ALL FIELDS
                RETURNING ApexClass(Id, Name)][0];
    }
    
    public class ABS_BatchException extends Exception{}
}