function Clear-DataGridViewSelection
{
	PARAM (
		[Parameter(Mandatory = $true)]
		[System.Windows.Forms.DataGridView]$DataGridView
	)
	$DataGridView.ClearSelection()
}