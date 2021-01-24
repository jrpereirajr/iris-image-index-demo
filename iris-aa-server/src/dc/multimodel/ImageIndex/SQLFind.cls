/// Defines the interface used by the SQL %FIND and %INSET filter conditions
Class dc.multimodel.ImageIndex.SQLFind Extends %SQL.AbstractFind
{

Property ResultBits [ MultiDimensional ];

Property Indexer As dc.multimodel.ImageIndex.Indexer;

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

ClassMethod teste(pId) As %Integer [ SqlProc ]
{
	return 100 - pId
}

Method PrepareFind(pSearch As %Binary) As %Status
{
	Do ..Log(" ------ PrepareFind ------ ")
	Set sc = $$$OK
	Set search = {}.%FromJSON(pSearch)
	If (search.%IsDefined("color_similarity")) {
		Set config = search.%Get("color_similarity")
		If (config.%IsDefined("first")) {
			Set image = config.%Get("image")
			Set first = ""
			If (config.%IsDefined("first")) {
				Set first = config.%Get("first")
			}
			$$$TOE(sc, ..Indexer.GetDominantColor(image, .s))
			Set idxGbl = ..Indexer.GetIndexLocation()
			Set id = $O(@idxGbl@(""))
			While (id '= "") {
				Set distance = 0
				For idx = 0,1,2 {
					Set distance = distance + $ZABS(s(idx) - @idxGbl@(id, idx))
				}
				Set $LIST(result(distance), * + 1) = id
				Set id = $O(@idxGbl@(id))
			}
			Set c = 0
			Set idxRes = $O(result(""))
			While (idxRes '= "") && ((first = "") || (c < first)) {
				Set idList = result(idxRes)
				For idxId = 1:1:$LISTLENGTH(idList) {
					Set id = $LISTGET(idList, idxId)
					Set tChunk = ..GetChunkFromId(id)
					Set tPos = ..GetBitPosFromId(id)
					Set $BIT(i%ResultBits(tChunk),tPos) = 1
					Set c = c + 1
					Quit:((first '= "") && (c >= first))
				}
				Set idxRes = $O(result(idxRes))
			}
		}
	} Else {
		Set dataGbl = ..Indexer.GetDataLocation()
		Set id = $O(@dataGbl@(""))
		While(id '= "") {
			Set tChunk = ..GetChunkFromId(id)
			Set tPos = ..GetBitPosFromId(id)
			If (..ParseSearch(pSearch, id)) {
				Set $BIT(i%ResultBits(tChunk),tPos) = 1
			}
			Set id = $O(@dataGbl@(id))
		}
	}
	Return sc
}

Method ParseSearch(pSearch As %Binary, pId As %Integer) As %Boolean
{
	Set search = {}.%FromJSON(pSearch)
	If (search.%IsDefined("parity")) {
		Return pId # 2 = $Case(search.parity, "even": 0, :1)
	} ElseIf (search.%IsDefined("color_similarity")) {}
	Return 0
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
	Set tChunk = (pItem\64000)+1, tPos=(pItem#64000)+1
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

}
