Class dc.multimodel.example.TestPython Extends %RegisteredObject
{

/// ln -s /shared/python-lib/barchart /usr/irissys/mgr/python/
ClassMethod Main() As %Status
{
  Set sc = $$$OK

  Write "Example2VirtualSummit: ", !
  Do ..Example2VirtualSummit()
  Write "------------------",!
  
  Write "Example3VirtualSummit: ", !
  Do ..Example3VirtualSummit()
  Write "------------------",!
  
  Write "Example4VirtualSummit: ", !
  Do ..Example4VirtualSummit()
  Write "------------------",!
  
  Write "TestColor1: ", !
  Set start = $ZHOROLOG
  Do ..TestColor1()
  Write "------------------ (",$ZHOROLOG - start,")",!
  
  Write "TestColor2: ", !
  Set start = $ZHOROLOG
  Do ..TestColor2()
  Write "------------------ (",$ZHOROLOG - start,")",!
  
  Write "TestColor3: ", !
  Set start = $ZHOROLOG
  Do ..TestColor3()
  Write "------------------ (",$ZHOROLOG - start,")",!

  Return sc
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

ClassMethod Example2VirtualSummit() As %Status
{
  Set sc = $$$OK
  Set b = ##class(%SYS.Python).Import("builtins")
  Do b.print("Hello world")
  Return sc
}

ClassMethod Example3VirtualSummit() As %Status
{
  Set sc = $$$OK
  Set np = ##class(%SYS.Python).Import("numpy")
  Set b = ##class(%SYS.Python).Import("builtins")
  Set futureValue = np.fv(0.05/12, 10*12, -100, -100)
  Write b.str(futureValue), !
  Return sc
}

ClassMethod Example4VirtualSummit() As %Status
{
  Set sc = $$$OK
  Set b = ##class(%SYS.Python).Import("builtins")
  Try {
    Set barchart = ##class(%SYS.Python).Import("barchart")
  } Catch(e) {
    $$$TOE(sc, ##class(%SYS.Python).Install("matplotlib"))
    Set barchart = ##class(%SYS.Python).Import("barchart")
  }
  Set df = barchart.exampleDF()
  ZWrite df
  Do b.print(df."to_string"())
  Do barchart.buildGraph("/shared/barchart_example.svg", df, "Country", "GPD_Per_Capita")
  Return sc
}

ClassMethod TestColor1() As %Status
{
  // http://jsonpickle.github.io/
  // https://github.com/fengsp/color-thief-py
  Set sc = $$$OK
  
  //Set json = ..PythonImport("jsonpickle")
  Set b = ##class(%SYS.Python).Import("builtins")
  Set json = ..PythonImport("json")
  Set fastcolorthief = ..PythonImport("fast_colorthief")
  Set imagepath = "/shared/test.png"
  Set dominantcolor = fastcolorthief."get_dominant_color"(imagepath, 1)
  Set colorpalette = fastcolorthief."get_palette"(imagepath)
  Do b.print(dominantcolor, colorpalette)
  //ZWrite dominantcolor, colorpalette
  //ZWrite {}.%FromJSON(json.encode(dominantcolor)), {}.%FromJSON(json.encode(colorpalette))
  ZWrite {}.%FromJSON(json.dumps(dominantcolor)), {}.%FromJSON(json.dumps(colorpalette))

  Return sc
}

ClassMethod TestColor2() As %Status
{
  // https://github.com/obskyr/colorgram.py
  Set sc = $$$OK

  Set json = ..PythonImport("jsonpickle")
  //Set json = ..PythonImport("json")
  Set colorgram = ..PythonImport("colorgram")
  Set imagepath = "/shared/test.png"
  // Extract 6 colors from an image.
  Set colors = colorgram.extract(imagepath, 6)
  ZWrite colors
  Set colors = {}.%FromJSON(json.encode(colors))
  //Set colors = {}.%FromJSON(json.dumps(colors))
  ZWrite colors

  Return sc
}

ClassMethod TestColor3() As %Status
{
  // https://github.com/CairX/extract-colors-py
  Set sc = $$$OK

  //Set json = ..PythonImport("jsonpickle")
  Set json = ..PythonImport("json")
  Set extcolors = ..PythonImport("extcolors")
  Set imagepath = "/shared/test.png"
  Set colors = extcolors."extract_from_path"(imagepath)
  //ZWrite {}.%FromJSON(json.encode(colors))
  ZWrite {}.%FromJSON(json.dumps(colors))

  Return sc
}

ClassMethod TestKNN() As %Status
{
  Set sc = $$$OK
  Set b = ##class(%SYS.Python).Import("builtins")
  Set json = ##class(%SYS.Python).Import("json")
  Set knn = ##class(%SYS.Python).Import("knn")

  Set k = 5
  Set x = "[[235, 198, 96]]"
  Set ind = knn.query(x, k, 3)
  Do b.print(ind.tolist())
  zw {}.%FromJSON(json.dumps(ind.tolist()))

  Return sc
}

/// Install PIP packages to default PIP directory instead of %SYS.Python's default directory
ClassMethod Install(packages)
{
  Set dir = ##class(%File).SubDirectoryName($SYSTEM.Util.ManagerDirectory(),"python",1)
  Set builtins = ##class(%SYS.Python).Import("builtins")
  Set pip = ##class(%SYS.Python).Import("pip._internal")
  Set args = builtins.list()

  Do args.append("install")
  //Do args.append("--target="_dir)
  Do args.append($TRANSLATE($ZSTRIP(packages,"*W"),","," "))

  // Now install ...
  Set r = pip.main(args)
  If r {
    zw r
    Set status = $$$ERROR($$$PythonPipInstallFailed,r)
    Quit
  }
}

}
