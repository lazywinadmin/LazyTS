function New-MessageBox
{
<#
	.SYNOPSIS
		The New-MessageBox functio will show a message box to the user
	
	.DESCRIPTION
		The New-MessageBox functio will show a message box to the user
	
	.PARAMETER Message
		Specifies the message to show
	
	.PARAMETER Title
		Specifies the title of the message box
	
	.PARAMETER Buttons
		Specifies which button to add. Just press tab to see the choices
	
	.PARAMETER Icon
		Specifies the icon to show. Just press tab to see the choices
	
	.EXAMPLE
		PS C:\> New-MessageBox -Message "Hello World" -Title "First Message" -Buttons "RetryCancel" -Icon "Asterix"
	
	.NOTES
		Author: Francois-Xavier Cat
		Twitter:@LazyWinAdm
		WWW: 	lazywinadmin.com
#>
	[CmdletBinding()]
	PARAM (
		
		[String]$Message,
		[String]$Title,
		[System.Windows.Forms.MessageBoxButtons]$Buttons = "OK",
		[System.Windows.Forms.MessageBoxIcon]$Icon = "None"
	)
	BEGIN
	{
		Add-Type -AssemblyName System.Windows.Forms
	}
	PROCESS
	{
		[System.Windows.Forms.MessageBox]::Show($Message, $Title, $Buttons, $Icon)
	}
} #New-MessageBox