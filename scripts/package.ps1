param(
    [ValidateSet("arm64-v8a")]
    [string]$Abi = "arm64-v8a",
    [string]$BuildRoot = "build",
    [string]$AndroidPlatform = "android-28",
    [string]$NdkHome = "",
    [string]$Generator = "Ninja"
)

$ErrorActionPreference = "Stop"
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$repoRoot = (Resolve-Path (Join-Path $scriptDir "..")).Path

function Resolve-NdkHome {
    if ($NdkHome -and (Test-Path $NdkHome)) { return (Resolve-Path $NdkHome).Path }
    if ($env:ANDROID_NDK_HOME -and (Test-Path $env:ANDROID_NDK_HOME)) { return (Resolve-Path $env:ANDROID_NDK_HOME).Path }
    if ($env:ANDROID_HOME) {
        $preferred = Join-Path $env:ANDROID_HOME "ndk/28.2.13676358"
        if (Test-Path $preferred) { return (Resolve-Path $preferred).Path }
    }
    throw "Android NDK not found. Set ANDROID_NDK_HOME or install NDK 28.2.13676358."
}

$ndk = Resolve-NdkHome
$toolchain = Join-Path $ndk "build/cmake/android.toolchain.cmake"
$buildDir = Join-Path $repoRoot "$BuildRoot-$Abi"

cmake -S $repoRoot -B $buildDir -G $Generator `
    "-DCMAKE_TOOLCHAIN_FILE=$toolchain" `
    "-DANDROID_ABI=$Abi" `
    "-DANDROID_PLATFORM=$AndroidPlatform" `
    "-DANDROID_STL=c++_shared" `
    "-DMOD_ID=player_finder" `
    "-DMOD_NAME=Player Finder" `
    "-DMOD_AUTHOR=Glacxxy" `
    "-DMOD_VERSION=0.1.0" `
    "-DMOD_LIBRARY_NAME=player_finder" `
    "-DMOD_MINECRAFT_VERSIONS=[\"1.21.*\"]"

cmake --build $buildDir --target levi_package --parallel
Write-Host "Created: $buildDir/player_finder-0.1.0-$Abi.levipack"
