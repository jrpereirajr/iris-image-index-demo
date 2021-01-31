/// Defines the interface used by the SQL %FIND and %INSET filter conditions
Class dc.multimodel.ImageIndex.SQLFind Extends %SQL.AbstractFind
{

Property ResultBits [ MultiDimensional ];

Property Indexer As dc.multimodel.ImageIndex.Indexer;

Property FindStrategy As %String [ InitialExpression = "knn" ];

Property ImagePath As %String;

Property First As %Integer;

ClassMethod Log(pMsg As %String, pKey As %String = "")
{
	Do ##class(dc.multimodel.ImageIndex.Log).Log(pMsg, pKey)
}

Method %OnNew() As %Status [ Private, ServerOnly = 1 ]
{
	Do ..Log(" ------ %New() ------ ")
	Kill i%ResultBits
	Return $$$OK
}

Method PrepareFind(pSearch As %Binary) As %Status
{
	Do ..Log(" ------ PrepareFind ------ ")
	Set sc = $$$OK
	Set search = {}.%FromJSON(pSearch)
	If (search.%IsDefined("color_similarity")) {
		Set config = search.%Get("color_similarity")
		If (config.%IsDefined("image")) {
			$$$ThrowOnError(..FindResults(config, .result))
			Set idxRes = $ORDER(result(""))
			While (idxRes '= "") {
				Set id = $ORDER(result(idxRes, ""))
				While(id '= "") {
					Set tChunk = ..GetChunkFromId(id)
					Set tPos = ..GetBitPosFromId(id)
					Set $BIT(i%ResultBits(tChunk),tPos) = 1
					Set id = $ORDER(result(idxRes, id))
				}
				Set idxRes = $ORDER(result(idxRes))
			}
		}
	}
	Return sc
}

Method FindResults(pConfig As %DynamicObject, ByRef pResult) As %Status
{
	Do ..Log(" ------ FindResults ------ ")
	Set sc = $$$OK
	Try {
		Set config = pConfig
		Set ..ImagePath = config.%Get("image")
		If (config.%IsDefined("first")) {
			Set ..First = config.%Get("first")
		}
		If (config.%IsDefined("strategy")) {
			Set ..FindStrategy = config.%Get("strategy")
		}

		$$$ThrowOnError(..Indexer.GetDominantColor(..ImagePath, .search))
		If (..FindStrategy = "fullscan") {
			$$$ThrowOnError(..FullScanFindStrategy(.search, .pResult))
		} ElseIf (..FindStrategy = "knn") {
			$$$ThrowOnError(..KNNFindStrategy(.search, .pResult))
		}
	}
	Catch ex {
		Set sc = ex.AsStatus()
		Set ^j("error") = ex.DisplayString()
	}
	Return sc
}

Method FullScanFindStrategy(ByRef pSearchVector, ByRef pResult) As %Status
{
	Do ..Log(" ------ FullScanFindStrategy ------ ")
	Set sc = $$$OK
	Try {
		Set idxGbl = ..Indexer.GetIndexLocation()
		Set rankGbl = ..Indexer.GetRankLocation()

		Set id = $ORDER(@idxGbl@("model", ""))
		While (id '= "") {
			If ($ISVALIDNUM(id)) {
				Merge vector = @idxGbl@("model", id, "rgb")
				Set distance = ..Indexer.GetL1Distance(.pSearchVector, .vector)
				Set result(distance, id) = ""
			}
			Set id = $ORDER(@idxGbl@("model", id))
		}

		Kill @rankGbl@(..ImagePath, ..FindStrategy)
		If (..First '= "") {
			Set c = 0
			Set distance = $ORDER(result(""))
			While (distance '= "") && (c < ..First) {
				Merge resultTmp(distance) = result(distance)

				Set id = $ORDER(result(distance, ""))
				While (id '= "") {
					Set @rankGbl@(..ImagePath, ..FindStrategy, id) = distance
					Set id = $ORDER(result(distance, id))
				}

				Set c = c + 1
				Set distance = $ORDER(result(distance))
			}
			Kill result
			Merge result = resultTmp
		}

		Merge pResult = result
	}
	Catch ex {
		Set sc = ex.AsStatus()
	}
	Return sc
}

Method KNNFindStrategy(ByRef pSearchVector, ByRef pResult) As %Status
{
	Do ..Log(" ------ KNNFindStrategy ------ ")
	Set sc = $$$OK
	Try {
		Set idxGbl = ..Indexer.GetIndexLocation()
		Set rankGbl = ..Indexer.GetRankLocation()

		Set json = ##class(%SYS.Python).Import("json")
		Set knn = ..GetKNN() //##class(%SYS.Python).Import("knn")

		Set first = ..First
		Set k = $GET(first, 5)

		Set n = ..Indexer.Cardinality - 1
		Set x = ""
		For i = 0:1:n {
			Set $LIST(x, * + 1) = pSearchVector(i)
		}
		Set x = "[["_$LISTTOSTRING(x, ",")_"]]"

		$$$ThrowOnError(..CreateOrUpdateKNNIndex())
		Set ind = knn.query(x, k, idxGbl)
		Set ind = {}.%FromJSON(json.dumps(ind.tolist()))
		Set ind = ind.%Get(0)

		Kill result
		Kill @rankGbl@(..ImagePath, ..FindStrategy)
		Set n = k - 1
		For i=0:1:n {
			Set id = ind.%Get(i)
			Set result(i, id) = ""
			Set @rankGbl@(..ImagePath, ..FindStrategy, id) = i
		}
		Merge pResult = result
	}
	Catch ex {
		Set sc = ex.AsStatus()
	}
	Return sc
}

Method CreateOrUpdateKNNIndex() As %Status
{
	Do ..Log(" ------ CreateOrUpdateKNNIndex ------ ")
	Set sc = $$$OK
	Try {
		Set idxGbl = ..Indexer.GetIndexLocation()
		Set lastIndexBuild = $GET(@idxGbl@("last-index-build"), "0,0")
		Set indexBuildDate = $PIECE(lastIndexBuild, ",", 1)
		Set indexBuildTime = $PIECE(lastIndexBuild, ",", 2)
		Set lastUpdateDate = $PIECE(@idxGbl@("last-modification"), ",", 1)
		Set lastUpdateTime = $PIECE(@idxGbl@("last-modification"), ",", 2)
		If ((indexBuildDate < lastUpdateDate) || ((indexBuildDate = lastUpdateDate) && (indexBuildTime < lastUpdateTime))) {
			Do ..Log("creating index...")
			Set knn = ..GetKNN() //##class(%SYS.Python).Import("knn")
			Do knn."create_index"(idxGbl, ..Indexer.Cardinality)
			Set @idxGbl@("last-index-build") = $ZTIMESTAMP
			Do ..Log("index created")
		}
	}
	Catch ex {
		Set sc = ex.AsStatus()
	}
	Return sc
}

Method DiffRank(pSearch As %Binary, pId As %String) As %Float
{
	Set search = {}.%FromJSON(pSearch)
	If (search.%IsDefined("color_similarity")) {
		Set config = search.%Get("color_similarity")
		Set imagePath = config.%Get("image")
		If (config.%IsDefined("strategy")) {
			Set findStrategy = config.%Get("strategy")
		}
		Set rankGbl = ..Indexer.GetRankLocation()
		Set rank = $GET(@rankGbl@(imagePath, findStrategy, pId))
		Return rank
	}
	Return ""
}

Method GetChunkFromId(pId As %Integer) As %Integer
{
	Return (pId \ 64000) + 1
}

Method GetBitPosFromId(pId As %Integer) As %Integer
{
	Return (pId # 64000) + 1
}

/// 	At minimum, <METHOD>ContainsItem()</METHOD> must always be supported.
/// 	It returns 1 iff the given pItem is in the set S.
Method ContainsItem(pItem As %String) As %Boolean
{
	Do ..Log(" ------ ContainsItem ------ ")
	Set tChunk = (pItem \ 64000) + 1
	Set tPos = (pItem # 64000) + 1
	Quit $BIT($GET(i%ResultBits(tChunk)),tPos)
}

/// <p>
/// For a given chunk number pChunk, return the corresponding actual bitmap string. 
/// </p>
/// <p>
/// This method must be implemented when %FIND is used. 
/// </p>
Method GetChunk(pChunk As %Integer) As %Binary
{
	Do ..Log(" ------ GetChunk ------ ")
	Quit $GET(i%ResultBits(pChunk))
}

/// <p>
/// This method simulates the usage of <function>$ORDER()</function> to 
/// traverse through the chunks of a bitmap index or a bitmap temp-file that 
/// would represent the set S. 
/// </p>
/// <p>
/// For a given chunk number pChunk, find the first chunk 
/// number &gt; pChunk and return it in .pChunk, with the method return value being the corresponding actual bitmap string. 
/// Return .pChunk="" if none found.
/// </p>
/// <p>
/// Note that when returning a positive .pChunk, it's OK for the returned bitmap b 
/// to have no bits set to 1, including b="" .  On the other hand, it's also OK 
/// for the method implementation to skip such a chunk and proceed to the next pChunk. 
/// </p>
/// <p>
/// This method must be implemented when %FIND is used. 
/// </p>
Method NextChunk(ByRef pChunk As %Integer = "") As %Binary
{
	Do ..Log(" ------ NextChunk ------ ")
	Set pChunk = $ORDER(i%ResultBits(pChunk),1,tBits)
	Quit:pChunk="" ""
	Quit tBits
}

/// <p>
/// This method simulates the usage of <function>$ORDER()</function> to 
/// traverse backwards through the chunks of a bitmap index or a bitmap temp-file 
/// that would represent the set S. 
/// </p>
/// <p>
/// For a given chunk number pChunk, find the first chunk 
/// number &lt; pChunk and return it in .pChunk, with the method return value being the corresponding actual bitmap string. 
/// Return .pChunk="" if none found.
/// </p>
/// <p>
/// Note that when returning a positive .pChunk, it's OK for the returned bitmap b 
/// to have no bits set to 1, including b="" .  On the other hand, it's also OK 
/// for the method implementation to skip such a chunk and proceed to the next pChunk. 
/// </p>
/// <p>
/// This method must be implemented when %FIND is used. 
/// </p>
Method PreviousChunk(ByRef pChunk As %Integer = "") As %Binary
{
	Do ..Log(" ------ PreviousChunk ------ ")
	Set pChunk = $ORDER(i%ResultBits(pChunk),-1,tBits)
	Quit:pChunk="" ""
	Quit tBits
}

/// Ugly hack for IRIS Native API installation...
/// This was necessary once installation with other libraries does not worked here in Dockerfile build...
ClassMethod GetKNN() As %Status
{
	Try {
		Set knn = ##class(%SYS.Python).Import("knn")
	}
	Catch ex {
		#; Do ##class(%SYS.Python).Install("/shared/python-lib/irisnative-1.0.0-cp34-abi3-linux_x86_64.whl")
		#; Set knn = ##class(%SYS.Python).Import("knn")

		Job ##class(%SYS.Python).Install("/shared/python-lib/irisnative-1.0.0-cp34-abi3-linux_x86_64.whl")
		Set ok = 0
		Do {
			Hang .5
			Try {
				Set knn = ##class(%SYS.Python).Import("knn")
				Set ok = 1
			} Catch(e) {}
		} While ('ok)
	}
	Return knn
}

}
