Class dc.multimodel.example.TestDocDB Extends %RegisteredObject
{

Property DBInstance As %DocDB.Database;

Property Items As %DynamicArray;

Method %OnNew() As %Status
{
  Set sc = $$$OK
  Set ..Items = [
    {"item":"journal","qty":25,"size":{"h":14,"w":21,"uom":"cm"},"status":"A"},
    {"item":"notebook","qty":50,"size":{"h":8.5,"w":11,"uom":"in"},"status":"A"},
    {"item":"paper","qty":100,"size":{"h":8.5,"w":11,"uom":"in"},"status":"D"},
    {"item":"planner","qty":75,"size":{"h":22.85,"w":30,"uom":"cm"},"status":"D"},
    {"item":"postcard","qty":45,"size":{"h":10,"w":15.25,"uom":"cm"},"status":"A"}
  ]
  Return sc
}

ClassMethod Execute() As %Status
{
  Set sc = ##class(dc.multumodel.example.TestDocDB).%New().Main()
  Return sc
}

Method Main() As %Status
{
  Set sc = $$$OK
  Try {
    Set ..DBInstance = ..GetDatabase("inventory")
    Do ..DBInstance.%Clear()

    Do ..Log("DocDB test initiated")

    Set ..DBInstance = ..GetDatabase("inventory")

    Do ..Log("Database definition:")
    Write ..DBInstance.%GetDatabaseDefinition().%ToJSON(), !

    Do ..Log("All databases in namespace:")
    Write $SYSTEM.DocDB.GetAllDatabases().%ToJSON(), !

    Do ..Log("Creating a index")
    Do ..CreateSingleIndex("item")
    Do ..CreateSingleIndex("qty")
    Do ..CreateSingleIndex("size")
    Do ..CreateSingleIndex("status")
    Do ..CreateSingleIndex("id")

    Do ..Log("Populating database")
    Set docs = ..SaveMany(..Items)

    Do ..Log("Database size: %1", ..DBInstance.%Size())

    Set lastDoc = ..DBInstance.%GetDocument(..DBInstance.%Size())
    Do ..Log("Last document: %1", lastDoc.%ToJSON())

    Do ..Log("Updating the last document")
    Set lastDoc.id = ..DBInstance.%Size()
    Set lastDoc.item = lastDoc.item_" [edited]"
    Do ..Save(lastDoc)
    Set lastDocEdited = ..DBInstance.%GetDocument(..DBInstance.%Size())
    Do ..Log("Last document: %1", lastDocEdited.%ToJSON())

    zw ..DBInstance.%FindDocuments(["id",5,"<"]).%ToJSON()

    Do ..Log("DocDB test finished")
  } Catch ex {
    Set sc = ex.AsStatus()
  }
  Return sc
}

ClassMethod Log(pMsg As %String, pArgs...) As %Status
{
  Set sc = $$$OK
  Write " - ", $$$FormatText(pMsg, pArgs...), !
  Return sc
}

Method GetDatabase(pDatabaseName As %String) As %DocDB.Database
{
  If $SYSTEM.DocDB.Exists(pDatabaseName) {
    Do ..Log("Database %1 retrieved", pDatabaseName)
    Set db = ##class(%DocDB.Database).%GetDatabase(pDatabaseName)
  } Else {
    Do ..Log("Database %1 created", pDatabaseName)
    Set db = ##class(%DocDB.Database).%CreateDatabase(pDatabaseName)
  }
  Return db
}

Method Save(pDoc As %DynamicObject, pIdKey As %String = "id") As %DynamicObject
{
  Set id = ""
  If (pIdKey '= "") {
    If (pDoc.%IsDefined(pIdKey)) {
      Set id = pDoc.%Get(pIdKey)
    }
  }
  Set doc = ..DBInstance.%SaveDocument(pDoc, id)
  return doc
}

Method SaveMany(pDocs As %DynamicArray, pIdKey As %String = "id") As %DynamicArray
{
  #Dim docs As %DynamicArray = []
  #Dim it As %Iterator.Array = pDocs.%GetIterator()
  While (it.%GetNext(.idx, .item)) {
    Set doc = ..Save(item)
    Do docs.%Push(doc)
  }
  Return docs
}

/// todo: improve...
Method CreateSingleIndex(pFieldName As %String, pUnique As %Boolean = 0) As %Status
{
  Set sc = $$$OK
  Try {
    Do ..DBInstance.%CreateProperty(pFieldName, "%String", "$.firstName", pUnique)
  } Catch ex {
    Set sc = ex.AsStatus()
  }
  Return sc
}

ClassMethod teste() As %Status
{
  set sc = $$$OK
  try {
    SET db = ##class(%DocDB.Database).%DropDatabase("People")
  } Catch (e) {}
  SET db = ##class(%DocDB.Database).%CreateDatabase("People")
  DO db.%CreateProperty("firstName","%String","$.firstName",0)
  DO db.%CreateProperty("lastName","%String","$.lastName",1) 
  DO db.%CreateProperty("birthDate","%String","$.birthInfo.date",0)
  DO db.%CreateProperty("tags","%List","$.tags.all",0)
  SET val = db.%SaveDocument({"firstName":"Serena","lastName":"Williams","birthInfo":{"date":"1976","country":"US"}, "tags": ["blank", "red"]})
  SET val = db.%SaveDocument({"firstName":"Bill","lastName":"Faulkner","birthInfo":{"date":"1976","country":"US"}, "tags": ["blank", "red"]})
  SET val = db.%SaveDocument({"firstName":"Fred","lastName":"Astare","birthInfo":{"date":"1976","country":"US"}, "tags": ["blank", "red"]})
  SET val = db.%SaveDocument({"firstName":"William","lastName":"Smith","birthInfo":{"date":"1976","country":"US"}, "tags": ["blank", "red"]})
  SET rval=db.%ExecuteQuery("SELECT %DocumentId,lastName FROM ISC_DM.People WHERE lastName %STARTSWITH 'F'")
  DO rval.%Display()
  SET rval=db.%ExecuteQuery("SELECT %Doc FROM ISC_DM.People WHERE birthDate = '1976'")
  DO rval.%Display()
  SET rval=db.%ExecuteQuery("SELECT %Doc FROM  ISC_DM.People where tags in ('red')")
  DO rval.%Display()
  return sc
}

}
