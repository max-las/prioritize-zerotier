$lowest_metric = $null
$zt_index = $null
$zt_metric = $null
$zt_matches = 0
$zt_metric_matches = 0

function End {
  param(
    [String]$Message
  )

  Write-Output $Message
  Write-Output ""
  Read-Host "Press Enter to exit"
  Exit
}

ForEach ($if in Get-NetIPInterface) {
  if (($zt_matches -eq 0) -and $if.InterfaceAlias.Contains("ZeroTier One")) {
    $zt_index = $if.InterfaceIndex
    $zt_metric = $if.InterfaceMetric
  }

  if ($if.InterfaceIndex -eq $zt_index) {
    $zt_matches++
  }

  if ($if.InterfaceMetric -eq $zt_metric) {
    $zt_metric_matches++
  }

  if (($null -eq $lowest_metric) -or ($if.InterfaceMetric -lt $lowest_metric)) {
    $lowest_metric = $if.InterfaceMetric
  }
}

if ($null -eq $zt_index) {
  End -Message "Error: ZeroTier One interface not found."
}

if (($zt_metric -eq $lowest_metric) -and ($zt_matches -eq $zt_metric_matches)) {
  End -Message "ZeroTier One interface already has the lowest interface metric. Nothing to do."
}

$new_metric = $lowest_metric - 5
if ($new_metric -le 0) {
  $new_metric = $lowest_metric - 1
}
if ($new_metric -le 0) {
  End -Message "Error: Cannot set ZeroTier One interface metric to a value lower than $lowest_metric."
}

$currentPrincipal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
if (!$currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
  End -Message "Error: Need administrator privileges to update ZeroTier One interface metric."
}

Set-NetIPInterface -InterfaceIndex $zt_index -InterfaceMetric $new_metric
End -Message "ZeroTier One interface metric updated successfully!"
