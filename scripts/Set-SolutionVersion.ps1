param(
  [Parameter(Mandatory)] [string] $Solution,
  [Parameter(Mandatory)] [int] $Build,
  [int] $Revision = 0
)
$path = "src/solutions/$Solution/Other/Solution.xml"
[xml] $xml = Get-Content $path -Raw
$node = $xml.ImportExportXml.SolutionManifest
$parts = $node.Version.Split('.')
$node.Version = "$($parts[0]).$($parts[1]).$Build.$Revision"
$xml.Save((Resolve-Path $path))
Write-Host "$Solution version set to $($node.Version)"
