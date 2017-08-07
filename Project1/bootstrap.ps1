[CmdletBinding()]
param(

)

$scriptsDir = split-path -parent $MyInvocation.MyCommand.Definition
$scriptsDir = "$scriptsDir\..\scripts"
$rootDir = & $scriptsDir\findFileRecursivelyUp.ps1 $scriptsDir .vcpkg-root

$sourcesPath = "$rootDir\Project1"
Write-Verbose("Path " + $sourcesPath)

if (!(Test-Path $sourcesPath))
{
    New-Item -ItemType directory -Path $sourcesPath -force | Out-Null
}

$downloadsDir = "$rootDir\downloads"

$nugetexe = & $scriptsDir\fetchDependency.ps1 "nuget" 1
$nugetPackageDir = "$downloadsDir\nuget-packages"

try{
    pushd $sourcesPath
    $msbuildExeWithPlatformToolset = & $scriptsDir\findAnyMSBuildWithCppPlatformToolset.ps1
    $msbuildExe = $msbuildExeWithPlatformToolset[0]
    $platformToolset = $msbuildExeWithPlatformToolset[1]
    $windowsSDK = & $scriptsDir\getWindowsSDK.ps1
    & $nugetexe restore Project1.sln
    & $msbuildExe /p:Configuration=Release /p:Platform=x86 /p:PlatformToolset=$platformToolset /p:TargetPlatformVersion=$windowsSDK /m

    Write-Verbose("Placing exe in the correct location")

    Copy-Item $sourcesPath\Release\Project1.exe $rootDir\Project1.exe | Out-Null
}
finally{
    popd
}
