trigger S2SShareContactRecord on Contact (before insert, after insert)
{
  //Get all active Salesforce-to-Salesforce
  //  connections
  List<PartnerNetworkConnection> activeConnections = [SELECT Id FROM PartnerNetworkConnection WHERE connectionStatus = 'Accepted'];

  //Find all Contacts that were inserted locally in this org
  List<Contact> localContacts = new List<Contact>();
  for(Contact newContact: Trigger.New)
  {
    if(newContact.ConnectionReceivedId == null)
    {
      localContacts.add(newContact);
    }
  }
  
  if(Trigger.isAfter)
  {        
    //If there are contacts that are local to this org, share them
    if(localContacts.size() > 0)
    {
      List<PartnerNetworkRecordConnection> contCnxns = new List<PartnerNetworkRecordConnection>();
      
      for(Contact c : localContacts)
      {
        for(PartnerNetworkConnection pnc : activeConnections)
        {
          //for each new contact and network connection,
          //  create a shared connection record
          PartnerNetworkRecordConnection newConnection = new PartnerNetworkRecordConnection(
                    ConnectionId = pnc.Id,
                    LocalRecordId = c.Id,
                    SendClosedTasks = false,
                    SendOpenTasks = false,
                    SendEmails = false,
                    ParentRecordId = c.AccountId);

          contCnxns.add(newConnection);
        }
      }

      if(contCnxns.size() > 0)
      {
        //Share the records
        insert contCnxns;
      }
    }
  }
  else if(Trigger.isBefore)
  {
    for(Contact c : localContacts)
    {
      c.LookupRelink__c = c.Lookup__c;
      c.RecordTypeName__c = c.RecordType.Name;
    }
  }
}

  
