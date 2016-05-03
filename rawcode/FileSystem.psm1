#---------------------------------------------------------------------------------
# Module FileSystem.psm1
#---------------------------------------------------------------------------------

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

#---------------------------------------------------------------------------------

Function Grant-ItemPermission {

<#
    .Synopsis
        Sets permissions on an item

    .Descriptions
        Sets permissions on an item.

    .Parameter Item
        Item on which to set permissions.

    .Parameter AccountName
        Domain\Name of the user or group.

    .Parameter Right
        Right Assigning to Account        

    .Link
        https://technet.microsoft.com/en-us/magazine/2008.02.powershell.aspx

    .Link
        https://social.technet.microsoft.com/Forums/en-US/634e6ec0-c6fc-467d-bef4-2be5c5296641/setacl-fails-in-v3?forum=winserverpowershell
#>

    [CmdletBinding()]
    param (
        [Parameter( Mandatory=$True,ValueFromPipeline=$True )]
        [PSObject[]]$Item,

        [Parameter( Mandatory=$True)]
        [String]$AccountName,

        [Parameter( Mandatory=$True)]
        [ValidateSet('ListDirectory', 'ReadData', 'WriteData', 'CreateFiles', 'CreateDirectories', 'AppendData' , 'ReadExtendedAttributes', 'WriteExtendedAttributes', 'Traverse', 'ExecuteFile', 'DeleteSubdirectoriesAndFiles', 'ReadAttributes' , 'WriteAttributes', 'Write', 'Delete' , 'ReadPermissions', 'Read', 'ReadAndExecute' , 'Modify', 'ChangePermissions', 'TakeOwnership', 'Synchronize', 'FullControl')]
        [String]$Right
    )

    Begin {
        Write-Verbose "Creating new access Rule"
        $rule=new-object System.Security.AccessControl.FileSystemAccessRule($AccountName,$Right,"Allow")
        
    }

    Process {
        Foreach ( $I in $Item ) {
            Write-Verbose "Granting Permissions for $I"
            $ACL = $I | Get-ACL
            $ACL.SetAccessRule($Rule)
            $I | Set-ACL -aclObject $ACL
        }
    }
}