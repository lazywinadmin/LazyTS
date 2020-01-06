function Reset-TextBox
{
	[CmdletBinding()]
	PARAM (
		[System.Windows.Forms.TextBox]$TextBox,
		[System.Drawing.Color]$BackColor = "White",
		[System.Drawing.Color]$ForeColor = "Black"
	)
	BEGIN { }
	PROCESS
	{
		TRY
		{
			$TextBox.Text = ""
			$TextBox.BackColor = $BackColor
			$TextBox.ForeColor = $ForeColor
		}
		CATCH { }
	}
}