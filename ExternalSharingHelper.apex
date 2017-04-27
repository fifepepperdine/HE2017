class ExternalSharingHelper
{
  @future 
  public static void relinkLookups(Map<Id,Id> idMap)
  {
    Map<Id,Id> objectMap = new Map<Id,Id>();
    
    //Get a map of the org linking record ids
    
    for (PartnerNetworkRecordConnection objectConnection : [SELECT Id, Status, PartnerRecordId, LocalRecordId 
                                                            FROM PartnerNetworkRecordConnection
                                                            WHERE LocalRecordId in :idMap.keySet()])
    {
      if (   objectConnection.Status == 'Sent' || objectConnection.Status == 'Received')
      {
        objectMap.put(objectConnection.PartnerRecordId, objectConnection.LocalRecordId);
      }
    }
    
    List<SObject> localSObjectList = new List<SObject>();
    
    //Update the local id field with the correctly mapped id
    
    for (Id localId : idMap.keySet())
    {
      SObject objectForUpdate = new SObject(Id=localId);
      objectForUpdate.LookupField__c = objectMap.get(idMap.get(localId));
      
      localSObjectList.add(objectForUpdate);
    }
    
    database.update(localSObjectList);
  } 



}
