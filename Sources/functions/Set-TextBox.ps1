function Set-TextBox
{
	[CmdletBinding()]
	PARAM (
		[System.Windows.Forms.TextBox]$TextBox,
		[System.Drawing.Color]$BackColor
	)
	BEGIN { }
	PROCESS
	{
		TRY
		{
			$TextBox.BackColor = $BackColor
		}
		CATCH { }
	}
}