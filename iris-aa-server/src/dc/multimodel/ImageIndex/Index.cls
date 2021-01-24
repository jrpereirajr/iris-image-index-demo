/// Functional Indexing to be used to optimize queries on image data
Class dc.multimodel.ImageIndex.Index Extends %Library.FunctionalIndex [ System = 3 ]
{

/// This method is invoked when an existing instance of a class is deleted.
ClassMethod DeleteIndex(pID As %CacheString, pArg... As %Binary) [ CodeMode = generator, ServerOnly = 1 ]
{
	If (%mode '= "method") {
		$$$GENERATE("	Try {")
		$$$GENERATE("		Do ##class(dc.multimodel.ImageIndex.Log).Log("" -------- DeleteIndex -------- "")")
		$$$GENERATE("		Do ##class(dc.multimodel.ImageIndex.Log).Log(pID, ""pID"")")
		$$$GENERATE("		Do ##class(dc.multimodel.ImageIndex.Log).Log("".pArg"", ""pArg"")")
		$$$GENERATE("		Set indexer = ##class(dc.multimodel.ImageIndex.Indexer).GetInstance("""_%class_""", """_%property_""")")
		$$$GENERATE("		Set indexGlb = indexer.GetIndexLocation()")
		$$$GENERATE("		Kill @indexGlb@(pID)")
		$$$GENERATE("	} Catch(e) {")
		$$$GENERATE("		Do ##class(dc.multimodel.ImageIndex.Log).Log(e.AsStatus(), ""error"")")
		$$$GENERATE("	}")
	}
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
		$$$GENERATE("		Set result.Indexer = indexer")
		$$$GENERATE("		Do result.PrepareFind(pSearch)")
		$$$GENERATE("	} Catch(e) {")
		$$$GENERATE("		Do ##class(dc.multimodel.ImageIndex.Log).Log(e.AsStatus(), ""error"")")
		$$$GENERATE("	}")
		$$$GENERATE("	Return result")
	}
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
		$$$GENERATE(" 	Set indexer = ##class(dc.multimodel.ImageIndex.Indexer).GetInstance("""_%class_""", """_%property_""")")
		$$$GENERATE("		Do indexer.GetDominantColor(pArg(1), .rgb)")
		$$$GENERATE("		Set indexGlb = indexer.GetIndexLocation()")
		$$$GENERATE("		Set @indexGlb@(pID) = pID")
		$$$GENERATE("		Merge @indexGlb@(pID) = rgb")
		$$$GENERATE("	} Catch(e) {")
		$$$GENERATE("		Do ##class(dc.multimodel.ImageIndex.Log).Log(e.AsStatus(), ""error"")")
		$$$GENERATE("	}")
	}
}

ClassMethod PurgeIndex() [ CodeMode = generator, ServerOnly = 1 ]
{
	If (%mode '= "method") {
		$$$GENERATE("	Try {")
		$$$GENERATE("		Do ##class(dc.multimodel.ImageIndex.Log).Log("" -------- PurgeIndex -------- "")")
		$$$GENERATE(" 	Set indexer = ##class(dc.multimodel.ImageIndex.Indexer).GetInstance("""_%class_""", """_%property_""")")
		$$$GENERATE(" 	Set indexGbl = indexer.GetIndexLocation()")
		$$$GENERATE(" 	Kill @indexGbl")
		$$$GENERATE("	} Catch(e) {")
		$$$GENERATE("		Do ##class(dc.multimodel.ImageIndex.Log).Log(e.AsStatus(), ""error"")")
		$$$GENERATE("	}")
	}
}

ClassMethod SortBeginIndex() [ CodeMode = generator, ServerOnly = 1 ]
{
	If (%mode '= "method") {
		$$$GENERATE("	Try {")
		$$$GENERATE("		Do ##class(dc.multimodel.ImageIndex.Log).Log("" -------- SortBeginIndex -------- "")")
		$$$GENERATE("	} Catch(e) {")
		$$$GENERATE("		Do ##class(dc.multimodel.ImageIndex.Log).Log(e.AsStatus(), ""error"")")
		$$$GENERATE("	}")
	}
}

ClassMethod SortEndIndex(pCommit As %Integer = 1) [ CodeMode = generator, ServerOnly = 1 ]
{
	If (%mode '= "method") {
		$$$GENERATE("	Try {")
		$$$GENERATE("		Do ##class(dc.multimodel.ImageIndex.Log).Log("" -------- SortEndIndex -------- "")")
		$$$GENERATE("		Do ##class(dc.multimodel.ImageIndex.Log).Log(pCommit, ""pCommit"")")
		$$$GENERATE("	} Catch(e) {")
		$$$GENERATE("		Do ##class(dc.multimodel.ImageIndex.Log).Log(e.AsStatus(), ""error"")")
		$$$GENERATE("	}")
	}
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
		$$$GENERATE("		Do indexer.GetDominantColor(pArg(1), .rgb)")
		$$$GENERATE("		Set indexGlb = indexer.GetIndexLocation()")
		$$$GENERATE("		Kill @indexGlb@(pID)")
		$$$GENERATE("		Set @indexGlb@(pID) = pID")
		$$$GENERATE("		Merge @indexGlb@(pID) = rgb")
		$$$GENERATE("	} Catch(e) {")
		$$$GENERATE("		Do ##class(dc.multimodel.ImageIndex.Log).Log(e.AsStatus(), ""error"")")
		$$$GENERATE("	}")
	}
}

}
