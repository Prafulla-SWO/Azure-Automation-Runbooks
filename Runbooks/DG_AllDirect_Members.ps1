#Get all users from the recursive DL _SWO_ALL

Connect-ExchangeOnline

$Visited = @{}

function Expand-DL {
    param([string]$DL)

    if ($Visited.ContainsKey($DL.ToLower())) {
        return
    }

    $Visited[$DL.ToLower()] = $true

    Get-DistributionGroupMember -Identity $DL -ResultSize Unlimited | ForEach-Object {

        if ($_.RecipientType -in @("MailUniversalDistributionGroup","MailUniversalSecurityGroup")) {
            Expand-DL $_.PrimarySmtpAddress
        }
        elseif ($_.RecipientType -in @("UserMailbox","RemoteUserMailbox","MailUser")) {
            [PSCustomObject]@{
                UPN          = $_.WindowsLiveID
                EmailAddress = $_.PrimarySmtpAddress
            }
        }
    }
}

$Results = Expand-DL "_SWO_ALL@softwareone.com" |
    Sort-Object UPN -Unique

