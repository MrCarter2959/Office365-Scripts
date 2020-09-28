<#
    .SYNOPSIS
    Offloads a Machine from Defender ATP

    .DESCRIPTION
    Offloads a Machine from Windows Defender ATP, within Microsoft 365.

    .PARAMETER ID
    Your AzureAD TenantID

    .PARAMETER BearerToken
    Your Defender ATP Bearer Token

    .PARAMETER ContentType
    Invoke-WebRequest's Selected Content Type

    .PARAMETER Comment
    Required Comment to Offload the device

    .EXAMPLE
    Remove-DefenderATPDevice -ID '1' -BearerToken '12345' -ContentType application/json' -Comment 'Offloading device, no longer in service'
#>

Function Remove-DefenderATPDevice {
####################################
# Set Parameters
    param (
        [Parameter (Mandatory = $true)]
        [string] $ID,
        [string] $BearerToken,
        [ValidateSet("application/json")]
        [string] $ContentType,
        [ValidateSet("api-us.securitycenter.microsoft.com","api-eu.securitycenter.microsoft.com","api-uk.securitycenter.microsoft.com")]
        [string] $DefenderAPIGeoLocation,
        [string] $Comment
    )
####################################
# Set Headers
$offloadHeaders = @{
    Authorization   = "Bearer $BearerToken"
    'Content-Type'  = $ContentType
}
####################################
# Set Body
$offloadBody = @{
    Comment = $Comment
} | ConvertTo-Json

####################################
# Invoke Machine Offload
Try {
    $offloadInvoke = Invoke-WebRequest -Method POST -Uri "https://$($DefenderAPIGeoLocation)/api/machines/$($ID)/offboard" -Body $offloadBody -Headers $offloadHeaders -ErrorAction Stop
}
Catch {
    Write-Warning $Error[0]
}
####################################
# Set Results (converted from JSON)
$offloadResults = ($offloadInvoke.content | ConvertFrom-Json)

####################################
# Return Results
Return $offloadResults
}