<#
.SYNOPSIS
    Finds and Removes Direct Assigned Licenses
.DESCRIPTION
    Finds Direct Assigned Licenses Attached to Licensing Groups and Removes
.REVISION 
    3.0
.UPDATED
    3.0 - Ready For Production
    2.0 - Fixed Syntax and Errors and Wrote In Instructions
    1.0 - Creation
.Author
    Name       : MrCarter2959
.Steps
    1 - Run lines 29 - 81 to find all users who have a direct assigned license
    2 - Run lines 96 - 142 to remove all direct assigned licenses that are a member of a licensing group. I export the changes stored in the array. As you can re-import the CSV and re-assigned the licenses if error's arrise, or need to quickly revert the changes that were made
    3 - Not Written Yet, Find users with a direct assigned, find them in AD, eveulate what group they should be a member of, and add them to licensing group, then remove the direct assigned license
#>

#--------------------------------------------------------------#
#
#                            STEP 1
#
#--------------------------------------------------------------#

#--------------------------------------------------------------#
# Connect to AzureAD
#--------------------------------------------------------------#
Connect-MsolService

#--------------------------------------------------------------#
# Setup Array's For Reporting
#--------------------------------------------------------------#
$directLicenseAssignmentReport = @()
$directLicenseAssignmentCount = 0
$perDirect2 = @()

#--------------------------------------------------------------#
# Find all our users who are 'Licensed' and Not a Device
#--------------------------------------------------------------#
$allUsers = Get-MsolUser -All -ErrorAction Stop | Where {($_.isLicensed -eq 'True') -and ($_.UserPrincipalName -notmatch "_Device*")}

#--------------------------------------------------------------#
# Loop over each user in $allUsers
#--------------------------------------------------------------#
foreach ($user in $allUsers){
    #--------------------------------------------------------------#
    # Processing all licenses per user  
    #--------------------------------------------------------------#     
        foreach ($license in $user.Licenses){
        <#
            the "GroupsAssigningLicense" array contains objectId's of groups which inherit licenses
            if the array contains an entry with the users own objectId the license was assigned directly to the user
            if the array contains no entries and the user has a license assigned he also got a direct license assignment
        #>
        if ($license.GroupsAssigningLicense -contains $user.ObjectId -or $license.GroupsAssigningLicense.Count -lt 1){
            #--------------------------------------------------------------#
            # Count
            #--------------------------------------------------------------#
            $directLicenseAssignmentCount++
            
            #--------------------------------------------------------------#
            # Write To Console, what we found
            #--------------------------------------------------------------#
            Write-Host "User $($user.UserPrincipalName) ($($user.ObjectId)) has direct license assignment for sku '$($license.AccountSkuId)')"
            #--------------------------------------------------------------#
            # Add details to the report
            #--------------------------------------------------------------#
            $directLicenseAssignmentReport += [PSCustomObject]@{
                UserPrincipalName = $user.UserPrincipalName
                ObjectId = $user.ObjectId
                AccountSkuId = $license.AccountSkuId
                DirectAssignment = $true
            }
        }
    }
}
#--------------------------------------------------------------#
# Write To Console, how many direct assigned licenses we have
#--------------------------------------------------------------#
Write-Host "Total Direct Assigned Licenses Found: $($directLicenseAssignmentCount)" -BackgroundColor "Yellow" -ForegroundColor "Black"


#--------------------------------------------------------------#
#
#                            STEP 2
#
#--------------------------------------------------------------#



#--------------------------------------------------------------#
# Loop through Each Direct Assigned, and Pull AD Group Membership
# If a member of our Licensing Group, Remove it, Log it
#--------------------------------------------------------------#
foreach ($user in $directLicenseAssignmentReport) {
   #--------------------------------------------------------------------#
   # Find our AD User (Setting the Varaible to NULL, helped with accounts
   # that werent found in AD and needed the variable to be null to process
   # correctly)
   #--------------------------------------------------------------#
   $licenseGroup = ''
   $licenseGroup = Get-ADUser -Identity $($user.UserPrincipalName.Split("@")[0]) -Properties memberOf | Select -ExpandProperty memberOf
   
   #--------------------------------------------------------------------#
   # Grabs Users that are a member of our Licensing Group
   #--------------------------------------------------------------------#
   $licenseGroup3 = ''
   $licenseGroup3 = $licenseGroup | Where {($_ -match "Licensing_Group_samAccountName")}

   #--------------------------------------------------------------------#
   # If the user is a member and has a Direct Assigned, Remove
   #--------------------------------------------------------------------#
   if ($licenseGroup -and $licenseGroup3 -and ($user.DirectAssignment -eq 'True')) {
        #---------------------------------------------------------------#
        # Write To Console, Membership Values
        Write-host "$($user.UserPrincipalName.Split("@")[0]) ($($user.ObjectId)) is a memberOf $licenseGroup3"
        Write-Host "AND"
        Write-Host "Has $($user.AccountSkuId) direct assignment is $($user.DirectAssignment)"
        Write-host "-----------------------------------------------------------------------"
        #---------------------------------------------------------------#
        # Add To Array For Export
        #---------------------------------------------------------------#
        $perDirect2 += [PSCustomObject]@{
            UserPrincipalName = $user.UserPrincipalName
            UserObjectID = $user.ObjectId
            GroupLicense = $licenseGroup3
            DirectLicense = $user.DirectAssignment
            DirectAssignedSKU = $user.AccountSkuId
            ActionTaken = "Removed: Direct Assigned - $($user.AccountSkuId)"
        }
        #---------------------------------------------------------------#
        # Remove the SKU
        #---------------------------------------------------------------#
        Set-MsolUserLicense -ObjectId $user.ObjectId -RemoveLicenses $user.AccountSkuId -Verbose
    }       
}

#--------------------------------------------------------------------#
# Export Action Report
#--------------------------------------------------------------------#
$perDirect2 | Export-CSV -Path "Some_Path_To_Export_The_Array_To.csv" -NoTypeInformation -Encoding ASCII
