Function Grant-ItemPermission {

<#
    
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
        $Rule
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

get-item c:\temp | Grant-ItemPermission -AccountName "stratuslivedemo\jeffbtest" -Right Read