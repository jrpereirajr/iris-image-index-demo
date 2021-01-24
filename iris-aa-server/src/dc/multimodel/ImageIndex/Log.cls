Class dc.multimodel.ImageIndex.Log Extends %RegisteredObject
{

Parameter LogEnableFlag = "^ImageIndexLog(""Enable"")";

Parameter LogBuffer = "^ImageIndexLog(""Log"")";

Parameter LogBufferInc = "^ImageIndexLog(""Log"", $INCREMENT(^ImageIndexLog(""Log"")))";

ClassMethod SetLog(pValue As %Boolean, pListAllowedMethods As %List = "")
{
	Set @..#LogEnableFlag = pValue
	Set @..#LogEnableFlag@("methods") = pListAllowedMethods
}

ClassMethod KillLog() As %Status
{
	Set sc = $$$OK
	Set buffer = ..#LogBuffer
	Try {
		Kill @buffer
	} Catch(e) {
		Set sc = e.AsStatus()
	}
	Return sc
}

ClassMethod Log(pMsg, pKey As %String = "") As %Status
{
	Set sc = $$$OK
	Set buffer = ..#LogBufferInc
	Return:('$GET(^ImageIndexLog("Enable"), 0)) sc
	Return:('..IsAllowed())
	Try {
		Set @buffer@("msg") = pMsg
		Set @buffer@("key") = $CASE(pKey, "":"", :pKey_": ")
		Set @buffer@("caller") = ..GetCaller()
		Set @buffer@("ts") = $ZDATETIME($HOROLOG, 3)
		If ($DATA(pMsg) > 1) {
			Merge @buffer = pMsg
		}
	} Catch(e) {
		Set sc = e.AsStatus()
	}
	Return sc
}

ClassMethod IsAllowed() As %Boolean
{
	Set allowed = @..#LogEnableFlag@("methods")
	Set lenAllowed = $LISTLENGTH(allowed)

	Return:(lenAllowed = 0) 1

	Set caller = ..GetCaller(4)
	Set tokens = $LISTFROMSTRING(caller, "^")
	For i = 1:1:lenAllowed {
		Set item = $LISTGET(allowed, i)
		Set class = $PIECE(item, ":", 1)
		Set method = $PIECE(item, ":", 2)
		Set isAllowed = $FIND($LISTGET(tokens, 3), class) > 0
		If ((isAllowed) && (method '= "") && (method '= "*")) {
			Set isAllowed = $FIND($LISTGET(tokens, 2), method) > 0
		}
	}
	Return isAllowed
}

ClassMethod GetCaller(pCallerIndex As %Integer = 3) As %String
{
	Return $LISTGET(##class(%Exception.StatusException).%New().iStack, pCallerIndex)
}

ClassMethod ShowLog() As %Status
{
	Set sc = $$$OK
	Set buffer = ..#LogBuffer
	Try {
		ZWrite @buffer
	} Catch(e) {
		Set sc = e.AsStatus()
	}
	Return sc
}

}
