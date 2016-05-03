#---------------------------------------------------------------------------------
# Module FileSystem.psm1
#---------------------------------------------------------------------------------

Function Get-ItemPermissions {
    
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

Function Grant-ItemPermissions {

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
        [String[]]$AccountName,

        [Parameter( Mandatory=$True)]
        [ValidateSet('ListDirectory', 'ReadData', 'WriteData', 'CreateFiles', 'CreateDirectories', 'AppendData' , 'ReadExtendedAttributes', 'WriteExtendedAttributes', 'Traverse', 'ExecuteFile', 'DeleteSubdirectoriesAndFiles', 'ReadAttributes' , 'WriteAttributes', 'Write', 'Delete' , 'ReadPermissions', 'Read', 'ReadAndExecute' , 'Modify', 'ChangePermissions', 'TakeOwnership', 'Synchronize', 'FullControl')]
        [String]$Right
    )

    Begin {
        Write-Verbose "Creating new access Rule(s)"
        $Rule = new-object System.Security.AccessControl.FileSystemAccessRule($AccountName,$Right,"ContainerInherit, ObjectInherit","None","Allow")
        
    }

    Process {
        Foreach ( $I in $Item ) {
            Write-Verbose "Grant-ItemPermission : Granting Permissions for $I"
            $ACL = $I | Get-ACL
      
            $ACL.SetAccessRule($RUle)
          
            $I | Set-ACL -aclObject $ACL
        }
    }
}

#---------------------------------------------------------------------------------

Function Remove-ItemPermissions {

<#
    .Synopsis
        Removes Permissions from an Item

    .Description
        Removes Permissions from an Item

    .Parameter Item
        Item from which to remove permissions.

    .Parameter Path
        Path to the Item from which to remove permissions.

    .Parameter ACE
        Access Control Entry for the permission you want to remove.

    .Example
        $Item | Get-ItemPermission | where IdentityReference -eq stratuslivedemo\jeff.buenting | Remove-ItemPermissions -Item $Item -Verbose

    .Note
        Author: Jeff Buenting
        Date: 2015 DEC 17
        

#>

    [CmdletBinding()]
    Param (
        [Parameter(ParameterSetName='Item',Mandatory=$true)]
        [PSObject]$Item,

        [Parameter(ParameterSetName='Path',Mandatory=$true)]
        [String]$Path,

        [Parameter(Mandatory=$True,ValueFromPipeline=$True)]
        [PSObject[]]$ACE
    )
    
    Process {
        Foreach ( $A in $ACE ) {
            Write-verbose "Removing $($A.IdentityReference)"
            Switch ( $PSCmdlet.ParameterSetName ) {
                'Item' {
                    Write-verbose "     from $($Item.FullName)"
                    $ACL = $Item | Get-ACL   

                    $ACL.Access | Where IdentityReference -eq $A.IdentityReference | Foreach {
                        $ACL.RemoveAccessRule( $_ ) | Out-Null
                    }
                    Set-ACL -Path $Item.FullName -AclObject $ACL                
                }

                'Path' {
                    Write-verbose "     from $Path"
                    $ACL = Get-ACL -Path $Path  
                    $ACL.Access | Where IdentityReference -eq $A.IdentityReference | Foreach {
                        $ACL.RemoveAccessRule( $_ ) | Out-Null
                    }
                    Set-ACL -Path $Path -AclObject $ACL
                }
            }                   
        }
    }
}

#---------------------------------------------------------------------------------

Function Set-ItemOwnership {

<#
    .Synopsis
        Takes Ownership of an Item

    .Description
        Takes Ownership of a File or Folder

    .Parameter Item
        File or folder of which to take ownership.

    .Parameter Account
        Account to set ownership

    .Example
        Get-Item c:\temp | Set-ItemOwnership -Account 'MyDomain\Steve.Baker'

    .Link
        http://blogs.technet.com/b/heyscriptingguy/archive/2008/04/15/how-can-i-use-windows-powershell-to-determine-the-owner-of-a-file.aspx

    .Note
        Must run as admin on machine where the file is located

    .Note
        Author: Jeff Buenting
        Note: 2015 DEC 02
#>

    [CmdletBinding()]
    Param (
        [Parameter(ValueFromPipeline=$True)]
        [PSObject[]]$Item,

        [String]$Account
    )

    Begin {
        Write-verbose "Getting User object for $Account"
        $UserInfo = $Account -split "\\"
        $User = New-Object System.Security.Principal.NTAccount($UserInfo[0],$UserInfo[1])

    }

    Process {
        Foreach ( $I in $Item ) {
            Write-verbose "Taking Ownership of $($I.FullName)"
            $File = Get-ACL $I
            $File.SetOwner( $User )
            Set-ACL -AclObject $File -Path $I.FullName
        }
    }
}

#---------------------------------------------------------------------------------

Function Set-ItemInheritance  {

<#
    .Synopsis
        Sets an Items Permision Inheritance.

    .Description
        Blocks or allows an Items Inheritance.  Also keeps or wipes out the existing permissions.

    .Parameter Item
        Item to set inheritance.

    .Parameter Block
        If set, Blocks the inheritance to an item.

    .Parameter KeepACE
        If True then the existing permissions will be kept.
        
    .Example
        Blocks Inheritance and keeps the existing permissions
        
        get-Item c:\work\stuff | Set-ItemInheritance -Block -KeepACE -verbose
    
    .Link
        http://www.millercode.com/?p=16

    .Link
        https://www.petri.com/identify-folders-with-blocked-inheritance-using-powershell

    .Note
        Author: Jeff Buenting
        Date: 2015 DEC 17
        
#>


    [CmdletBinding(DefaultParameterSetName = 'Item')]
    Param (
        [Parameter(ParameterSetName='Item',Mandatory=$true,ValueFromPipeline=$true)]
        [PsObject[]]$Item,

        [Parameter(ParameterSetName='Path',Mandatory=$true,ValueFromPipeline=$true)]
        [String[]]$Path,

        [Parameter(ParameterSetName='Path')]
        [Parameter(ParameterSetName='Item')]
        [Switch]$Block,

        [Parameter(ParameterSetName='Path')]
        [Parameter(ParameterSetName='Item')]
        [Switch]$KeepACE
    )

    Process {
        Switch ( $PSCmdlet.ParameterSetName ) {
            'Item' {
                Foreach ( $I in $Item ) {
                    Write-verbose "Setting Inheritance for $($I.FullName)"
                    Write-verbose "     To Block = $Block; KeepACE = $KeepACE"
                    $ACL = $I | Get-Acl

                    $ACL.SetAccessRuleProtection($Block,$KeepACE)

                    Set-Acl -Path $I.FullName -AclObject $ACL
                }
            }

            'Path' {
                Foreach ( $P in $Path ) {
                    Write-verbose "Setting Inheritance for $P"
                    Write-verbose "     To Block = $Block; KeepACE = $KeepACE"
                    $ACL = Get-Acl -Path $P

                    $ACL.SetAccessRuleProtection($Block,$KeepACE)

                    Set-Acl -Path $P -AclObject $ACL
                }
            }
        }
    }
}