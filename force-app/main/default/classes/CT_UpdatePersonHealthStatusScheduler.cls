public with sharing class CT_UpdatePersonHealthStatusScheduler implements Schedulable {
    
    public static final String cronExp = '0 0 2 * * ?';
    public void execute(SchedulableContext SC){
        
        CT_UpdatePersonHealthStatusBatch batchClass = new CT_UpdatePersonHealthStatusBatch();
        String jobId = Database.executeBatch(batchClass, 20);

    }
}