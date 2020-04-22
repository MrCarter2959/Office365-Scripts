<#
    .SYNOPSIS
    Gets Bearer Token Via Azure AD Registered App

    .DESCRIPTION
    Returns a Bearer Token when Authenticated with a AzureAD App Credentials to query MS Graph API's

    .PARAMETER TenantID
    Your AzureAD TenantID

    .PARAMETER ClientID
    Your Registered Applications AzureAD ClientID

    .PARAMETER ClientSecret
    Your Registered Applications Client Secret key

    .EXAMPLE
    Get-AzureADBearerToken -TenantID '1234567891' -ClientId '1asfd123bsar123' -ClientSecret '1v1244e/*asd124va/1.4,vsa'
#>
Function Get-AzureADBearerToken ()
    {
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
        $uri = "https://login.microsoftonline.com/$TenantID/oauth2/v2.0/token"

        ####################################
        # Construct Request Body
        $Body = @{
            client_id       = $ClientID
            scope           = "https://graph.microsoft.com/.default"
            client_secret   = $ClientSecret
            grant_type      = "client_credentials"
        }

    Try {
        ####################################
        # Get Token
        $tokenRequest = Invoke-WebRequest -Method Post -Uri $uri -ContentType "application/x-www-form-urlencoded" -Body $Body -UseBasicParsing -ErrorAction Stop

        ####################################
        # Get Token
        $bearerToken = ($tokenRequest.Content | ConvertFrom-Json)
    }
    Catch {
        Write-Warning $Error[0]
    }
    Return $bearerToken
}

<#
    .SYNOPSIS
    Returns Users that are considered a risk within Azure's System

    .DESCRIPTION
    Finds and Returns Users that are flagged in Azure as 'Risky'

    .PARAMETER URI
    Query URI that is wanted to be used

    .PARAMETER BearerToken
    Your Bearer Token Obtained from Get-AzureADBearerToken

    .EXAMPLE
    Get-AzureADRiskDetections -URI 'https://graph.microsoft.com/beta/riskDetections' -BearerToekn '1243efasfd12432g/1245265'
