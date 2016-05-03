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

    .Link
        Cmdlet Parameter Sets

        https://msdn.microsoft.com/en-us/library/dd878348(v=vs.85).aspx

    .Note
        Must run as admin on machine where the file is located

    .Note
        Author: Jeff Buenting
        Note: 2015 DEC 02
#>

    [CmdletBinding()]
    Param (
        [Parameter(ParameterSetName='Item',Mandatory=$True)]
        [psobject[]]$Item,

        [Parameter(ParameterSetName='Path',Mandatory=$True)]
        [String[]]$Path,

        [Parameter(Mandatory=$True)]
        [String]$Account
    )

    Begin {
        Write-verbose "Getting User object for $Account"
        $UserInfo = $Account -split "\\"
        $User = New-Object System.Security.Principal.NTAccount($UserInfo[0],$UserInfo[1])

    }

    Process {
        Switch ($PSCmdlet.ParameterSetName) {
            'Path' {
                Write-Verbose "Path Parameter Specified"
                ForEach ( $P in $Path ) {
                    Write-verbose "Taking Ownership of $Path"
                    $File = Get-ACL -Path $P
                    $File.SetOwner( $User )
                    Set-ACL -AclObject $File -Path $P
                }
            }
            'Item' {
                Write-Verbose "Item parameter Specified"
                Foreach ( $I in $Item ) {
                    Write-verbose "Taking Ownership of $($I.FullName)"
                    $File = Get-ACL $I
                    $File.SetOwner( $User )
                    Set-ACL -AclObject $File -Path $I.FullName | Out-Null
                }
            }
            
        }
    }
}

Set-ItemOwnership -Path c:\temp -Account 'stratuslivedemo\jeff.buenting' -Verbose