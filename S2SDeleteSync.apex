global class S2SDeleteSync implements Schedulable
{
  global void execute(SchedulableContext SC)
  {
    DeleteRecords();
  }

  public static void DeleteRecords()
  {
    DateTime now = DateTime.now();
    now = now.addHours(-2);
    List<Id> acc = new List<Id>();
    List<Id> con = new List<Id>();
    //001 = Account
    //003 = Contact
    for(PartnerNetworkRecordConnection p : [SELECT Id, LocalRecordId, Status, EndDate 
                                            FROM PartnerNetworkRecordConnection 
                                            WHERE Status='Deleted' AND EndDate>=:now])
    {
      string localId = p.LocalRecordId;
      
      if(localId.startsWith('001')) 
      {
        acc.add(p.LocalRecordId);
      }
      if(localId.startsWith('003'))
      {
        con.add(p.LocalRecordId);
      }
    }
    
    List<Account> accs = [SELECT Id FROM Account WHERE Id in :acc];
    database.delete (accs, false);
    List<Contact> cons = [SELECT Id FROM Contact WHERE Id in :con];
    database.delete (cons, false);
  }
}
