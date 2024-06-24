/**
 * @description Utility class for Resourcing functionality
 *
 * @author Konrad Bruszewski
 * @date October 2021
 */
public with sharing class UTL_Resourcing {

    public static final String RESOURCING_PERMISSION_SET = 'Resourcing';
    public static final String ADMINS_GROUP_DEVELOPER_NAME = 'Corporate_Finance_Resourcing_Admins';

    /**
     * Returns date of the Friday in the previous calendar week
     *
     * @return Date
     */
    public static Date getLastWeekFridayDate() {
        return getWeekDayDate(5).addDays(-7);
    }

    /**
     * Returns date of given week day in the current calendar week
     *
     * @param weekDay - Day of the week as Integer (1 for Monday, 2 for Tuesday etc.)
     *
     * @return Date
     */
    public static Date getWeekDayDate(Integer weekDay) {
        if (weekDay > 7 || weekDay < 1) {
            throw new UTL_ResourcingException(String.format('Week day ({0}) out of range: 1-7', new List<String>{String.valueOf(weekDay)}));
        }
        Datetime today = Datetime.now();
        String todayWeekday = today.format('u');
        Integer daysUntilSelectedWeekDay = weekDay - Integer.valueOf(todayWeekday);
        return Date.newInstance(today.year(), today.month(), today.day()).addDays(daysUntilSelectedWeekDay);
    }

    /**
     * Check which users in the given User Ids set have "Resourcing" permission set assigned
     *
     * @param userIds
     *
     * @return Set<Id> - users with permission set assigned
     */
    public static Set<Id> getUsersWithPermissionSetAssigned(Set<Id> userIds){
        Set<Id> assigneeIds = new Set<Id>();
        SEL_PermissionSetAssignments permSetSelector = SEL_PermissionSetAssignments.newInstance();
        List<PermissionSetAssignment> assignments = permSetSelector.selectByPermissionSetNameAndAssigneeIds(RESOURCING_PERMISSION_SET, userIds);
        for (PermissionSetAssignment assignment : assignments) {
            assigneeIds.add(assignment.AssigneeId);
        }

        return assigneeIds;
    }

    public class UTL_ResourcingException extends Exception {}
}