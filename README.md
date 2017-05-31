# FileSystem
Windows File System Powershell Module for WIndows FileSystem.

### Version
- **1.2** -- Fixed a bug with Grant-ItemPermissions

### Functions
- **Get-ItemPermissions** 
  - Gets an Items ACL List of Permissions
  
  - **`[PSObject[]]`Item** (_Mandatory_): Item from which to get permissions
  
- **Grant-ItemPermissions**
  - Sets permissions on an Item
  
  - **`[PSObject[]]`Item** (_Mandatory_): Item from which to set permissions
  - **`[String[]]`AccountName** (_Mandatory_): Domain\UserName of the user or group.
  - **`[String]`Right** (_Mandatory_): Right Assigning to Account  
  
- **Remove-ItemPermissions**
 - Removes Permissions from an Item
 
 - **`[PSObject[]]`Item** (_Mandatory_): Item from which to Remove permissions
 
- **Set-ItemOwnership**
  - Sets ownership of an item.
  
  - **`[PSObject[]]`Item** (_Mandatory_): Item from which to get permissions
  - **`[String]`Account** : Account to set ownership
  
- **Set-ItemInheritance**
  - Sets an Items Permision Inheritance.
  
- **Get-FileorFolderPath**
  - Opens a GUI window to allow browsing to a folder or file.
  
  - **`[String]`InitialDirectory** (_Mandatory_)
  
- **Get-Folder**
  
