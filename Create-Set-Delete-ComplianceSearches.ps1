Function Connect-Compliance {
    
    #User Login
    $Login_Credentials = Get-Credential

    #Exchange URL
    $Compliance_URI = "https://ps.compliance.protection.outlook.com/powershell-liveid/"

    #Config Name
    $Configuration_Name = "Microsoft.Exchange"

    #Authentication
    $Authentication = "Basic"

    #Start The Session
    $Compliance_Session = New-PSSession -ConfigurationName $Configuration_Name -ConnectionUri $Compliance_URI -Authentication $Authentication -Credential $Login_Credentials -AllowRedirection

    #Import The Session
    Import-PSSession $Exchange_Session -DisableNameChecking -AllowClobber
    }

    $ComplianceDate = Get-Date -Format "MM-dd-yyyy"

    Connect-Compliance

    $ComplianceSearch_Name = "Enter Search Name Here "+$ComplianceDate

    #Run This to Create a New Compliance Search
    New-ComplianceSearch -Name $ComplianceSearch_Name -ExchangeLocation All -ContentMatchQuery 'sent>=09/05/2019 AND subject:"subject_line" AND from:"sender"' -Description "Enter Description Of Query Here" -verbose

    #Run This to Start the Compliance Search Created from Line 29
    Start-ComplianceSearch -Identity $ComplianceSearch_Name -verbose

    #Run This to See the Compliance Search Status from Line 32
    Get-ComplianceSearch -Identity $ComplianceSearch_Name -verbose | Format-List 

    #Run this to see The number of Matches to the Compliance Search from Line 35
    Get-ComplianceSearch -Identity $ComplianceSearch_Name -verbose | Select Items

    #Run This to Delete the Messages Held within the Compliance Search from Lines 29 and 32
    New-ComplianceSearchAction -SearchName $ComplianceSearch_Name -Purge -PurgeType SoftDelete -Verbose

    #Run This to See the Status of the Soft Delete Purge from line 41
    Get-ComplianceSearchAction -Identity "$ComplianceSearch_Name Spam_Purge" | Format-List
