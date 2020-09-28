<#
    .SYNOPSIS
    Gets Bearer Token Via Azure AD Registered App

    .DESCRIPTION
    Returns a Bearer Token when Authenticated with AzureAD App Credentials to query Microsoft Defender ATP API's

    .PARAMETER TenantID
    Your AzureAD TenantID

    .PARAMETER ClientID
    Your Registered Applications AzureAD ClientID

    .PARAMETER ClientSecret
    Your Registered Applications Client Secret key

    .EXAMPLE
    Get-DefenderATPBearerToken -TenantID '12345678910' -ClientId '1asfd123bsar123' -ClientSecret '123456x,,797124'
#>

Function Get-DefenderATPBearerToken () {
        ####################################
        # Set Parameters
        param (
            [Parameter (Mandatory = $true)]
            [string] $TenantID,
            [string] $ClientID,
            [string] $ClientSecret
        )

        ####################################
        # Set URi
        $resourceAppIdUri = 'https://api.securitycenter.windows.com'
        $oAuthURI = "https://login.windows.net/$TenantID/oauth2/token"

        ####################################
        # Construct Request Body
        $authBody = [Ordered] @{
            resource        = "$resourceAppIdUri"
            client_id       = "$ClientID"
            client_secret   = "$ClientSecret"
            grant_type      = 'client_credentials'
        }

    Try {
        ####################################
        # Get Token
        $tokenRequest = Invoke-WebRequest -Method Post -Uri $oAuthUri -Body $authBody -UseBasicParsing -ErrorAction Stop

        ####################################
        # Get Token
        $bearerToken = ($tokenRequest.content | ConvertFrom-Json).access_token
        ####################################
        # Get Token Type
        $bearerType = ($tokenRequest.content | ConvertFrom-Json).token_type
        ####################################
        # Get Token Resource
        $bearerResource = ($tokenRequest.content | ConvertFrom-Json).resource
        ####################################
        # Get Token Expiration
        $bearerExpiration = ($tokenRequest.Content | ConvertFrom-Json).expires_in

        ####################################
        # Gather Array
        $bearerResources = [PSCUSTOMOBJECT]@{
            bearerToken      = $bearerToken
            bearerType       = $bearerType
            bearerResource   = $bearerResource
            bearerExpiration = $bearerExpiration
        }

    }
    Catch {
        Write-Warning $Error[0]
    }
    Return $bearerResources | Format-Table -Wrap -AutoSize
}