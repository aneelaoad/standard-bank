/*************************************************************************\
    @ Author        :     Nitish Kumar
    @ Date          :     July,2013
    @ Test File     :     EventRep_Email_TaskDet_Controller Class
    @description   :     EventRep_Email_TaskDet_Controller to be tested
    
    @ Last Modified By  :   Charles Mutsu    
    @ Last Modified On  :   05-Aug-2013
    @ Description   :       Updated API version from 27 to 28 
    
****************************************************************************/
@IsTest
public class EventRep_Email_TaskDet_Controller_test {


    @IsTest
    static void testClass() {
        fflib_SObjectUnitOfWork uow = ABS_ObjectBuilderBase.getNewUnitOfWork();
        new BLD_Account(uow)
            .addTask(new BLD_Task(uow));
        uow.commitWork();

        Boolean isExceptionThrown = false;
        try {
            EventRep_Email_TaskDet_Controller cont = new EventRep_Email_TaskDet_Controller ();
            cont.TaskStatus = 'Open' ;
            cont.getTaskDet();
            EventRep_Email_TaskDet_Controller cont2 = new EventRep_Email_TaskDet_Controller ();
            cont2.TaskStatus = 'In Progress';
            cont2.getTaskDet();
        }
        catch(Exception ex) {
            isExceptionThrown = true;
        }
        System.assert(!isExceptionThrown);
    }
}