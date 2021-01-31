Class dc.multimodel.ImageIndex.Indexer Extends %RegisteredObject
{

Property ClassName As %String;

Property IndexName As %String;

Property DataGlobal As %String [ Private ];

Property IndexGlobal As %String [ Private ];

Property RankGlobal As %String [ Private ];

Property Cardinality As %Integer;

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
  Set ..RankGlobal = ..GetRankLocation()
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

Method GetRankLocation() As %String
{
  // Note: consider use a non journalized global for better performance
  Set storage = "^IRIS.Temp(""image-index-rank"","""_..ClassName_""")"
	Return storage
}

ClassMethod GetInstance(pClassName As %String, pIndexName As %String) As dc.multimodel.ImageIndex.Indexer
{
  // Singleton strategy paused...
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

Method GetDominantColor(pFile As %String, ByRef pVector) As %Status
{
  Set sc = $$$OK
  Try {
    // RGB
    $$$ThrowOnError(..GetDominantColorRGB(pFile, .pVector))

    // HSV
    #; $$$ThrowOnError(..GetDominantColorHSV(pFile, .pVector))

    // RGB + HSV
    #; $$$ThrowOnError(..GetDominantColorRGB(pFile, .rgb))
    #; $$$ThrowOnError(..GetDominantColorHSV(pFile, .hsv))
    #; Set pVector(0) = rgb(0)
    #; Set pVector(1) = rgb(1)
    #; Set pVector(2) = rgb(2)
    #; Set pVector(3) = hsv(0)
    #; Set pVector(4) = hsv(1)
    #; Set pVector(5) = hsv(2)
  } Catch(e) {
    Set sc = e.AsStatus()
  }
  Return sc
}

Method GetDominantColorRGB(pFile As %String, ByRef pVector) As %Status
{
  // http://jsonpickle.github.io/
  // https://github.com/fengsp/color-thief-py
  Set sc = $$$OK
  Try {
    Set json = ##class(%SYS.Python).Import("json")
    Set fastcolorthief = ##class(%SYS.Python).Import("fast_colorthief")
    Set imagepath = pFile
    Set dominantcolor = fastcolorthief."get_dominant_color"(imagepath, 1)
    // Set colorpalette = fastcolorthief."get_palette"(imagepath)
    Set vector = {}.%FromJSON(json.dumps(dominantcolor))
    Set n = ..Cardinality - 1
    For i = 0:1:n {
      Set pVector(i) = vector.%Get(i)
    }
  } Catch(e) {
    Set sc = e.AsStatus()
  }
  Return sc
}

Method GetDominantColorHSV(pFile As %String, ByRef pVector) As %Status
{
  // http://jsonpickle.github.io/
  // https://github.com/fengsp/color-thief-py
  Set sc = $$$OK
  Try {
    Set json = ##class(%SYS.Python).Import("json")
    Set fastcolorthief = ##class(%SYS.Python).Import("fast_colorthief")
    Set colorsys = ##class(%SYS.Python).Import("colorsys")
    Set imagepath = pFile
    Set dominantcolor = fastcolorthief."get_dominant_color"(imagepath, 1)
    // Set colorpalette = fastcolorthief."get_palette"(imagepath)
    Set vector = {}.%FromJSON(json.dumps(dominantcolor))
    Set hsv = colorsys."rgb_to_hsv"(
      vector.%Get(0) / 255, vector.%Get(1) / 255, vector.%Get(2) / 255
    )
    Set hsv = {}.%FromJSON(json.dumps(hsv))
    Set n = ..Cardinality - 1
    For i = 0:1:n {
      Set pVector(i) = $NUMBER(hsv.%Get(i) * 255, 0)
      If pVector(i) > 255 {
        Set pVector(i) = 255
      }
    }
  } Catch(e) {
    Set sc = e.AsStatus()
  }
  Return sc
}

/// Calculate the L1 distance, aka city block, taxcab or Manhattan distance
/// @see https://en.wikipedia.org/wiki/Taxicab_geometry
Method GetL1Distance(ByRef pVector1, ByRef pVector2) As %Float
{
  Set distance = 0
  Set n = ..Cardinality - 1
  For idx = 0:1:n {
    Set distance = distance + $ZABS(pVector2(idx) - pVector1(idx))
  }
  Return distance
}

Method Insert(pID As %CacheString, pArgs... As %Binary)
{
  $$$ThrowOnError(..GetDominantColor(pArgs(1), .rgb))
	Set idxGbl = ..GetIndexLocation()
	Set @idxGbl@("model", pID) = ""
  Merge @idxGbl@("model", pID, "rgb") = rgb
  Set @idxGbl@("last-modification") = $ZTIMESTAMP
}

Method Delete(pID As %CacheString, pArg... As %Binary)
{
  Set idxGbl = ..GetIndexLocation()
  Kill @idxGbl@("model", pID)
  Set @idxGbl@("last-modification") = $ZTIMESTAMP
}

Method Purge(pID As %CacheString, pArg... As %Binary)
{
  Set idxGbl = ..GetIndexLocation()
  Kill @idxGbl
  Set @idxGbl@("last-modification") = $ZTIMESTAMP
}

Method Update(pID As %CacheString, pArg... As %Binary)
{
  Set idxGbl = ..GetIndexLocation()
  Do ..GetDominantColor(pArg(1), .rgb)
  Kill @idxGbl@("model", pID)
  Set @idxGbl@("model", pID) = ""
  Merge @idxGbl@("model", pID, "rgb") = rgb
  Set @idxGbl@("last-modification") = $ZTIMESTAMP
}

}
