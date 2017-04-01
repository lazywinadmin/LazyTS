function Append-RichtextboxStatus
{
	PARAM (
		[Parameter(Mandatory = $true)]
		[string]$Message,
		[string]$MessageColor = "DarkGreen",
		[string]$DateTimeColor = "Black",
		[string]$Source,
		[string]$SourceColor = "Gray",
		[string]$ComputerName,
		[String]$ComputerNameColor = "Blue")
	
	$SortableTime = get-date -Format "yyyy-MM-dd HH:mm:ss"
	$richtextboxStatus.SelectionColor = $DateTimeColor
	$richtextboxStatus.AppendText("[$SortableTime] ")
	
	IF ($PSBoundParameters['ComputerName'])
	{
		$richtextboxStatus.SelectionColor = $ComputerNameColor
		$richtextboxStatus.AppendText(("$ComputerName ").ToUpper())
	}
	
	IF ($PSBoundParameters['Source'])
	{
		$richtextboxStatus.SelectionColor = $SourceColor
		$richtextboxStatus.AppendText("$Source ")
	}
	
	$richtextboxStatus.SelectionColor = $MessageColor
	$richtextboxStatus.AppendText("$Message`r")
	$richtextboxStatus.Refresh()
	$richtextboxStatus.ScrollToCaret()
	
	Write-Verbose -Message "$SortableTime $Message"
}