#>
Function Get-AzureADRiskDetections ()
    {
        ####################################
        # Set Parameters
        param (
            [Parameter (Mandatory = $true)]
            [string] $URI,
            [string] $BearerToken
        )

    Try {
        ####################################
        # Set Array List
        $tennantObjects = New-Object System.Collections.Generic.List[object]
        ####################################
        # Run Query
        $query = Invoke-WebRequest -Method "Get" -Uri $URI -ContentType "application/json" -Headers @{Authorization = "Bearer $BearerToken"} -ErrorAction Stop
        ####################################
        # Query Results
        $results = ($query.Content | ConvertFrom-Json)
        ####################################
        # Loop through Results and Add to Array
        foreach ($signin in $results.value)
            {
                # Assign Time Variable to Convert Into Local Time
                $ActivityTime = $signin.activityDateTime
                $ActivityTimeHR = [System.TimeZone]::CurrentTimeZone.ToLocalTime($ActivityTime)
                # Assign Time Variable to Convert Into Local Time
                $DetectedTime = $signin.DetectedDateTime
                $DetectedTimeHR = [System.TimeZone]::CurrentTimeZone.ToLocalTime($DetectedTime)
                # Assign Time Variable to Convert Into Local Time
                $UpdatedTime = $signin.LastUpdatedDateTime
                $UpdatedTimeHR = [System.TimeZone]::CurrentTimeZone.ToLocalTime($UpdatedTime)

                #Add Objects to List
                $tennantObjects.Add(
                    [PSCUSTOMOBJECT] @{
                        ID = $signin.id
                        RequestID = $signin.requestID
                        RiskType = $signin.RiskType
                        RiskEventType = $signin.RiskEventType
                        RiskState = $signin.RiskState
                        RiskLevel = $signin.RiskLevel
                        RiskDetail = $signin.RiskDetail
                        Source=$signin.Source
                        DetectionTimingType = $signin.detectionTimingType
                        Activity = $signin.activity
                        TokenIssuerType = $signin.tokenIssuerType
                        IPAddress = $signin.ipAddress
                        ActivityDateTime = $signin.activityDateTime
                        DetectedDateTime = $signin.DetectedDateTime
                        LastUpdatedDateTime = $signin.LastUpdatedDateTime
                        LocalTimeActivityDateTime = $ActivityTimeHR
                        LocalTimeDetectedDateTime = $DetectedTimeHR
                        LocalTimeLastUpdatedDateTime = $UpdatedTimeHR
                        UserID = $signin.userID
                        DisplayName = $signin.userDisplayName
                        UserPrincipalName = $signin.userPrincipalName
                        Key = $signin.additionalInfo.Key
                        Value = $signin.additionalInfo.Value
                        City = $signin.location.city
                        State = $signin.location.state
                        Country = $signin.location.countryOrRegion
                        GeoCoordinates = $signin.Location.geoCoordinates
                })
            }
        ####################################
        # Create Variable of Results
        $findMore = $results

        ####################################
        # Count How Many
        Write-Host "Found : $($Results.value.count) Records" -BackgroundColor 'DarkYellow' -ForegroundColor 'White'

        ####################################
        # If Results are Paging Loop
        Try {
            
            If ($results.'@odata.nextLink')
                {
                    $findMore.'@odata.nextLink' = $results.'@odata.nextLink'

                    Do
                        {
                            $findMore = Invoke-RestMethod -Method Get -ContentType "application/json" -Headers @{Authorization = "Bearer $BearerToken"} -Uri $findMore.'@odata.nextLink'
                            Write-Host "Found : $($Results.value.count) Records" -BackgroundColor 'DarkYellow' -ForegroundColor 'White'

                            foreach ($signin in $results.value)
                                {
                                    # Assign Time Variable to Convert Into Local Time
                                    $ActivityTime = $signin.activityDateTime
                                    $ActivityTimeHR = [System.TimeZone]::CurrentTimeZone.ToLocalTime($ActivityTime)
                                    # Assign Time Variable to Convert Into Local Time
                                    $DetectedTime = $signin.DetectedDateTime
                                    $DetectedTimeHR = [System.TimeZone]::CurrentTimeZone.ToLocalTime($DetectedTime)
                                    # Assign Time Variable to Convert Into Local Time
                                    $UpdatedTime = $signin.LastUpdatedDateTime
                                    $UpdatedTimeHR = [System.TimeZone]::CurrentTimeZone.ToLocalTime($UpdatedTime)
                                    
                                    #Add Objects to List
                                    $tennantObjects.Add(
                                        [PSCUSTOMOBJECT] @{
                                            ID = $signin.id
                                            RequestID = $signin.requestID
                                            RiskType = $signin.RiskType
                                            RiskEventType = $signin.RiskEventType
                                            RiskState = $signin.RiskState
                                            RiskLevel = $signin.RiskLevel
                                            RiskDetail = $signin.RiskDetail
                                            Source=$signin.Source
                                            DetectionTimingType = $signin.detectionTimingType
                                            Activity = $signin.activity
                                            TokenIssuerType = $signin.tokenIssuerType
                                            IPAddress = $signin.ipAddress
                                            ActivityDateTime = $signin.activityDateTime
                                            DetectedDateTime = $signin.DetectedDateTime
                                            LastUpdatedDateTime = $signin.LastUpdatedDateTime
                                            LocalTimeActivityDateTime = $ActivityTimeHR
                                            LocalTimeDetectedDateTime = $DetectedTimeHR
                                            LocalTimeLastUpdatedDateTime = $UpdatedTimeHR
                                            UserID = $signin.userID
                                            DisplayName = $signin.userDisplayName
                                            UserPrincipalName = $signin.userPrincipalName
                                            Key = $signin.additionalInfo.Key
                                            Value = $signin.additionalInfo.Value
                                            City = $signin.location.city
                                            State = $signin.location.state
                                            Country = $signin.location.countryOrRegion
                                            GeoCoordinates = $signin.Location.geoCoordinates
                                        })
                                }
                        }
                    While
                        ($findMore.'@odata.nextLink')
                }
            }
        Catch
            {
                Write-Warning $Error[0]
            }
    } Catch
        {
            Write-Warning $Error[0]
        }  
    ####################################
    # Set Total Count
    $TotalDetections = ($tennantObjects.Count)
    Write-Host "Current Risk Detections : $($tennantObjects.Count)" -BackgroundColor 'Green' -ForegroundColor 'Black'
    Return $tennantObjects
    }