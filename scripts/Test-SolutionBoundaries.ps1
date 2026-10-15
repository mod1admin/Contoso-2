param(
  [Parameter(Mandatory)] [string] $SolutionFolder,
  [Parameter(Mandatory)] [string] $ExpectedPrefix,
  [string] $SharedPrefix = 'ccore'
)
$ErrorActionPreference = 'Stop'
$failures = [System.Collections.Generic.List[string]]::new()
$solXml = Join-Path $SolutionFolder 'Other/Solution.xml'
[xml] $sol = Get-Content $solXml -Raw
$pub = $sol.ImportExportXml.SolutionManifest.Publisher
 
# Rule 1: publisher prefix must match the register
if ($pub.CustomizationPrefix -ne $ExpectedPrefix) {
  $failures.Add("Publisher prefix is '$($pub.CustomizationPrefix)'")
}
 
# Rule 2: project solutions must not carry SharedCore components
if ($ExpectedPrefix -ne $SharedPrefix) {
  $hits = Get-ChildItem $SolutionFolder -Recurse -File |
    Select-String -Pattern "\b$($SharedPrefix)_\w+" -List
  $manifest = $sol.ImportExportXml.SolutionManifest
  $roots = $manifest.RootComponents.ChildNodes
  foreach ($r in $roots) {
    if ($r.schemaName -like "$($SharedPrefix)_*") {
      $failures.Add("Root component from SharedCore: $($r.schemaName)")
    }
  }
  foreach ($h in $hits) {
    # Lookups to SharedCore tables are allowed in relationship files
    if ($h.Path -notmatch 'Relationships|Workflows') {
      $failures.Add("SharedCore reference in $($h.Path)")
    }
  }
}
