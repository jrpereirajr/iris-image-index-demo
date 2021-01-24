Include %occErrors

/// Adapted from https://github.com/intersystems-ru/Cache-FileServer
Class dc.rest.SimpleImageServer Extends %CSP.REST
{

/// This parameter influences the CORS support. The default is an empty string meaning 'not specified'.
/// If set to true (1) then CORS processing is ON. If set to false (0) then CORS processing is OFF.
/// If left unset "" then the decision to process CORS is delegated to the setting on the URL map route.
Parameter HandleCorsRequest = 1;

XData UrlMap
{
<Routes>
<Route Url="/upload" Method="POST" Call="UploadFile"/>
<Route Url="/download" Method="GET" Call="Download"/>
<Route Url="/image-files" Method="GET" Call="GetImageFiles"/>
<Route Url="/get-color-similars" Method="GET" Call="GetColorSimilarImages"/>
<Route Url="/fast-colorthief-test" Method="POST" Call="FastColorthiefTest"/>
</Routes>
}

ClassMethod UploadFile(ByRef pFileName = "") As %Status
{
	#dim sc As %Status = $$$OK
	Try {
 		Set Location = $GET(^Settings("user_files_dir"), "/data/img")
		Set Stream = %request.GetMimeData("file", 1)
		Set Name = $PIECE(Stream.FileName, ".", 0, * - 1)
		Set Extension = $PIECE(Stream.FileName, ".", *)
		Set FileName = Location_"/"_Name_"."_Extension

		Set counter = 1
		While ##class(%File).Exists(FileName) {
			Set FileName=Location_Name_"_("_counter_")."_Extension
			Set counter = counter + 1
		}
		Set file = ##class(%Stream.FileBinary).%New()
		Set file.Filename = FileName
		Do file.CopyFromAndSave(Stream)

    Set pFileName = FileName
		
		Kill file
	} Catch ex {
		Set sc = ex.AsStatus()
	}
	Quit sc
}

ClassMethod Download() As %Status
{
	Set sc = $$$OK
	Try {
 		Set Location = $GET(^Settings("user_files_dir"), "/data/img")
		Set pFileName = $GET(%request.Data("filename", 1))
		
		If $MATCH(pFileName, ".*\.jpg|.*\.jpeg") {
			Set %response.ContentType="image/jpeg"
		} ElseIf $MATCH(pFileName, ".*\.png") {
			Set %response.ContentType="image/png"
		} ElseIf $MATCH(pFileName, ".*\.gif") {
			Set %response.ContentType="image/gif"
		} Else {
			Set %response.ContentType = "application/octet-stream"
		}

		Do %response.SetHeader("Content-Disposition","attachment; filename="""_pFileName_"""")
		Set stream=##class(%FileBinaryStream).%New()
		Set stream.Filename = Location_"/"_pFileName
		While 'stream.AtEnd {
		Set line=stream.Read()
			Write line
		}
	} Catch ex {
		Set sc = ex.AsStatus()
	}
	Return sc
}

ClassMethod GetImageFiles() As %Status
{
	Set sc = $$$OK
	Set files = []
	Try {
 		Set Location = $GET(^Settings("user_files_dir"), "/data/img")
		Set dir = $GET(%request.Data("dir", 1))
		Set fillDir = Location_"/"_dir
		If ##class(%File).DirectoryExists(fillDir) {
			Set rs = ##Class(%ResultSet).%New("%File.FileSet")
 			Do rs.Execute(fillDir, "*", , 1)
 			While rs.Next() {
				If (rs.Get("Type") '= "D") {
					Do files.%Push(dir_"/"_rs.Get("ItemName"))
				}
			}
		}
	} Catch ex {
		Set sc = ex.AsStatus()
	}
	Write files.%ToJSON()
	Return sc
}

ClassMethod GetColorSimilarImages() As %Status
{
	Set sc = $$$OK
	Try {
 		Set Location = $GET(^Settings("user_files_dir"), "/data/img")
		Set filename = $GET(%request.Data("filename", 1))
		Set searchConfig = {
			"color_similarity": {
				"image": (Location_"/"_filename),
				"first": 5
			}
		}.%ToJSON()
		/*
		&SQL(
			SELECT %DLIST(ImageFile) INTO :similarImagesList FROM dc_multimodel_ImageIndex.Test WHERE 
				ID %FIND search_index(idxImageFile, :searchConfig)
		)
		If (SQLCODE '= 0) && (SQLCODE '= 100) {
			Throw ##class(%Exception.SQL).CreateFromSQLCODE(SQLCODE, "")
		}
		*/
		Set similarImagesList = ""
		Set sql = 
		"SELECT %DLIST(ImageFile) AS similarImagesList "_
		"FROM dc_multimodel_ImageIndex.Test WHERE "_
			"ID %FIND search_index(idxImageFile, '"_searchConfig_"')"
		Set rs = ##class(%SQL.Statement).%ExecDirect(, sql)
		If (rs.%Next()) {
			Set similarImagesList = rs.similarImagesList
		}
		Set similarImages = []
		For i = 1:1:$LISTLENGTH(similarImagesList) {
			Set imgFile = $LISTGET(similarImagesList, i)
			Set imgFile = $REPLACE(imgFile, Location, "")
			Do similarImages.%Push(imgFile)
		}
		Write {
			"similarImages": (similarImages),
			"sql": (sql)
		}.%ToJSON()
	} Catch ex {
		Set sc = ex.AsStatus()
	}
	Return sc
}

ClassMethod FastColorthiefTest() As %Status
{
  Set sc  = $$$OK
  Try {
    $$$ThrowOnError(..UploadFile(.imagepath))
    Set json = ##class(dc.multimodel.example.TestPython).PythonImport("json")
    Set fastcolorthief =  ##class(dc.multimodel.example.TestPython).PythonImport("fast_colorthief")
    Set dominantcolor = fastcolorthief."get_dominant_color"(imagepath, 1)
    Set colorpalette = fastcolorthief."get_palette"(imagepath)
    Set resp = {
      "dominantColor": ({}.%FromJSON(json.dumps(dominantcolor))),
      "colorPalette": ({}.%FromJSON(json.dumps(colorpalette)))
    }
		Set %response.ContentType="application/json"
    Write resp.%ToJSON()
  } Catch(e) {
    Set sc = e.AsStatus()
  }
  Return sc
}

}
