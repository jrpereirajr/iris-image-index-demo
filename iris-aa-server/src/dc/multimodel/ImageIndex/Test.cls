Include %occErrors

Class dc.multimodel.ImageIndex.Test Extends %Persistent
{

Property Name As %String;

Property ImageFile As %String(MAXLEN = 1024);

Index idxName On Name [ Type = bitmap ];

Index idxImageFile On (ImageFile) As dc.multimodel.ImageIndex.Index;

ClassMethod ExecuteCRUD() As %Status
{
	Set sc = $$$OK
	Try {
		$$$ThrowOnError(..Truncate())
		$$$ThrowOnError(..Create())
		$$$ThrowOnError(..Retrieve())
		$$$ThrowOnError(..Update())
		$$$ThrowOnError(..Delete())
	}
	Catch ex {
		Set sc = ex.AsStatus()
	}
	Return sc
}

ClassMethod Create(pDir = "/data/img", pRecursive As %Boolean = 1, pIgnoreList As %List = {$LB("/data/img/test")}) As %Status
{
	Set %c = 0
	Set %max = ""
	&SQL(TRUNCATE TABLE dc_multimodel_ImageIndex.Test)
	Return ..CreateRecursive(pDir, pRecursive, pIgnoreList)
}

ClassMethod CreateRecursive(pDir = "/data/img", pRecursive As %Boolean = 1, pIgnoreList As %List = "") As %Status
{
	Quit:((%max '= "") && (%c >= %max))
	Set st = $$$OK
	
	Try {
		Set dir = ##class(%File).NormalizeDirectory(pDir)
		If ##class(%File).DirectoryExists(dir) {
			Set rs = ##Class(%ResultSet).%New("%File.FileSet")
 			Do rs.Execute(dir, "*", , 1)
 			While rs.Next() {
				Quit:((%max '= "") && (%c >= %max))
				If (rs.Get("Type") '= "D") {
					Set name = rs.Get("ItemName")
					Set imageFile = pDir_"/"_name
					&SQL(
						INSERT INTO dc_multimodel_ImageIndex.Test (Name, ImageFile) 
						VALUES (:name, :imageFile)
					)
					If (SQLCODE '= 0) && (SQLCODE '= 100) {
						Throw ##class(%Exception.SQL).CreateFromSQLCODE(SQLCODE)
					}
					Set %c = %c + 1
				} Else {
					Set subdir = rs.Get("Name")
					If ((pRecursive) && ($LISTFIND(pIgnoreList, subdir) = 0)) {
						$$$ThrowOnError(..CreateRecursive(subdir, pRecursive, pIgnoreList))
					}
				}
			}
		} Else {
			Throw ##class(%Exception.General).%New("Directory not found: "_dir)
		} 
	} Catch(ex) {
		Set st = ex.AsStatus()
	}

	Return st
}

ClassMethod Retrieve() As %Status
{
	Do ..Log(" ------- Retrieve -------- ")
	Set sc = $$$OK
	Set sql = 
	"SELECT * "_
	"FROM dc_multimodel_ImageIndex.Test "_
	"WHERE "_
		"ID %FIND search_index(idxImageFile,'{""color_similarity"": {""image"": ""/data/img/short-sleeve-top/green/16107484909318.jpg"", ""first"": 10}}')"
	Set tStatement = ##class(%SQL.Statement).%New()
	Set sc = tStatement.%Prepare(sql)
	If (sc '= 1) {
		Write "%Prepare failed:" Do $SYSTEM.Status.DisplayError(sc)
		Return sc
	}
	Set rset = tStatement.%Execute()
	Do rset.%Display()
	Return sc
}

ClassMethod Update() As %Status
{
	Set sc = $$$OK
	&SQL(
		UPDATE dc_multimodel_ImageIndex.Test 
		SET ImageFile = '/data/img/short-sleeve-top/white/16107486208714.jpg'
		WHERE Id = 1
	)
	&SQL(
		UPDATE dc_multimodel_ImageIndex.Test 
		SET ImageFile = '/data/img/short-sleeve-top/white/16107486208611.jpg'
		WHERE Id = 1
	)
	Return sc
}

ClassMethod Delete() As %Status
{
	Set sc = $$$OK
	&SQL(
		DELETE FROM dc_multimodel_ImageIndex.Test WHERE Id = 1
	)
	Return sc
}

ClassMethod Truncate() As %Status
{
	Set sc = $$$OK
	&SQL(
		TRUNCATE TABLE dc_multimodel_ImageIndex.Test
	)
	Return sc
}

ClassMethod Log(pMsg As %String, pKey As %String = "") As %Status
{
	Set sc = $$$OK
	Do ##class(dc.multimodel.ImageIndex.Log).Log(pMsg, pKey)
	Return sc
}

Storage Default
{
<Data name="TestDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
<Value name="2">
<Value>Name</Value>
</Value>
<Value name="3">
<Value>ImageFile</Value>
</Value>
</Data>
<DataLocation>^dc.multimodel.ImageIndex.TestD</DataLocation>
<DefaultData>TestDefaultData</DefaultData>
<IdLocation>^dc.multimodel.ImageIndex.TestD</IdLocation>
<IndexLocation>^dc.multimodel.ImageIndex.TestI</IndexLocation>
<StreamLocation>^dc.multimodel.ImageIndex.TestS</StreamLocation>
<Type>%Storage.Persistent</Type>
}

}
