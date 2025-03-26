public with sharing class CT_UpdateLocationStatusScheduler implements Schedulable {
    
    public static final String cronExp = '0 0 2 * * ?';
    public void execute(SchedulableContext SC){
        
        CT_UpdateLocationStatusBatch batchClass = new CT_UpdateLocationStatusBatch();
        String jobId = Database.executeBatch(batchClass, 20);

    }
}