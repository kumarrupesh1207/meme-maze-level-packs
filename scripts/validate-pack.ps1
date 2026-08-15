param(
  [string]$PackPath = (Join-Path $PSScriptRoot '..\packs\pack-5.json')
)

$ErrorActionPreference = 'Stop'
$pack = Get-Content (Resolve-Path $PackPath) -Raw | ConvertFrom-Json
$hasFailures = $false

foreach ($level in @($pack.levels)) {
  $surfaces = @()
  foreach ($floor in @($level.floors)) {
    $surfaces += [pscustomobject]@{
      Kind = 'floor'; X = [double]$floor.position.x
      Y = [double]$floor.position.y; Width = [double]$floor.size.x
    }
  }
  foreach ($floor in @($level.crumbling_floors)) {
    if ($null -eq $floor) { continue }
    $surfaces += [pscustomobject]@{
      Kind = 'crumble'; X = [double]$floor.position.x
      Y = [double]$floor.position.y; Width = [double]$floor.size.x
    }
  }
  foreach ($floor in @($level.hidden_floors)) {
    if ($null -eq $floor) { continue }
    $surfaces += [pscustomobject]@{
      Kind = 'hidden'; X = [double]$floor.position.x
      Y = [double]$floor.position.y; Width = [double]$floor.size.x
    }
  }
  $surfaces = @($surfaces | Sort-Object X)
  $errors = @()

  if ($surfaces.Count -eq 0) {
    $errors += 'has no solid surfaces'
  }

  for ($i = 0; $i -lt $surfaces.Count; $i++) {
    $a = $surfaces[$i]
    if ($a.Width -le 0) { $errors += "surface $i has invalid width" }
    for ($j = $i + 1; $j -lt $surfaces.Count; $j++) {
      $b = $surfaces[$j]
      $horizontalOverlap = [math]::Min($a.X + $a.Width, $b.X + $b.Width) - [math]::Max($a.X, $b.X)
      $verticalDistance = [math]::Abs($a.Y - $b.Y)
      if ($a.Kind -ne 'hidden' -and $b.Kind -ne 'hidden' -and
          $horizontalOverlap -gt 0 -and $verticalDistance -lt 200) {
        $errors += "surfaces $i and $j visually overlap"
      }
    }
  }

  # Conservative authoring limits: harder levels must use timing and choices,
  # not a jump beyond the player's dependable reach.
  $reachable = New-Object bool[] $surfaces.Count
  for ($i = 0; $i -lt $surfaces.Count; $i++) {
    $surface = $surfaces[$i]
    if ($level.spawn_point.x -ge $surface.X -and
        $level.spawn_point.x -le ($surface.X + $surface.Width)) {
      $reachable[$i] = $true
    }
  }
  if (-not ($reachable -contains $true) -and $surfaces.Count -gt 0) {
    $reachable[0] = $true
  }

  for ($i = 0; $i -lt $surfaces.Count; $i++) {
    if (-not $reachable[$i]) { continue }
    for ($j = $i + 1; $j -lt $surfaces.Count; $j++) {
      $a = $surfaces[$i]; $b = $surfaces[$j]
      $gap = $b.X - ($a.X + $a.Width)
      $rise = $a.Y - $b.Y
      if ($gap -ge 0 -and $gap -le 220 -and $rise -le 160 -and $rise -ge -220) {
        $reachable[$j] = $true
      }
    }
  }

  $goalIsReachable = $false
  for ($i = 0; $i -lt $surfaces.Count; $i++) {
    $surface = $surfaces[$i]
    if ($reachable[$i] -and $level.goal.position.x -ge $surface.X -and
        $level.goal.position.x -le ($surface.X + $surface.Width)) {
      $goalIsReachable = $true
    }
  }
  if (-not $goalIsReachable) { $errors += 'has no conservative reachable route to the goal' }

  if ($errors.Count -gt 0) {
    $hasFailures = $true
    Write-Host "FAIL Level $($level.level_id): $($errors -join '; ')"
  } else {
    Write-Host "PASS Level $($level.level_id)"
  }
}

if ($hasFailures) { exit 1 }
