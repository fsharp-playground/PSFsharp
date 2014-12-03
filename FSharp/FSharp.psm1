#requres -version 3.0

# ---------------------------------------------------------------------- Functions

function Find-FscExe {

  $roots   = @('HKLM:\Software', 'HKLM:\Software\Wow6432Node')
  $subkeys = @(
    'Microsoft\FSharp\3.1\Runtime\v4.0',
    'Microsoft\FSharp\3.0\Runtime\v4.0',
    'Microsoft\FSharp\2.0\Runtime\v4.0' 
  )

  $installedFolder = $roots |
    Foreach { $root= $_; $subkeys | Foreach { "$root\$_" } } |
    Where   { Test-Path $_ } |
    Foreach { Get-ItemProperty $_ } |
    Foreach '(default)' |
    Select-Object -First 1

  Join-Path $installedFolder 'fsc.exe'

} # End of Find-FscExe

function Invoke-FscExe {

  param (
    [Parameter(Mandatory)]
    [string[]] $Arguments
  )

  & (Find-FscExe) $Arguments

  $?

} # End of Invoke-FscExe

function New-FsModule {

  param (
    [Parameter(Mandatory)]
    [string] $Name
  )

  $tempAssemblyPath = [IO.Path]::Combine(
    [IO.Path]::GetTempPath(),
      [IO.Path]::ChangeExtension(
        [IO.Path]::GetRandomFileName(), '.dll'))

  $result = Invoke-FscExe `
    -Arguments @(
      '--nologo',
      "--out:$tempAssemblyPath",
      '--target:library'
      '--reference:System.Management.Automation'
      $Name)

  if (!$result) {
    Write-Host -ForegroundColor Yellow 'Failed to compile.'
    return
  }

  $tempAssemblyPath

} # End of New-FsModule

# ---------------------------------------------------------------------- Alias 

Set-Alias -Name fsc -Value Invoke-FscExe

# ---------------------------------------------------------------------- Export

Export-ModuleMember -Alias *
Export-ModuleMember -Function *

# ---------------------------------------------------------------------- EOF

