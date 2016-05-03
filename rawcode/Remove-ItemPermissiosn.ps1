Import-Module 'F:\OneDrive - StratusLIVE, LLC\Scripts\Modules\FileSystem\FileSystem.psm1'

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
                    $ACL.RemoveAccessRule( ( $ACL.GetAccessRules($true, $true, [System.Security.Principal.NTAccount]) | Where IdentityReference -eq $A.IdentityReference ) )
                    Set-ACL -Path $Item.FullName -AclObject $ACL                
                }

                'Path' {
                    Write-verbose "     from $Path"
                    $ACL = Get-ACL -Path $Path  
                    $ACL.RemoveAccessRule( ( $ACL.GetAccessRules($true, $true, [System.Security.Principal.NTAccount]) | Where IdentityReference -eq $A.IdentityReference ) )
                    Set-ACL -Path $Path -AclObject $ACL
                }
            }                   
        }
    }
}

$Item = Get-item c:\work\stuff 

$Item | Get-ItemPermissions | where IdentityReference -eq stratuslivedemo\jeff.buenting | Remove-ItemPermissions -Item $Item -Verbose

