trigger S2SAcceptContactRecord on Contact (before insert, before update)
{

  //Find all Contacts that were inserted locally in this org
  List<Contact> remoteContacts = new List<Contact>();
  Map<Id, Id> contactIds = new Map<Id, Id>();
  for(Contact newContact: Trigger.New)
  {
    if(newContact.ConnectionReceivedId != null)
    {
    remoteContacts.add(newContact);
    contactIds.put(newContact.Id, newContact.LookupRelink__c);
    }
  }
  
  if(Trigger.isBefore)
  {
    //update the record types
    for(Contact c : remoteContacts)
    {
    c.RecordTypeId =  Schema.SObjectType.Contact.getRecordTypeInfosByName().get(c.RecordTypeName__c).getRecordTypeId();
    }
    
    //update lookup relationships
    
    if(!contactIds.isEmpty())
    {
      ExternalSharingHelper.relinkLookups(contactIds);
    }   
  }
}  
