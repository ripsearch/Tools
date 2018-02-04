. $PSScriptRoot\StartProcess.ps1

function Build-Sln($SolutionFile, $Configuration, $Platform, $OutputVar="OutDir", [String]$OutputFolder="") {
    Write-Host "Building $SolutionFile ..."

    $vsdevcmd = $env:VLPP_VSDEVCMD_PATH
    if ($vsdevcmd -eq $null) {
        throw "You have to add an environment variable named VLPP_VSDEVCMD_PATH and set its value to the path of VsDevCmd.bat (e.g. C:\Program Files (x86)\Microsoft Visual Studio\2017\Professional\Common7\Tools\VsDevCmd.bat)"
    }
    if ($OutputFolder.IndexOf(":\") -eq -1) {
        $output_dir = "$OutputVar=`"$PSScriptRoot\.Output\$OutputFolder"
    } else {
        $output_dir = "$OutputVar=`"$OutputFolder"
    }
    $msbuild_arguments = "MSBUILD `"$SolutionFile`" /m:8 /t:Rebuild /p:Configuration=`"$Configuration`";Platform=`"$Platform`";$($output_dir)"
    $cmd_arguments = "`"`"$vsdevcmd`" & $msbuild_arguments"
    Start-Process-And-Wait (,($env:ComSpec, "/c $cmd_arguments"))
}

function Test-Single-Binary($FileName) {
    if (!(Test-Path -Path $PSScriptRoot\.Output\$FileName)) {
        throw "Failed"
    }
    Copy $PSScriptRoot\.Output\$FileName $PSScriptRoot\$FileName
}

function Test-Single-Binary-Rename($Source, $Target) {
    if (!(Test-Path -Path $PSScriptRoot\.Output\$Source)) {
        throw "Failed"
    }
    Copy $PSScriptRoot\.Output\$Source $PSScriptRoot\$Target
}

function Import-Project($ProjectName, [String[]]$Dependencies) {
    Write-Host "Importing $ProjectName ..."
    Push-Location $PSScriptRoot\..\..\$ProjectName\Import | Out-Null
    foreach ($dep in $Dependencies) {
        Write-Host "    From $dep"
        Copy-Item ..\..\$dep\Release\*.h .
        Copy-Item ..\..\$dep\Release\*.cpp .
    }
    Pop-Location | Out-Null
}

function Release-Project($ProjectName) {
    Write-Host "Releasing $ProjectName ..."
    Start-Process-And-Wait (,("$PSScriptRoot\CodePack.exe", "..\..\$ProjectName\Release\CodegenConfig.xml"))
}

function Update-Parser($FileName) {
    Write-Host "Updating Parser: $FileName ..."
    Start-Process-And-Wait (,("$PSScriptRoot\ParserGen.exe", "$FileName"))
}