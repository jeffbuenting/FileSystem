Function Set-ItemInheritance {

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


    [CmdletBinding()]
    Param (
        [Parameter(ParameterSetName='Item',Mandatory=$true,ValueFromPipeline=$true)]
        [PsObject[]]$Item,

        [Parameter(ParameterSetName='Path',Mandatory=$true,ValueFromPipeline=$true)]
        [String[]]$Path,

        [Switch]$Block,

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

get-Item c:\work\stuff | Set-ItemInheritance -KeepACE -verbose