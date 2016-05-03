Function Get-ItemPermission {
    
<#
    .Synopsis
        Gets an Items ACL List.

    .Description
        Gets an items ACL List of permissions

    .Parameter Item
        Item from which to get permissions

    .Example
        get permissions for c:\temp

        Get-item c:\temp | Get-ItemAccess 

    .Link
        http://blogs.technet.com/b/josebda/archive/2010/11/12/how-to-handle-ntfs-folder-permissions-security-descriptors-and-acls-in-powershell.aspx

    .Note
        Author: Jeff Buenting
        Date: 2015 DEC 1
#>

    [CmdletBinding()]
    param (
        [Parameter( ValueFromPipeline=$True )]
        [PSObject[]]$Item
    )

    Process {
        Foreach ( $I in $Item ) {
            Write-Verbose "Getting Permissions for $I"
            Write-Output ($I | Get-Acl).GetAccessRules($true, $true, [System.Security.Principal.NTAccount])
        }
    }
}

Get-item c:\temp | Get-ItemAccess 