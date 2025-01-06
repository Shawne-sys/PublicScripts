# Check and import the Exchange Online Management module
if (-not (Get-Module -ListAvailable -Name ExchangeOnlineManagement)) {
    Install-Module -Name ExchangeOnlineManagement -Scope CurrentUser -Force
}

Import-Module ExchangeOnlineManagement

# Ensure connected to Exchange Online
if (-not (Get-Command Connect-ExchangeOnline -ErrorAction SilentlyContinue)) {
    Write-Host "Exchange Online Management module is not available. Please install it first."
    exit
}

# Function to grant delegate calendar permissions
function Grant-CalendarAccess {
    param (
        [string]$targetMailbox,
        [string]$delegateEmail
    )

    # Construct the calendar identity
    $calendarIdentity = "$targetMailbox\Calendar"

    # Grant delegate calendar permissions
    try {
        Add-MailboxFolderPermission -Identity $calendarIdentity -User $delegateEmail -AccessRights Editor
        Write-Host "Successfully granted delegate access to $targetMailbox's calendar for $delegateEmail."
    } catch {
        Write-Host "Failed to grant delegate access to the calendar: $_"
    }
}

# Prompt user for input
try {
    $targetMailbox = Read-Host "Enter the email address of the mailbox to which you want to grant calendar access"
    if (-not $targetMailbox) { throw "Target mailbox email address cannot be empty." }

    $delegateEmail = Read-Host "Enter the email address of the user who needs delegate calendar access"
    if (-not $delegateEmail) { throw "Delegate email address cannot be empty." }

    # Connect to Exchange Online if not already connected
    if (-not (Get-PSSession | Where-Object { $_.ConfigurationName -eq 'Microsoft.Exchange' })) {
        Connect-ExchangeOnline -UserPrincipalName (Get-Credential).UserName -ShowProgress $true
    }

    # Call the function to grant calendar access
    Grant-CalendarAccess -targetMailbox $targetMailbox -delegateEmail $delegateEmail
} catch {
    Write-Host "An error occurred: $_"
}

