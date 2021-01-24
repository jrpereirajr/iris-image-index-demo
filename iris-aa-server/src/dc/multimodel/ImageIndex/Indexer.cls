Class dc.multimodel.ImageIndex.Indexer Extends %RegisteredObject
{

Property ClassName As %String;

Property IndexName As %String;

Property DataGlobal As %String [ Private ];

Property IndexGlobal As %String [ Private ];

ClassMethod Log(pMsg As %String, pKey As %String = "")
{
	Do ##class(dc.multimodel.ImageIndex.Log).Log(pMsg, pKey)
}

Method %OnNew(pClassName As %String, pIndexName As %String) As %Status [ Private, ServerOnly = 1 ]
{
  Set ..ClassName = pClassName
  Set ..IndexName = pIndexName
  Set ..DataGlobal = ..GetDataLocation()
  Set ..IndexGlobal = ..GetIndexLocation()
  Do ..Log(..DataGlobal, "DataGlobal")
  Do ..Log(..IndexGlobal, "IndexGlobal")
	Quit $$$OK
}

Method GetDataLocation() As %String
{
  // Note: expected just one storage; fail for multiples storages
	Set storage = ##class(%Dictionary.ClassDefinition).%OpenId(..ClassName).Storages.GetAt(1).DataLocation
	Return storage
}

Method GetIndexLocation() As %String
{
  // Note: expected just one storage; fail for multiples storages
	Set storage = ##class(%Dictionary.ClassDefinition).%OpenId(..ClassName).Storages.GetAt(1).IndexLocation
	Return $NAME(@storage@(..IndexName))
}

ClassMethod GetInstance(pClassName As %String, pIndexName As %String) As dc.multimodel.ImageIndex.Indexer
{
  //If '$DATA(%ImageIndexerCache(pClassName, pIndexName)) || '$ISOBJECT(%ImageIndexerCache(pClassName, pIndexName)) {
    Set Obj = ..%New(pClassName, pIndexName)
    Set %ImageIndexerCache(pClassName, pIndexName) = Obj
    Do ..Log($$$FormatText("Created new instance for the Indexer(%1, %2)", pClassName, pIndexName))
  /*} Else {
    Set Obj = %ImageIndexerCache(pClassName, pIndexName)
    Do ..Log($$$FormatText("Previous instance for the Indexer(%1, %2) reused", pClassName, pIndexName))
  }*/
  Return Obj
}

ClassMethod PythonImport(pLibName As %String) As %SYS.Python
{
  Try {
    Set lib = ##class(%SYS.Python).Import(pLibName)
  } Catch(e) {
    Write $$$FormatText("Installing %1...", pLibName), !
    $$$TOE(sc, ##class(%SYS.Python).Install(pLibName))
    Set lib = ##class(%SYS.Python).Import(pLibName)
  }
  Return lib
}

ClassMethod GetDominantColor(pFile As %String, ByRef pVector) As %Status
{
  // http://jsonpickle.github.io/
  // https://github.com/fengsp/color-thief-py
  Set sc = $$$OK
  Try {
    Set json = ..PythonImport("json")
    Set fastcolorthief = ..PythonImport("fast_colorthief")
    Set imagepath = pFile
    Set dominantcolor = fastcolorthief."get_dominant_color"(imagepath, 1)
    Set colorpalette = fastcolorthief."get_palette"(imagepath)
    Set vector = {}.%FromJSON(json.dumps(dominantcolor))
    For i = 0,1,2 {
      Set pVector(i) = vector.%Get(i)
    }
  } Catch(e) {
    Set sc = e.AsStatus()
  }
  Return sc
}

}
