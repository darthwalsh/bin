MSBuild script automatically downloads [Grammatica](https://grammatica.percederberg.net/) assets and generates C# grammar source files.

https://github.com/darthwalsh/ExpLang/blob/v0.0.1-csharp/Engine/Engine.csproj#L31

```xml
  <Target Name="GenerateGrammar" BeforeTargets="BeforeBuild">
    <PropertyGroup>
      <GrammaticaURL>https://github.com/cederberg/grammatica/releases/download/v1.6/grammatica-1.6.zip</GrammaticaURL>
      <GrammaticaZip>$(IntermediateOutputPath)grammatica-1.6.zip</GrammaticaZip>
      <GrammaticaJar>$(IntermediateOutputPath)grammatica-1.6\lib\grammatica-1.6.jar</GrammaticaJar>
      <ExecNeeded>false</ExecNeeded>
      <ExecNeeded Condition="!Exists('$(GrammaticaGenerated)\ExpAnalyzer.cs')">true</ExecNeeded>
      <ExecNeeded Condition="$([System.IO.File]::GetLastWriteTime('ExpLang.grammar').Ticks) &gt; $([System.IO.File]::GetLastWriteTime('$(GrammaticaGenerated)\ExpAnalyzer.cs').Ticks)">true</ExecNeeded>
    </PropertyGroup>
    <!-- If needed, download and extract grammatica-1.6.jar. Ignore error from first build, due to https://github.com/Microsoft/msbuild/issues/3884 -->
    <DownloadFile Condition="$(ExecNeeded) And !Exists($(GrammaticaZip)) And !Exists($(GrammaticaJar))" SourceUrl="$(GrammaticaURL)" DestinationFolder="$(IntermediateOutputPath)" />
    <Unzip Condition="$(ExecNeeded) And !Exists($(GrammaticaJar))" SourceFiles="$(GrammaticaZip)" DestinationFolder="$(IntermediateOutputPath)" OverwriteReadOnlyFiles="true" />
    <Exec Condition="$(ExecNeeded)" Command="java -jar &quot;$(GrammaticaJar)&quot; ExpLang.grammar --csoutput $(GrammaticaGenerated) --cspublic --csnamespace Engine.Generated --csclassname Exp" />
    <!-- Append to FileWrites so the file will be removed on clean -->
    <ItemGroup>
      <FileWrites Include="$(GrammaticaZip);$(GrammaticaJar);$(GrammaticaGenerated)\*" />
    </ItemGroup>
  </Target>
```

## Unzip problem in old MSBuild
But note: https://github.com/darthwalsh/ExpLang/issues/1 you might get error on first run:
```
Engine\Engine.csproj(73,5): Error MSB3936: Failed to open unzip file "grammatica-1.6/" to "C:\Users\VssAdministrator\AppData\Local\Temp\grammatica-1.6\".  Could not find a part of the path 'C:\Users\VssAdministrator\AppData\Local\Temp\grammatica-1.6\'.
Engine\Engine.csproj(73,5): Error MSB3936: Failed to open unzip file "grammatica-1.6/doc/" to "C:\Users\VssAdministrator\AppData\Local\Temp\grammatica-1.6\doc\".  Could not find a part of the path 'C:\Users\VssAdministrator\AppData\Local\Temp\grammatica-1.6\doc\'.
```
Caused by [dotnet/msbuild/issues/3884](https://github.com/dotnet/msbuild/issues/3884) which is now fixed