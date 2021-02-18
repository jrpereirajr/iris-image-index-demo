/// Functional Indexing to be used to optimize queries on image data
Class dc.multimodel.ImageIndex.Index Extends %Library.FunctionalIndex [ System = 3 ]
{

/// Feature space cardinality
/// As this class is intended to index image in RGB space, its cardinality is 3
Parameter Cardinality = 3;

/// This method is invoked when an existing instance of a class is deleted.
ClassMethod DeleteIndex(pID As %CacheString, pArg... As %Binary) [ CodeMode = generator, ServerOnly = 1 ]
{
	If (%mode '= "method") {
		$$$GENERATE("	Try {")
		$$$GENERATE("		Do ##class(dc.multimodel.ImageIndex.Log).Log("" -------- DeleteIndex -------- "")")
		$$$GENERATE("		Do ##class(dc.multimodel.ImageIndex.Log).Log(pID, ""pID"")")
		$$$GENERATE("		Do ##class(dc.multimodel.ImageIndex.Log).Log("".pArg"", ""pArg"")")
		$$$GENERATE("		Set indexer = ##class(dc.multimodel.ImageIndex.Indexer).GetInstance("""_%class_""", """_%property_""")")
		$$$GENERATE("		Set indexer.Cardinality = "_..#Cardinality)
		$$$GENERATE("		Do indexer.Delete(pID, pArg...)")
		$$$GENERATE("	} Catch(e) {")
		$$$GENERATE("		Do ##class(dc.multimodel.ImageIndex.Log).Log(e.AsStatus(), ""error"")")
		$$$GENERATE("		Throw e")
		$$$GENERATE("	}")
	}
	Return $$$OK
}

ClassMethod Find(pSearch As %Binary) As %Library.Binary [ CodeMode = generator, ServerOnly = 1, SqlProc ]
{
	If (%mode '= "method") {
		$$$GENERATE("	Set result = """"")
		$$$GENERATE("	Try {")
		$$$GENERATE("		Do ##class(dc.multimodel.ImageIndex.Log).Log("" -------- Find -------- "")")
		$$$GENERATE("		Do ##class(dc.multimodel.ImageIndex.Log).Log(pSearch, ""pSearch"")")
		$$$GENERATE("		Set result = ##class(dc.multimodel.ImageIndex.SQLFind).%New()")
		$$$GENERATE("		Set indexer = ##class(dc.multimodel.ImageIndex.Indexer).GetInstance("""_%class_""", """_%property_""")")
		$$$GENERATE("		Set indexer.Cardinality = "_..#Cardinality)
		$$$GENERATE("		Set result.Indexer = indexer")
		$$$GENERATE("		Do result.PrepareFind(pSearch)")
		$$$GENERATE("	} Catch(e) {")
		$$$GENERATE("		Do ##class(dc.multimodel.ImageIndex.Log).Log(e.AsStatus(), ""error"")")
		$$$GENERATE("		Throw e")
		$$$GENERATE("	}")
		$$$GENERATE("	Return result")
	}
	Return $$$OK
}

/// This method is invoked when a new instance of a class is inserted into the database.
ClassMethod InsertIndex(pID As %CacheString, pArg... As %Binary) [ CodeMode = generator, ServerOnly = 1 ]
{
	If (%mode '= "method") {
		$$$GENERATE("	Try {")
		$$$GENERATE("		Do ##class(dc.multimodel.ImageIndex.Log).Log("" -------- InsertIndex -------- "")")
		$$$GENERATE("		Do ##class(dc.multimodel.ImageIndex.Log).Log("""_%class_""", ""%class"")")
		$$$GENERATE("		Do ##class(dc.multimodel.ImageIndex.Log).Log("""_%property_""", ""%property"")")
		$$$GENERATE("		Do ##class(dc.multimodel.ImageIndex.Log).Log(pID, ""pID"")")
		$$$GENERATE("		Do ##class(dc.multimodel.ImageIndex.Log).Log(.pArg, ""pArg"")")
		$$$GENERATE("		Set indexer = ##class(dc.multimodel.ImageIndex.Indexer).GetInstance("""_%class_""", """_%property_""")")
		$$$GENERATE("		Set indexer.Cardinality = "_..#Cardinality)
		$$$GENERATE("		Do indexer.Insert(pID, pArg...)")
		$$$GENERATE("	} Catch(e) {")
		$$$GENERATE("		Do ##class(dc.multimodel.ImageIndex.Log).Log(e.AsStatus(), ""error"")")
		$$$GENERATE("		Throw e")
		$$$GENERATE("	}")
	}
	Return $$$OK
}

ClassMethod PurgeIndex() [ CodeMode = generator, ServerOnly = 1 ]
{
	If (%mode '= "method") {
		$$$GENERATE("	Try {")
		$$$GENERATE("		Do ##class(dc.multimodel.ImageIndex.Log).Log("" -------- PurgeIndex -------- "")")
		$$$GENERATE("		Set indexer = ##class(dc.multimodel.ImageIndex.Indexer).GetInstance("""_%class_""", """_%property_""")")
		$$$GENERATE("		Set indexer.Cardinality = "_..#Cardinality)
		$$$GENERATE("		Set indexGbl = indexer.GetIndexLocation()")
		$$$GENERATE("		Do indexer.Purge()")
		$$$GENERATE("	} Catch(e) {")
		$$$GENERATE("		Do ##class(dc.multimodel.ImageIndex.Log).Log(e.AsStatus(), ""error"")")
		$$$GENERATE("		Throw e")
		$$$GENERATE("	}")
	}
	Return $$$OK
}

ClassMethod SortBeginIndex() [ CodeMode = generator, ServerOnly = 1 ]
{
	If (%mode '= "method") {
		$$$GENERATE("	Try {")
		$$$GENERATE("		Do ##class(dc.multimodel.ImageIndex.Log).Log("" -------- SortBeginIndex -------- "")")
		$$$GENERATE("	} Catch(e) {")
		$$$GENERATE("		Do ##class(dc.multimodel.ImageIndex.Log).Log(e.AsStatus(), ""error"")")
		$$$GENERATE("		Throw e")
		$$$GENERATE("	}")
	}
	Return $$$OK
}

ClassMethod SortEndIndex(pCommit As %Integer = 1) [ CodeMode = generator, ServerOnly = 1 ]
{
	If (%mode '= "method") {
		$$$GENERATE("	Try {")
		$$$GENERATE("		Do ##class(dc.multimodel.ImageIndex.Log).Log("" -------- SortEndIndex -------- "")")
		$$$GENERATE("		Do ##class(dc.multimodel.ImageIndex.Log).Log(pCommit, ""pCommit"")")
		$$$GENERATE("	} Catch(e) {")
		$$$GENERATE("		Do ##class(dc.multimodel.ImageIndex.Log).Log(e.AsStatus(), ""error"")")
		$$$GENERATE("		Throw e")
		$$$GENERATE("	}")
	}
	Return $$$OK
}

/// This method is invoked when an existing instance of a class is updated.
ClassMethod UpdateIndex(pID As %CacheString, pArg... As %Binary) [ CodeMode = generator, ServerOnly = 1 ]
{
	If (%mode '= "method") {
		$$$GENERATE("	Try {")
		$$$GENERATE("		Do ##class(dc.multimodel.ImageIndex.Log).Log("" -------- UpdateIndex -------- "")")
		$$$GENERATE("		Do ##class(dc.multimodel.ImageIndex.Log).Log(pID, ""pID"")")
		$$$GENERATE("		Do ##class(dc.multimodel.ImageIndex.Log).Log(.pArg, ""pArg"")")
		$$$GENERATE(" 	Set indexer = ##class(dc.multimodel.ImageIndex.Indexer).GetInstance("""_%class_""", """_%property_""")")
		$$$GENERATE("		Set indexer.Cardinality = "_..#Cardinality)
		$$$GENERATE("		Do indexer.Update(pID, pArg...)")
		$$$GENERATE("	} Catch(e) {")
		$$$GENERATE("		Do ##class(dc.multimodel.ImageIndex.Log).Log(e.AsStatus(), ""error"")")
		$$$GENERATE("		Throw e")
		$$$GENERATE("	}")
	}
	Return $$$OK
}

ClassMethod DiffRank(pSearch As %Binary, pID As %String) As %Float [ CodeMode = generator, PublicList = (SQLCODE, %msg), ServerOnly = 1, SqlProc ]
{
	If (%mode '= "method") {
		$$$GENERATE("	Set diff = """"")
		$$$GENERATE("	Try {")
		$$$GENERATE("		Do ##class(dc.multimodel.ImageIndex.Log).Log("" -------- DiffRank -------- "")")
		$$$GENERATE("		Do ##class(dc.multimodel.ImageIndex.Log).Log(pSearch, ""pSearch"")")
		$$$GENERATE("		Do ##class(dc.multimodel.ImageIndex.Log).Log(pID, ""pID"")")
		$$$GENERATE("		Set result = ##class(dc.multimodel.ImageIndex.SQLFind).%New()")
		$$$GENERATE(" 	Set indexer = ##class(dc.multimodel.ImageIndex.Indexer).GetInstance("""_%class_""", """_%property_""")")
		$$$GENERATE("		Set indexer.Cardinality = "_..#Cardinality)
		$$$GENERATE("		Set result.Indexer = indexer")
		$$$GENERATE("		Set diff = result.DiffRank(pSearch, pID)")
		$$$GENERATE("	} Catch(e) {")
		$$$GENERATE("		Do ##class(dc.multimodel.ImageIndex.Log).Log(e.AsStatus(), ""error"")")
		$$$GENERATE("		Throw e")
		$$$GENERATE("	}")
		$$$GENERATE("	Return diff")
	}
	Return $$$OK
}

}
