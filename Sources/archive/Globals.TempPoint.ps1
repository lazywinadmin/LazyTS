#requires -version 3

#--------------------------------------------
# Declare Global Variables and Functions here
#--------------------------------------------

#Location of the script
function Get-ScriptDirectory
{ 
	if($hostinvocation -ne $null)
	{
		Split-Path $hostinvocation.MyCommand.path
	}
	else
	{
		Split-Path $script:MyInvocation.MyCommand.Path
	}
}

[string]$ScriptDirectory = Get-ScriptDirectory


# Load Configuration
$configurationpath = Join-Path -Path $ScriptDirectory -ChildPath 'config.psd1'
if(-not(Test-Path $configurationpath)){Write-Warning -message "can't retrieve the configuration file 'config.psd1'"}
$Configuration= Import-LocalizedData -BaseDirectory (Get-ScriptDirectory) -FileName "config.psd1"

# PSTerminalServices Module Requirements
# Get the path of the DLL file: Cassia.dll (.net library)
$CassiaPath = Join-Path -Path (Get-ScriptDirectory) -ChildPath "Cassia.dll"
# Load the DLL
if (-not(Test-Path $CassiaPath)){Write-Warning -Message "The file Cassia.dll is missing. The Script can't continue without this file";exit}
[Reflection.Assembly]::LoadFile($CassiaPath) | Out-Null

# Import all the helper functions
$functionpath = Join-Path -Path $ScriptDirectory -child "functions"
$script:Server = 'localhost'
foreach ($file in (Get-ChildItem -path $functionpath))
{
	. $file.fullname
}



#
## From WinFormPS
#function Append-RichtextboxStatus{
#	PARAM(
#	[Parameter(Mandatory=$true)]
#	[string]$Message,
#	[string]$MessageColor = "DarkGreen",
#	[string]$DateTimeColor="Black",
#	[string]$Source,
#	[string]$SourceColor="Gray",
#	[string]$ComputerName,
#	[String]$ComputerNameColor= "Blue")
#	
#	$SortableTime = get-date -Format "yyyy-MM-dd HH:mm:ss"
#	$richtextboxStatus.SelectionColor = $DateTimeColor
#	$richtextboxStatus.AppendText("[$SortableTime] ")
#	
#	IF ($PSBoundParameters['ComputerName']){
#		$richtextboxStatus.SelectionColor = $ComputerNameColor
#		$richtextboxStatus.AppendText(("$ComputerName ").ToUpper())
#	}
#	
#	IF ($PSBoundParameters['Source']){
#		$richtextboxStatus.SelectionColor = $SourceColor
#		$richtextboxStatus.AppendText("$Source ")
#	}
#	
#	$richtextboxStatus.SelectionColor = $MessageColor
#	$richtextboxStatus.AppendText("$Message`r")
#	$richtextboxStatus.Refresh()
#	$richtextboxStatus.ScrollToCaret()
#	
#	Write-Verbose -Message "$SortableTime $Message"
#}
#
#function Set-DataGridView
#{
#	<#
#		.SYNOPSIS
#			This function helps you edit the datagridview control
#	
#		.DESCRIPTION
#			This function helps you edit the datagridview control
#	
#		.EXAMPLE
#			Set-DataGridView -DataGridView $datagridview1 -ProperFormat -FontFamily $listboxFontFamily.Text -FontSize $listboxFontSize.Text
#	
#		.EXAMPLE
#			Set-DataGridView -DataGridView $datagridview1 -AlternativeRowColor -BackColor 'AliceBlue' -ForeColor 'Black'
#	
#		.EXAMPLE
#			Set-DataGridViewRowHeader -DataGridView $datagridview1 -HideRowHeader
#	
#		.EXAMPLE
#			Set-DataGridViewRowHeader -DataGridView $datagridview1 -ShowRowHeader
#	
#		.NOTES
#			Author: Francois-Xavier Cat
#			Twitter:@LazyWinAdm
#			WWW: 	lazywinadmin.com
#	#>
#	
#	[CmdletBinding()]
#	PARAM (
#		[ValidateNotNull()]
#		[Parameter(Mandatory = $true)]
#		[System.Windows.Forms.DataGridView]$DataGridView,
#		
#		[Parameter(Mandatory = $true, ParameterSetName = "AlternativeRowColor")]
#		[Switch]$AlternativeRowColor,
#		
#		[Parameter(ParameterSetName = "DefaultRowColor")]
#		[Switch]$DefaultRowColor,
#		
#		[Parameter(Mandatory = $true, ParameterSetName = "AlternativeRowColor")]
#		[Parameter(ParameterSetName = "DefaultRowColor")]
#		[System.Drawing.Color]$ForeColor,
#		
#		[Parameter(Mandatory = $true, ParameterSetName = "AlternativeRowColor")]
#		[Parameter(ParameterSetName = "DefaultRowColor")]
#		[System.Drawing.Color]$BackColor,
#		
#		[Parameter(Mandatory = $true, ParameterSetName = "Proper")]
#		[Switch]$ProperFormat,
#		
#		[Parameter(ParameterSetName = "Proper")]
#		[String]$FontFamily = "Consolas",
#		
#		[Parameter(ParameterSetName = "Proper")]
#		[Int]$FontSize = 10,
#		
#		[Parameter(ParameterSetName = "HideRowHeader")]
#		[Switch]$HideRowHeader,
#		[Parameter(ParameterSetName = "ShowRowHeader")]
#		[Switch]$ShowRowHeader
#	)
#	PROCESS
#	{
#		if ($psboundparameters['AlternativeRowColor'])
#		{
#			$DataGridView.AlternatingRowsDefaultCellStyle.ForeColor = $ForeColor
#			$DataGridView.AlternatingRowsDefaultCellStyle.BackColor = $BackColor
#		}
#		
#		if ($psboundparameters['DefaultRowColor'])
#		{
#			$DataGridView.RowsDefaultCellStyle.ForeColor = $ForeColor
#			$DataGridView.RowsDefaultCellStyle.BackColor = $BackColor
#		}
#		
#		
#		if ($psboundparameters['ProperFormat'])
#		{
#			#$Font = New-Object -TypeName System.Drawing.Font -ArgumentList "Segoi UI", 10
#			$Font = New-Object -TypeName System.Drawing.Font -ArgumentList $FontFamily, $FontSize
#			
#			#[System.Drawing.FontStyle]::Bold
#			
#			$DataGridView.ColumnHeadersBorderStyle = 'Raised'
#			$DataGridView.BorderStyle = 'Fixed3D'
#			$DataGridView.SelectionMode = 'FullRowSelect'
#			$DataGridView.AllowUserToResizeRows = $false
#			$datagridview.DefaultCellStyle.font = $Font
#		}
#		
#		if ($psboundparameters['HideRowHeader'])
#		{
#			$DataGridView.RowHeadersVisible = $false
#		}
#		if ($psboundparameters['ShowRowHeader'])
#		{
#			$DataGridView.RowHeadersVisible = $true
#		}
#	}
#	
#}#Set-DataGridView
#
#function Reset-DataGridViewFormat
#{
#<#
#	.SYNOPSIS
#		The Reset-DataGridViewFormat function will reset the format of a datagridview control
#	
#	.DESCRIPTION
#		The Reset-DataGridViewFormat function will reset the format of a datagridview control
#	
#	.PARAMETER DataGridView
#		Specifies the DataGridView Control.
#	
#	.EXAMPLE
#		PS C:\> Reset-DataGridViewFormat -DataGridView $DataGridViewObj
#	
#	.NOTES
#		Author: Francois-Xavier Cat
#		Twitter:@LazyWinAdm
#		WWW: 	lazywinadmin.com
##>
#	[CmdletBinding()]
#	PARAM (
#		[Parameter(Mandatory = $true)]
#		[System.Windows.Forms.DataGridView]$DataGridView)
#	PROCESS
#	{
#		$DataSource = $DataGridView.DataSource
#		$DataGridView.DataSource = $null
#		$DataGridView.DataSource = $DataSource
#		
#		#$DataGridView.RowsDefaultCellStyle.BackColor = 'White'
#		#$DataGridView.RowsDefaultCellStyle.ForeColor = 'Black'
#		$DataGridView.RowsDefaultCellStyle = $null
#		$DataGridView.AlternatingRowsDefaultCellStyle = $null
#	}
#}#Reset-DataGridViewFormat
#
#function Find-DataGridViewValue
#{
#<#
#	.SYNOPSIS
#		The Find-DataGridViewValue function helps you to find a specific value and select the cell, row or to set a fore and back color.
#	
#	.DESCRIPTION
#		The Find-DataGridViewValue function helps you to find a specific value and select the cell, row or to set a fore and back color.
#	
#	.PARAMETER DataGridView
#		Specifies the DataGridView Control to use
#	
#	.PARAMETER RowBackColor
#		Specifies the back color of the row to use
#	
#	.PARAMETER RowForeColor
#		Specifies the fore color of the row to use
#	
#	.PARAMETER SelectCell
#		Specifies to select only the cell when the value is found
#	
#	.PARAMETER SelectRow
#		Specifies to select the entire row when the value is found
#	
#	.PARAMETER Value
#		Specifies the value to search
#	
#	.EXAMPLE
#		PS C:\> Find-DataGridViewValue -DataGridView $datagridview1 -Value $textbox1.Text
#	
#		This will find the value and select the cell(s)
#	
#	.EXAMPLE
#		PS C:\> Find-DataGridViewValue -DataGridView $datagridview1 -Value $textbox1.Text -RowForeColor 'Red' -RowBackColor 'Black'
#	
#		This will find the value and color the fore and back of the row
#	.EXAMPLE
#		PS C:\> Find-DataGridViewValue -DataGridView $datagridview1 -Value $textbox1.Text -SelectRow
#	
#		This will find the value and select the entire row
#	
#	.NOTES
#		Francois-Xavier Cat
#		@lazywinadm
#		www.lazywinadmin.com
##>
#	[CmdletBinding(DefaultParameterSetName = "Cell")]
#	PARAM (
#		[Parameter(Mandatory = $true)]
#		[System.Windows.Forms.DataGridView]$DataGridView,
#		
#	[ValidateNotNull()]	
#	[Parameter(Mandatory = $true)]
#		[String]$Value,
#		[Parameter(ParameterSetName = "Cell")]
#		[Switch]$SelectCell,
#		
#		[Parameter(ParameterSetName = "Row")]
#		[Switch]$SelectRow,
#		
#		#[Parameter(ParameterSetName = "Column")]
#		#[Switch]$SelectColumn,
#		[Parameter(ParameterSetName = "RowColor")]
#		[system.Drawing.Color]$RowForeColor,
#		[Parameter(ParameterSetName = "RowColor")]
#		[system.Drawing.Color]$RowBackColor
#	)
#	
#	PROCESS
#	{
#		$DataGridView.ClearSelection()
#		
#		FOR ([int]$i = 0; $i -lt $DataGridView.RowCount; $i++)
#		{
#			FOR ([int] $j = 0; $j -lt $DataGridView.ColumnCount; $j++)
#			{
#				$CurrentCell = $dataGridView.Rows[$i].Cells[$j]
#				
#				#if ((-not $CurrentCell.Value.Equals([DBNull]::Value)) -and ($CurrentCell.Value.ToString() -like "*$Value*"))
#				if ($CurrentCell.Value.ToString() -match $Value)
#				{
#					
#					# Row Selection
#					IF ($PSBoundParameters['SelectRow'])
#					{
#						$dataGridView.Rows[$i].Selected = $true
#					}
#					
#					<#
#					# Column Selection
#					IF ($PSBoundParameters['SelectColumn'])
#					{
#						#$DataGridView.Columns[$($CurrentCell.ColumnIndex)].Selected = $true
#						#$DataGridView.Columns[$j].Selected = $true
#						#$CurrentCell.DataGridView.Columns[$j].Selected = $true
#					}
#					#>
#					
#					# Row Fore Color
#					IF ($PSBoundParameters['RowForeColor'])
#					{
#						$dataGridView.Rows[$i].DefaultCellStyle.ForeColor = $RowForeColor
#					}
#					# Row Back Color
#					IF ($PSBoundParameters['RowBackColor'])
#					{
#						$dataGridView.Rows[$i].DefaultCellStyle.BackColor = $RowBackColor
#					}
#					
#					# Cell Selection
#					ELSEIF (-not ($PSBoundParameters['SelectRow']) -and -not ($PSBoundParameters['SelectColumn']))
#					{
#						$CurrentCell.Selected = $true
#					}
#				}#IF not empty and contains value
#			}#For Each column
#		}#For Each Row
#	}#PROCESS
#}#Find-DataGridViewValue
#
#function Set-DataGridViewFilter
#{
#<#
#	.SYNOPSIS
#		The function Set-DataGridViewFilter helps to only show specific entries with a specific value
#	
#	.DESCRIPTION
#		The function Set-DataGridViewFilter helps to only show specific entries with a specific value.
#		The data needs to be in a DataTable Object. You can use ConvertTo-DataTable to convert your
#		PowerShell object into a DataTable object.
#	
#	.PARAMETER AllColumns
#		Specifies to search all the column
#	
#	.PARAMETER ColumnName
#		Specifies to search in a specific column name
#	
#	.PARAMETER DataGridView
#		Specifies the DataGridView control where the data will be filtered
#	
#	.PARAMETER DataTable
#		Specifies the DataTable object that is most likely the original source of the DataGridView
#	
#	.PARAMETER Filter
#		Specifies the string to search
#	
#	.EXAMPLE
#		PS C:\> Set-DataGridViewFilter -DataGridView $datagridview1 -DataTable $ProcessesDT -AllColumns -Filter $textbox1.Text
#	
#	.EXAMPLE
#		PS C:\> Set-DataGridViewFilter -DataGridView $datagridview1 -DataTable $ProcessesDT -ColumnName "Name" -Filter $textbox1.Text
#
#	.NOTES
#		Author: Francois-Xavier Cat
#		Twitter:@LazyWinAdm
#		WWW: 	lazywinadmin.com
##>
#	PARAM (
#		[Parameter(Mandatory = $true)]
#		[System.Windows.Forms.DataGridView]$DataGridView,
#		[Parameter(Mandatory = $true)]
#		[System.Data.DataTable]$DataTable,
#		[Parameter(Mandatory = $true)]
#		[String]$Filter,
#		
#		[Parameter(Mandatory = $true, ParameterSetName = "OneColumn")]
#		[String]$ColumnName,
#		[Parameter(Mandatory = $true, ParameterSetName = "AllColumns")]
#		[Switch]$AllColumns
#	)
#	PROCESS
#	{
#		$Filter = $Filter.ToString()
#		
#		IF ($PSBoundParameters['AllColumns'])
#		{
#			FOREACH ($Column in $DataTable.Columns)
#			{
#				#$RowFilter += "Convert("+$($Column.ColumnName)+",'system.string') Like '%"{1}%' OR " -f $Column.ColumnName, $Filter
#				$RowFilter += "Convert($($Column.ColumnName),'system.string') Like '%$Filter%' OR "
#			}
#			
#			# Remove the last 'OR'
#			$RowFilter = $RowFilter -replace " OR $", ''
#			
#			#Append-RichtextboxStatus -Message $RowFilter
#		}
#		IF ($PSBoundParameters['ColumnName'])
#		{
#			$RowFilter = "$ColumnName LIKE '%$Filter%'"
#		}
#		
#		$DataTable.defaultview.rowfilter = $RowFilter
#		Load-DataGridView -DataGridView $DataGridView -Item $DataTable
#	}
#	END { Remove-Variable -Name $RowFilter -ErrorAction 'SilentlyContinue' | Out-Null }
#}#Set-DataGridViewFilter
#
#function ConvertTo-DataTable
#{
#	<#
#		.SYNOPSIS
#			Converts objects into a DataTable.
#	
#		.DESCRIPTION
#			Converts objects into a DataTable, which are used for DataBinding.
#	
#		.PARAMETER  InputObject
#			The input to convert into a DataTable.
#	
#		.PARAMETER  Table
#			The DataTable you wish to load the input into.
#	
#		.PARAMETER RetainColumns
#			This switch tells the function to keep the DataTable's existing columns.
#		
#		.PARAMETER FilterWMIProperties
#			This switch removes WMI properties that start with an underline.
#	
#		.EXAMPLE
#			$DataTable = ConvertTo-DataTable -InputObject (Get-Process)
#	
#		.NOTES
#			SAPIEN Technologies, Inc.
#			http://www.sapien.com/
#	
#			VERSION HISTORY
#			1.0 ????/??/?? From Sapien.com Version
#			2.0 2014/12/03 Francois-Xavier Cat - In the rows workk, I added a 
#				small piece of code to handle the $null value with [DBNull]::Value
#				
#	#>
#	[CmdletBinding()]
#	[OutputType([System.Data.DataTable])]
#	param (
#		[ValidateNotNull()]
#		$InputObject,
#		[ValidateNotNull()]
#		[System.Data.DataTable]$Table,
#		[switch]$RetainColumns,
#		[switch]$FilterWMIProperties
#	)
#	
#	if ($Table -eq $null)
#	{
#		$Table = New-Object System.Data.DataTable
#	}
#	
#	if ($InputObject -is [System.Data.DataTable])
#	{
#		$Table = $InputObject
#	}
#	else
#	{
#		if (-not $RetainColumns -or $Table.Columns.Count -eq 0)
#		{
#			#Clear out the Table Contents
#			$Table.Clear()
#			
#			if ($InputObject -eq $null) { return } #Empty Data
#			
#			$object = $null
#			
#			#find the first non null value
#			foreach ($item in $InputObject)
#			{
#				if ($item -ne $null)
#				{
#					$object = $item
#					break
#				}
#			}
#			
#			if ($object -eq $null) { return } #All null then empty
#			
#			#COLUMN
#			#Get all the properties in order to create the columns
#			foreach ($prop in $object.PSObject.Get_Properties())
#			{
#				if (-not $FilterWMIProperties -or -not $prop.Name.StartsWith('__'))#filter out WMI properties
#				{
#					#Get the type from the Definition string
#					$type = $null
#					
#					if ($prop.Value -ne $null)
#					{
#						try { $type = $prop.Value.GetType() }
#						catch { Write-Verbose -Message "Can't find type of $prop" }
#					}
#					
#					if ($type -ne $null) # -and [System.Type]::GetTypeCode($type) -ne 'Object')
#					{
#						Write-Verbose -Message "Creating Column: $($Prop.name) (Type: $type)"
#						[void]$table.Columns.Add($prop.Name, $type)
#					}
#					else #Type info not found
#					{
#						#if ($prop.name -eq "" -or $prop.name -eq $null) { [void]$table.Columns.Add([DBNull]::Value) }
#						[void]$table.Columns.Add($prop.Name)
#					}
#				}
#			}
#			
#			if ($object -is [System.Data.DataRow])
#			{
#				foreach ($item in $InputObject)
#				{
#					$Table.Rows.Add($item)
#				}
#				return @(, $Table)
#			}
#		}
#		else
#		{
#			$Table.Rows.Clear()
#		}
#		
#		#Rows Work
#		foreach ($item in $InputObject)
#		{
#			# Create a new row object
#			$row = $table.NewRow()
#			
#			if ($item)
#			{
#				foreach ($prop in $item.PSObject.Get_Properties())
#				{
#					#Find the appropriate column to put the value
#					if ($table.Columns.Contains($prop.Name))
#					{
#						if ($prop.value -eq $null) { $prop.value = [DBNull]::Value }
#						$row.Item($prop.Name) = $prop.Value
#					}
#				}
#			}
#			[void]$table.Rows.Add($row)
#		}
#	}
#	
#	return @(, $Table)
#}
#
#function Load-DataGridView
#{
#	<#
#	.SYNOPSIS
#		This functions helps you load items into a DataGridView.
#
#	.DESCRIPTION
#		Use this function to dynamically load items into the DataGridView control.
#
#	.PARAMETER  DataGridView
#		The ComboBox control you want to add items to.
#
#	.PARAMETER  Item
#		The object or objects you wish to load into the ComboBox's items collection.
#	
#	.PARAMETER  DataMember
#		Sets the name of the list or table in the data source for which the DataGridView is displaying data.
#	#>
#	
#	[CmdletBinding()]
#	Param (
#		[ValidateNotNull()]
#		[Parameter(Mandatory=$true)]
#		[System.Windows.Forms.DataGridView]$DataGridView,
#		[ValidateNotNull()]
#		[Parameter(Mandatory=$true)]
#		$Item,
#	    [Parameter(Mandatory=$false)]
#		[string]$DataMember
#	)
#	$DataGridView.SuspendLayout()
#	$DataGridView.DataMember = $DataMember
#	
#	if ($Item -is [System.ComponentModel.IListSource]`
#	-or $Item -is [System.ComponentModel.IBindingList] -or $Item -is [System.ComponentModel.IBindingListView] )
#	{
#		$DataGridView.DataSource = $Item
#	}
#	else
#	{
#		$array = New-Object System.Collections.ArrayList
#		
#		if ($Item -is [System.Collections.IList])
#		{
#			$array.AddRange($Item)
#		}
#		else
#		{	
#			$array.Add($Item)	
#		}
#		$DataGridView.DataSource = $array
#	}
#	
#	$DataGridView.ResumeLayout()
#}
#
#function Set-TextBox
#{
#	[CmdletBinding()]
#	PARAM (
#		[System.Windows.Forms.TextBox]$TextBox,
#		[System.Drawing.Color]$BackColor
#	)
#	BEGIN { }
#	PROCESS
#	{
#		TRY
#		{
#			$TextBox.BackColor = $BackColor
#		}
#		CATCH { }
#	}
#}
#
#function Disable-Button
#{
#<#
#.SYNOPSIS
#	This function will disable a button control
#.EXAMPLE
#	Disable-Button -Button $Button
#.NOTES
#	Francois-Xavier Cat
#	@lazywinadm
#	www.lazywinadmin.com
##>
#	[CmdletBinding()]
#	PARAM (
#		[ValidateNotNull()]
#		[Parameter(Mandatory = $true)]
#		[System.Windows.Forms.Button[]]$Button
#	)
#	BEGIN
#	{
#		Add-Type -AssemblyName System.Windows.Forms
#	}
#	PROCESS
#	{
#		foreach ($ButtonObject in $Button)
#		{
#			$ButtonObject.Enabled = $false
#		}
#		
#	}
#}#Disable-Button
#
#function Reset-TextBox
#{
#	[CmdletBinding()]
#	PARAM (
#		[System.Windows.Forms.TextBox]$TextBox,
#		[System.Drawing.Color]$BackColor = "White",
#		[System.Drawing.Color]$ForeColor = "Black"
#	)
#	BEGIN { }
#	PROCESS
#	{
#		TRY
#		{
#			$TextBox.Text = ""
#			$TextBox.BackColor = $BackColor
#			$TextBox.ForeColor = $ForeColor
#		}
#		CATCH { }
#	}
#}
#
#function Enable-Button
#{
#<#
#.SYNOPSIS
#	This function will enable a button control
#.EXAMPLE
#	Enable-Button -Button $Button
#.NOTES
#	Francois-Xavier Cat
#	@lazywinadm
#	www.lazywinadmin.com
##>
#	[CmdletBinding()]
#	PARAM (
#		[ValidateNotNull()]
#		[Parameter(Mandatory = $true)]
#		[System.Windows.Forms.Button[]]$Button
#	)
#	BEGIN
#	{
#		Add-Type -AssemblyName System.Windows.Forms
#	}
#	PROCESS
#	{
#		foreach ($ButtonObject in $Button)
#		{
#			$ButtonObject.Enabled = $true
#		}
#	}
#}#Enable-Button
#
#function Clear-DataGridViewSelection
#{
#	PARAM (
#		[Parameter(Mandatory = $true)]
#		[System.Windows.Forms.DataGridView]$DataGridView
#	)
#	$DataGridView.ClearSelection()
#}
#
#function New-MessageBox
#{
#<#
#	.SYNOPSIS
#		The New-MessageBox functio will show a message box to the user
#	
#	.DESCRIPTION
#		The New-MessageBox functio will show a message box to the user
#	
#	.PARAMETER Message
#		Specifies the message to show
#	
#	.PARAMETER Title
#		Specifies the title of the message box
#	
#	.PARAMETER Buttons
#		Specifies which button to add. Just press tab to see the choices
#	
#	.PARAMETER Icon
#		Specifies the icon to show. Just press tab to see the choices
#	
#	.EXAMPLE
#		PS C:\> New-MessageBox -Message "Hello World" -Title "First Message" -Buttons "RetryCancel" -Icon "Asterix"
#	
#	.NOTES
#		Author: Francois-Xavier Cat
#		Twitter:@LazyWinAdm
#		WWW: 	lazywinadmin.com
##>
#	[CmdletBinding()]
#	PARAM (
#		
#		[String]$Message,
#		[String]$Title,
#		[System.Windows.Forms.MessageBoxButtons]$Buttons = "OK",
#		[System.Windows.Forms.MessageBoxIcon]$Icon = "None"
#	)
#	BEGIN
#	{
#		Add-Type -AssemblyName System.Windows.Forms
#	}
#	PROCESS
#	{
#		[System.Windows.Forms.MessageBox]::Show($Message, $Title, $Buttons, $Icon)
#	}
#}#New-MessageBox
#
## PSTerminalServices Module by Shay Levy
#$script:Server='localhost'
#function Get-TSSession
#{
#	<#
#	.SYNOPSIS
#		Lists the sessions on a given terminal server.
#
#	.DESCRIPTION
#		Use Get-TSSession to get a list of sessions from a local or remote computers.
#		Note that Get-TSSession is using Aliased properties to display the output on the console (IPAddress and State), these attributes
#		are not the same as the original attributes (ClientIPAddress and ConnectionState).
#		This is important when you want to use the -Filter parameter which requires the latter.
#		To see all aliassed properties and their corresponding properties (Definition column), pipe the result to Get-Member:
#
#		PS > Get-TSSession | Get-Member -MemberType AliasProperty
#
#		   TypeName: Cassia.Impl.TerminalServicesSession
#
#		Name      MemberType    Definition
#		----      ----------    ----------
#		(...)
#		IPAddress AliasProperty IPAddress = ClientIPAddress
#		State     AliasProperty State = ConnectionState
#
#
#	.PARAMETER ComputerName
#	    	The name of the terminal server computer. The default is the local computer. Default value is the local computer (localhost).
#
#	.PARAMETER Id
#		Specifies the session Id number.
#
#	.PARAMETER InputObject
#		   Specifies a session object. Enter a variable that contains the object, or type a command or expression that gets the sessions.
#
#	.PARAMETER Filter
#		   Specifies a filter based on the session properties. The syntax of the filter, including the use of
#		   wildcards and depends on the properties of the session. Internally, The Filter parameter uses client side
#		   filtering using the Where-Object cmdlet, objects are filtered after they are retrieved.
#
#	.PARAMETER State
#		The connection state of the session. Use this parameter to get sessions of a specific state. Valid values are:
#
#		Value		 Description
#		-----		 -----------
#		Active		 A user is logged on to the session.
#		ConnectQuery The session is in the process of connecting to a client.
#		Connected	 A client is connected to the session).
#		Disconnected The session is active, but the client has disconnected from it.
#		Down		 The session is down due to an error.
#		Idle		 The session is waiting for a client to connect.
#		Initializing The session is initializing.
#		Listening 	 The session is listening for connections.
#		Reset		 The session is being reset.
#		Shadowing	 This session is shadowing another session.
#
#	.PARAMETER ClientName
#		The name of the machine last connected to a session.
#		Use this parameter to get sessions made from a specific computer name. Wildcrads are permitted.
#
#	.PARAMETER UserName
#		Use this parameter to get sessions made by a specific user name. Wildcrads are permitted.
#
#	.EXAMPLE
#		Get-TSSession
#
#		Description
#		-----------
#		Gets all the sessions from the local computer.
#
#	.EXAMPLE
#		Get-TSSession -ComputerName comp1 -State Disconnected
#
#		Description
#		-----------
#		Gets all the disconnected sessions from the remote computer 'comp1'.
#
#	.EXAMPLE
#		Get-TSSession -ComputerName comp1 -Filter {$_.ClientIPAddress -like '10*' -AND $_.ConnectionState -eq 'Active'}
#
#		Description
#		-----------
#		Gets all Active sessions from remote computer 'comp1', made from ip addresses that starts with '10'.
#
#	.EXAMPLE
#		Get-TSSession -ComputerName comp1 -UserName a*
#
#		Description
#		-----------
#		Gets all sessions from remote computer 'comp1' made by users with name starts with the letter 'a'.
#
#	.EXAMPLE
#		Get-TSSession -ComputerName comp1 -ClientName s*
#
#		Description
#		-----------
#		Gets all sessions from remote computer 'comp1' made from a computers names that starts with the letter 's'.
#
#	.OUTPUTS
#		Cassia.Impl.TerminalServicesSession
#
#	.COMPONENT
#		TerminalServer
#
#	.NOTES
#		Author: Shay Levy
#		Blog  : http://blogs.microsoft.co.il/blogs/ScriptFanatic/
#
#	.LINK
#		http://code.msdn.microsoft.com/PSTerminalServices
#
#	.LINK
#		http://code.google.com/p/cassia/
#
#	.LINK
#		Stop-TSSession
#		Disconnect-TSSession
#		Send-TSMessage
#	#>
#
#
#	[OutputType('Cassia.Impl.TerminalServicesSession')]
#	[CmdletBinding(DefaultParameterSetName='Session')]
#
#	Param(
#
#		[Parameter()]
#		[Alias('CN','IPAddress')]
#		[System.String]$ComputerName,
#
#		[Parameter(
#			Position=0,
#			ValueFromPipelineByPropertyName=$true,
#			ParameterSetName='Session'
#		)]
#		[Alias('SessionID')]
#		[ValidateRange(0,65536)]
#		[System.Int32]$Id=-1,
#
#		[Parameter(
#			Position=0,
#			Mandatory=$true,
#			ValueFromPipeline=$true,
#			ParameterSetName='InputObject'
#		)]
#		[Cassia.Impl.TerminalServicesSession]$InputObject,
#
#		[Parameter(
#			Mandatory=$true,
#			ParameterSetName='Filter'
#		)]
#		[ScriptBlock]$Filter,
#
#		[Parameter()]
#		[ValidateSet('Active','Connected','ConnectQuery','Shadowing','Disconnected','Idle','Listening','Reset','Down','Initializing')]
#		[Alias('ConnectionState')]
#		[System.String]$State='*',
#
#		[Parameter()]
#		[System.String]$ClientName='*',
#
#		[Parameter()]
#		[System.String]$UserName='*'
#	)
#
#
#	begin
#	{
#		try
#		{
#			$FuncName = $MyInvocation.MyCommand
#			Write-Verbose "[$funcName] Entering Begin block."
#
#			if(!$ComputerName)
#			{
#				Write-Verbose "[$funcName] $ComputerName is not defined, loading global value '$script:Server'."
#				$ComputerName = Get-TSGlobalServerName
#			}
#			else
#			{
#				$ComputerName = Set-TSGlobalServerName -ComputerName $ComputerName
#			}
#
#
#			Write-Verbose "[$FuncName] Attempting remote connection to '$ComputerName'"
#			$TSManager = New-Object Cassia.TerminalServicesManager
#			$TSRemoteServer = $TSManager.GetRemoteServer($ComputerName)
#			$TSRemoteServer.Open()
#
#			if(!$TSRemoteServer.IsOpen)
#			{
#				Throw 'Connection to remote server is not open. Use Connect-TSServer to connect first.'
#			}
#
#			Write-Verbose "[$FuncName] Connection is open '$ComputerName'"
#			Write-Verbose "[$FuncName] Updating global Server name '$ComputerName'"
#			$null = Set-TSGlobalServerName -ComputerName $ComputerName
#		}
#		catch
#		{
#			Throw
#		}
#	}
#
#
#	Process
#	{
#
#		Write-Verbose "[$funcName] Entering Process block."
#
#		try
#		{
#			if($PSCmdlet.ParameterSetName -eq 'Session')
#			{
#				Write-Verbose "[$FuncName] Binding to ParameterSetName '$($PSCmdlet.ParameterSetName)'"
#				if($Id -lt 0)
#				{
#					$session = $TSRemoteServer.GetSessions()
#				}
#				else
#				{
#					$session = $TSRemoteServer.GetSession($Id)
#				}
#			}
#
#			if($PSCmdlet.ParameterSetName -eq 'InputObject')
#			{
#				Write-Verbose "[$FuncName] Binding to ParameterSetName '$($PSCmdlet.ParameterSetName)'"
#				$session = $InputObject
#			}
#
#			if($PSCmdlet.ParameterSetName -eq 'Filter')
#			{
#				Write-Verbose "[$FuncName] Binding to ParameterSetName '$($PSCmdlet.ParameterSetName)'"
#
#				$TSRemoteServer.GetSessions() | Where-Object $Filter
#			}
#
#			if($session)
#			{
#				$session | Where-Object {$_.ConnectionState -like $State -AND $_.UserName -like $UserName -AND $_.ClientName -like $ClientName } | `
#				Add-Member -MemberType AliasProperty -Name IPAddress -Value ClientIPAddress -PassThru | `
#				Add-Member -MemberType AliasProperty -Name State -Value ConnectionState -PassThru
#			}
#		}
#		catch
#		{
#			Throw
#		}
#	}
#
#	end
#	{
#		try
#		{
#			Write-Verbose "[$funcName] Entering End block."
#			Write-Verbose "[$funcName] Disconnecting from remote server '$($TSRemoteServer.ServerName)'"
#			$TSRemoteServer.Close()
#			$TSRemoteServer.Dispose()
#		}
#		catch
#		{
#			Throw
#		}
#	}
#}
#
#function Disconnect-TSSession
#{
#
#	<#
#	.SYNOPSIS
#		Disconnects any connected user from the session.
#
#	.DESCRIPTION
#		Disconnect-TSSession disconnects any connected user from a session on local or remote computers.
#
#	.PARAMETER ComputerName
#	    	The name of the terminal server computer. The default is the local computer. Default value is the local computer (localhost).
#
#	.PARAMETER Id
#		Specifies the session Id number.
#
#	.PARAMETER InputObject
#		   Specifies a session object. Enter a variable that contains the object, or type a command or expression that gets the sessions.
#
#	.PARAMETER Synchronous
#	       When the Synchronous parameter is present the command waits until the session is fully disconnected otherwise it returns
#	       immediately, even though the session may not be completely disconnected yet.
#
#	.PARAMETER Force
#	       Overrides any confirmations made by the command.
#
#	.EXAMPLE
#		Get-TSSession -ComputerName comp1 | Disconnect-TSSession
#
#		Description
#		-----------
#		Disconnects all connected users from Active sessions on remote computer 'comp1'. The caller is prompted to
#		By default, the caller is prompted to confirm each action.
#
#	.EXAMPLE
#		Get-TSSession -ComputerName comp1 -State Active | Disconnect-TSSession -Force
#
#		Description
#		-----------
#		Disconnects any connected user from Active sessions on remote computer 'comp1'.
#		By default, the caller is prompted to confirm each action. To override confirmations, the Force Switch parameter is specified.
#
#	.EXAMPLE
#		Get-TSSession -ComputerName comp1 -State Active -Synchronous | Disconnect-TSSession -Force
#
#		Description
#		-----------
#		Disconnects any connected user from Active sessions on remote computer 'comp1'. The Synchronous parameter tells the command to
#		wait until the session is fully disconnected and only tghen it proceeds to the next session object.
#		By default, the caller is prompted to confirm each action. To override confirmations, the Force Switch parameter is specified.
#
#	.OUTPUTS
#
#	.COMPONENT
#		TerminalServer
#
#	.NOTES
#		Author: Shay Levy
#		Blog  : http://blogs.microsoft.co.il/blogs/ScriptFanatic/
#
#	.LINK
#		http://code.msdn.microsoft.com/PSTerminalServices
#
#	.LINK
#		http://code.google.com/p/cassia/
#
#	.LINK
#		Get-TSSession
#		Stop-TSSession
#		Send-TSMessage
#	#>
#
#	[CmdletBinding(SupportsShouldProcess=$true,ConfirmImpact='High',DefaultParameterSetName='Id')]
#
#	Param(
#
#		[Parameter()]
#		[Alias('CN','IPAddress')]
#		[System.String]$ComputerName=$script:server,
#
#		[Parameter(
#			Position=0,
#			Mandatory=$true,
#			ParameterSetName='Id',
#			ValueFromPipelineByPropertyName=$true
#		)]
#		[Alias('SessionId')]
#		[System.Int32]$Id,
#
#		[Parameter(
#			Mandatory=$true,
#			ValueFromPipeline=$true,
#			ParameterSetName='InputObject'
#		)]
#		[Cassia.Impl.TerminalServicesSession]$InputObject,
#
#		[switch]$Synchronous,
#
#		[switch]$Force
#	)
#
#	begin
#	{
#		try
#		{
#			$FuncName = $MyInvocation.MyCommand
#			Write-Verbose "[$funcName] Entering Begin block."
#
#			if(!$ComputerName)
#			{
#				Write-Verbose "[$funcName] $ComputerName is not defined, loading global value '$script:Server'."
#				$ComputerName = Get-TSGlobalServerName
#			}
#			else
#			{
#				$ComputerName = Set-TSGlobalServerName -ComputerName $ComputerName
#			}
#
#			Write-Verbose "[$FuncName] Attempting remote connection to '$ComputerName'"
#			$TSManager = New-Object Cassia.TerminalServicesManager
#			$TSRemoteServer = $TSManager.GetRemoteServer($ComputerName)
#			$TSRemoteServer.Open()
#
#			if(!$TSRemoteServer.IsOpen)
#			{
#				Throw 'Connection to remote server is not open. Use Connect-TSServer to connect first.'
#			}
#
#			Write-Verbose "[$FuncName] Connection is open '$ComputerName'"
#			Write-Verbose "[$FuncName] Updating global Server name '$ComputerName'"
#			$null = Set-TSGlobalServerName -ComputerName $ComputerName
#		}
#		catch
#		{
#			Throw
#		}
#	}
#
#
#	Process
#	{
#
#		Write-Verbose "[$funcName] Entering Process block."
#
#		try
#		{
#			if($PSCmdlet.ParameterSetName -eq 'Id')
#			{
#				Write-Verbose "[$FuncName] Binding to ParameterSetName '$($PSCmdlet.ParameterSetName)'"
#				$session = $TSRemoteServer.GetSession($Id)
#			}
#
#			if($PSCmdlet.ParameterSetName -eq 'InputObject')
#			{
#				Write-Verbose "[$FuncName] Binding to ParameterSetName '$($PSCmdlet.ParameterSetName)'"
#				$session  = $InputObject
#			}
#
#
#			if($session -ne $null)
#			{
#				if($Force -or $PSCmdlet.ShouldProcess($TSRemoteServer.ServerName,"Disconnecting session id '$($session.sessionId)'"))
#				{
#					if($session.ConnectionState -ne 'Disconnected')
#					{
#						$session.Disconnect($Synchronous)
#					}
#					else
#					{
#						Write-Verbose 'Session is already in Disconnected mode.'
#					}
#				}
#			}
#		}
#		catch
#		{
#			Throw
#		}
#	}
#
#	end
#	{
#		try
#		{
#			Write-Verbose "[$funcName] Entering End block."
#			Write-Verbose "[$funcName] Disconnecting from remote server '$($TSRemoteServer.ServerName)'"
#			$TSRemoteServer.Close()
#			$TSRemoteServer.Dispose()
#		}
#		catch
#		{
#			Throw
#		}
#	}
#}
#
#function Stop-TSSession
#{
#
#	<#
#	.SYNOPSIS
#		Logs the session off, disconnecting any user that might be connected.
#
#	.DESCRIPTION
#		Use Stop-TSSession to logoff the session and disconnect any user that might be connected.
#
#	.PARAMETER ComputerName
#	    	The name of the terminal server computer. The default is the local computer. Default value is the local computer (localhost).
#
#	.PARAMETER Id
#		Specifies the session Id number.
#
#	.PARAMETER InputObject
#		   Specifies a session object. Enter a variable that contains the object, or type a command or expression that gets the sessions.
#
#	.PARAMETER Synchronous
#	       When the Synchronous parameter is present the command waits until the session is fully disconnected otherwise it returns
#	       immediately, even though the session may not be completely disconnected yet.
#
#	.PARAMETER Force
#	       Overrides any confirmations made by the command.
#
#	.EXAMPLE
#		Get-TSSession -ComputerName comp1 | Stop-TSSession
#
#		Description
#		-----------
#		logs off all connected users from Active sessions on remote computer 'comp1'. The caller is prompted to
#		By default, the caller is prompted to confirm each action.
#
#	.EXAMPLE
#		Get-TSSession -ComputerName comp1 -State Active | Stop-TSSession -Force
#
#		Description
#		-----------
#		logs off any connected user from Active sessions on remote computer 'comp1'.
#		By default, the caller is prompted to confirm each action. To override confirmations, the Force Switch parameter is specified.
#
#	.EXAMPLE
#		Get-TSSession -ComputerName comp1 -State Active -Synchronous | Stop-TSSession -Force
#
#		Description
#		-----------
#		logs off any connected user from Active sessions on remote computer 'comp1'. The Synchronous parameter tells the command to
#		wait until the session is fully disconnected and only tghen it proceeds to the next session object.
#		By default, the caller is prompted to confirm each action. To override confirmations, the Force Switch parameter is specified.
#
#	.OUTPUTS
#
#	.COMPONENT
#		TerminalServer
#
#	.NOTES
#		Author: Shay Levy
#		Blog  : http://blogs.microsoft.co.il/blogs/ScriptFanatic/
#
#	.LINK
#		http://code.msdn.microsoft.com/PSTerminalServices
#
#	.LINK
#		http://code.google.com/p/cassia/
#
#	.LINK
#		Get-TSSession
#		Disconnect-TSSession
#		Send-TSMessage
#	#>
#
#	[CmdletBinding(SupportsShouldProcess=$true,ConfirmImpact='High',DefaultParameterSetName='Id')]
#
#	Param(
#
#		[Parameter()]
#		[Alias('CN','IPAddress')]
#		[System.String]$ComputerName=$script:server,
#
#		[Parameter(
#			Position=0,
#			Mandatory=$true,
#			ParameterSetName='Id',
#			ValueFromPipelineByPropertyName=$true
#		)]
#		[Alias('SessionId')]
#		[System.Int32]$Id,
#
#		[Parameter(
#			Mandatory=$true,
#			ValueFromPipeline=$true,
#			ParameterSetName='InputObject'
#		)]
#		[Cassia.Impl.TerminalServicesSession]$InputObject,
#
#		[switch]$Synchronous,
#
#		[switch]$Force
#	)
#
#	begin
#	{
#		try
#		{
#			$FuncName = $MyInvocation.MyCommand
#			Write-Verbose "[$funcName] Entering Begin block."
#
#			if(!$ComputerName)
#			{
#				Write-Verbose "[$funcName] $ComputerName is not defined, loading global value '$script:Server'."
#				$ComputerName = Get-TSGlobalServerName
#			}
#			else
#			{
#				$ComputerName = Set-TSGlobalServerName -ComputerName $ComputerName
#			}
#
#			Write-Verbose "[$FuncName] Attempting remote connection to '$ComputerName'"
#			$TSManager = New-Object Cassia.TerminalServicesManager
#			$TSRemoteServer = $TSManager.GetRemoteServer($ComputerName)
#			$TSRemoteServer.Open()
#
#			if(!$TSRemoteServer.IsOpen)
#			{
#				Throw 'Connection to remote server is not open. Use Connect-TSServer to connect first.'
#			}
#
#			Write-Verbose "[$FuncName] Connection is open '$ComputerName'"
#			Write-Verbose "[$FuncName] Updating global Server name '$ComputerName'"
#			$null = Set-TSGlobalServerName -ComputerName $ComputerName
#		}
#		catch
#		{
#			Throw
#		}
#	}
#
#
#
#	Process
#	{
#
#		Write-Verbose "[$funcName] Entering Process block."
#
#		try
#		{
#
#			if($PSCmdlet.ParameterSetName -eq 'Id')
#			{
#				Write-Verbose "[$FuncName] Binding to ParameterSetName '$($PSCmdlet.ParameterSetName)'"
#				$session = $TSRemoteServer.GetSession($Id)
#			}
#
#			if($PSCmdlet.ParameterSetName -eq 'InputObject')
#			{
#				Write-Verbose "[$FuncName] Binding to ParameterSetName '$($PSCmdlet.ParameterSetName)'"
#				$session  = $InputObject
#			}
#
#			if($session -ne $null)
#			{
#				if($Force -or $PSCmdlet.ShouldProcess($TSRemoteServer.ServerName,"Logging off session id '$($session.sessionId)'"))
#				{
#					Write-Verbose "[$FuncName] Logging off session '$($session.SessionId)'"
#					$session.Logoff($Synchronous)
#				}
#			}
#		}
#		catch
#		{
#			Throw
#		}
#	}
#
#
#	end
#	{
#		try
#		{
#			Write-Verbose "[$funcName] Entering End block."
#			Write-Verbose "[$funcName] Disconnecting from remote server '$($TSRemoteServer.ServerName)'"
#			$TSRemoteServer.Close()
#			$TSRemoteServer.Dispose()
#		}
#		catch
#		{
#			Throw
#		}
#	}
#}
#
#function Get-TSProcess
#{
#
#	<#
#	.SYNOPSIS
#		Gets a list of processes running in a specific session or in all sessions.
#
#	.DESCRIPTION
#		Use Get-TSProcess to get a list of session processes from a local or remote computers.
#
#	.PARAMETER ComputerName
#	    	The name of the terminal server computer. The default is the local computer. Default value is the local computer (localhost).
#
#	.PARAMETER Id
#		Specifies the process Id number.
#
#	.PARAMETER InputObject
#		   Specifies a process object. Enter a variable that contains the object, or type a command or expression that gets the sessions.
#
#	.PARAMETER Name
#		   Specifies the process name. Wildcards are permitted.
#
#	.PARAMETER Session
#		Specifies the session Id number.
#
#	.EXAMPLE
#		Get-TSProcess
#
#		Description
#		-----------
#		Gets all the sessions processes from the local computer.
#
#	.EXAMPLE
#		Get-TSSession -Id 0 -ComputerName comp1 | Get-TSProcess
#
#		Description
#		-----------
#		Gets all processes connected to session id 0 from remote computer 'comp1'.
#
#	.EXAMPLE
#		Get-TSProcess -Name s* -ComputerName comp1
#
#		Description
#		-----------
#		Gets all the processes with name starts with the letter 's' from remote computer 'comp1'.
#
#	.OUTPUTS
#		Cassia.Impl.TerminalServicesProcess
#
#	.COMPONENT
#		TerminalServer
#
#	.NOTES
#		Author: Shay Levy
#		Blog  : http://blogs.microsoft.co.il/blogs/ScriptFanatic/
#
#	.LINK
#		http://code.msdn.microsoft.com/PSTerminalServices
#
#	.LINK
#		http://code.google.com/p/cassia/
#
#	.LINK
#		Get-TSSession
#		Stop-TSProcess
#	#>
#
#
#	[OutputType('Cassia.Impl.TerminalServicesProcess')]
#	[CmdletBinding(DefaultParameterSetName='Name')]
#
#	Param(
#
#		[Parameter()]
#		[Alias('CN','IPAddress')]
#		[System.String]$ComputerName=$script:server,
#
#		[Parameter(
#			Position=0,
#			ValueFromPipelineByPropertyName=$true,
#			ParameterSetName='Name'
#		)]
#		[Alias('ProcessName')]
#		[System.String]$Name='*',
#
#		[Parameter(
#			Mandatory=$true,
#			ValueFromPipeline=$true,
#			ValueFromPipelineByPropertyName=$true,
#			ParameterSetName='Id'
#		)]
#		[Alias('ProcessID')]
#		[ValidateRange(0,65536)]
#		[System.Int32]$Id=-1,
#
#
#		[Parameter(
#			Position=0,
#			Mandatory=$true,
#			ValueFromPipeline=$true,
#			ParameterSetName='InputObject'
#		)]
#		[Cassia.Impl.TerminalServicesProcess]$InputObject,
#
#
#		[Parameter(
#			Position=0,
#			Mandatory=$true,
#			ValueFromPipeline=$true,
#			ParameterSetName='Session'
#		)]
#		[Alias('SessionId')]
#		[Cassia.Impl.TerminalServicesSession]$Session
#	)
#
#
#
#	begin
#	{
#		$FuncName = $MyInvocation.MyCommand
#		Write-Verbose "[$funcName] Entering Begin block."
#
#		if(!$ComputerName)
#		{
#			Write-Verbose "[$funcName] $ComputerName is not defined, loading global value '$script:Server'."
#			$ComputerName = Get-TSGlobalServerName
#		}
#		else
#		{
#			$ComputerName = Set-TSGlobalServerName -ComputerName $ComputerName
#		}
#
#		Write-Verbose "[$FuncName] Attempting remote connection to '$ComputerName'"
#		$TSManager = New-Object Cassia.TerminalServicesManager
#		$TSRemoteServer = $TSManager.GetRemoteServer($ComputerName)
#		$TSRemoteServer.Open()
#
#		if(!$TSRemoteServer.IsOpen)
#		{
#			Throw 'Connection to remote server is not open. Use Connect-TSServer to connect first.'
#		}
#
#		Write-Verbose "[$FuncName] Connection is open '$ComputerName'"
#		Write-Verbose "[$FuncName] Updating global Server name '$ComputerName'"
#		$null = Set-TSGlobalServerName -ComputerName $ComputerName
#	}
#
#
#
#	Process
#	{
#
#		Write-Verbose "[$funcName] Entering Process block."
#
#		try
#		{
#
#			if($PSCmdlet.ParameterSetName -eq 'Name')
#			{
#				Write-Verbose "[$FuncName] Binding to ParameterSetName '$($PSCmdlet.ParameterSetName)'"
#				if($Name -eq '*')
#				{
#					$proc = $TSRemoteServer.GetProcesses()
#				}
#				else
#				{
#					$proc = $TSRemoteServer.GetProcesses() | Where-Object {$_.ProcessName -like $Name}
#				}
#			}
#
#			if($PSCmdlet.ParameterSetName -eq 'Id')
#			{
#				Write-Verbose "[$FuncName] Binding to ParameterSetName '$($PSCmdlet.ParameterSetName)'"
#				if($Id -lt 0)
#				{
#					$proc = $TSRemoteServer.GetProcesses()
#				}
#				else
#				{
#					$proc = $TSRemoteServer.GetProcess($Id)
#				}
#			}
#
#
#			if($PSCmdlet.ParameterSetName -eq 'Session')
#			{
#				Write-Verbose "[$FuncName] Binding to ParameterSetName '$($PSCmdlet.ParameterSetName)'"
#				if($Session)
#				{
#					$proc = $Session.GetProcesses()
#				}
#			}
#
#
#			if($PSCmdlet.ParameterSetName -eq 'InputObject')
#			{
#				Write-Verbose "[$FuncName] Binding to ParameterSetName '$($PSCmdlet.ParameterSetName)'"
#				$proc = $InputObject
#			}
#
#
#			if($proc)
#			{
#				$proc
#			}
#		}
#		catch
#		{
#			Throw
#		}
#	}
#
#
#	end
#	{
#		try
#		{
#			Write-Verbose "[$funcName] Entering End block."
#			Write-Verbose "[$funcName] Disconnecting from remote server '$($TSRemoteServer.ServerName)'"
#			$TSRemoteServer.Close()
#			$TSRemoteServer.Dispose()
#		}
#		catch
#		{
#			Throw
#		}
#	}
#}
#
#function Stop-TSProcess
#{
#
#	<#
#	.SYNOPSIS
#		Terminates the process running in a specific session or in all sessions.
#
#	.DESCRIPTION
#		Use Stop-TSProcess to terminate one or more processes from a local or remote computers.
#
#	.PARAMETER ComputerName
#	    	The name of the terminal server computer. The default is the local computer. Default value is the local computer (localhost).
#
#	.PARAMETER Id
#		Specifies the process Id number.
#
#	.PARAMETER InputObject
#		Specifies a process object. Enter a variable that contains the object, or type a command or expression that gets the sessions.
#
#	.PARAMETER Name
#		Specifies the process name.
#
#	.PARAMETER Session
#		Specifies the session Id number.
#
#	.PARAMETER Force
#	       Overrides any confirmations made by the command.
#
#	.EXAMPLE
#		 Get-TSProcess -Id 6552 | Stop-TSProcess
#
#		Description
#		-----------
#		Gets process Id 6552 from the local computer and stop it. Confirmations needed.
#
#	.EXAMPLE
#		Get-TSSession -Id 3 -ComputerName comp1 | Stop-TSProcess -Force
#
#		Description
#		-----------
#		Terminats all processes connected to session id 3 from remote computer 'comp1', suppress confirmations.
#
#	.OUTPUTS
#		Cassia.Impl.TerminalServicesProcess
#
#	.COMPONENT
#		TerminalServer
#
#	.NOTES
#		Author: Shay Levy
#		Blog  : http://blogs.microsoft.co.il/blogs/ScriptFanatic/
#
#	.LINK
#		http://code.msdn.microsoft.com/PSTerminalServices
#
#	.LINK
#		http://code.google.com/p/cassia/
#
#	.LINK
#		Get-TSProcess
#		Get-TSSession
#	#>
#
#	[CmdletBinding(SupportsShouldProcess=$true,ConfirmImpact='High',DefaultParameterSetName='Name')]
#
#	Param(
#		[Parameter()]
#		[Alias('CN','IPAddress')]
#		[System.String]$ComputerName=$script:server,
#
#		[Parameter(
#			Position=0,
#			ValueFromPipelineByPropertyName=$true,
#			ParameterSetName='Name'
#		)]
#		[Alias("ProcessName")]
#		[System.String]$Name='*',
#
#		[Parameter(
#			Mandatory=$true,
#			ValueFromPipeline=$true,
#			ValueFromPipelineByPropertyName=$true,
#			ParameterSetName='Id'
#		)]
#		[Alias('ProcessID')]
#		[ValidateRange(0,65536)]
#		[System.Int32]$Id=-1,
#
#		[Parameter(
#			Position=0,
#			Mandatory=$true,
#			ValueFromPipeline=$true,
#			ParameterSetName='InputObject'
#		)]
#		[Cassia.Impl.TerminalServicesProcess]$InputObject,
#
#		[Parameter(
#			Position=0,
#			Mandatory=$true,
#			ValueFromPipeline=$true,
#			ParameterSetName='Session'
#		)]
#		[Alias('SessionId')]
#		[Cassia.Impl.TerminalServicesSession]$Session,
#
#		[switch]$Force
#	)
#
#
#	begin
#	{
#		try
#		{
#			$FuncName = $MyInvocation.MyCommand
#			Write-Verbose "[$funcName] Entering Begin block."
#
#			if(!$ComputerName)
#			{
#				Write-Verbose "[$funcName] $ComputerName is not defined, loading global value '$script:Server'."
#				$ComputerName = Get-TSGlobalServerName
#			}
#			else
#			{
#				$ComputerName = Set-TSGlobalServerName -ComputerName $ComputerName
#			}
#
#			Write-Verbose "[$FuncName] Attempting remote connection to '$ComputerName'"
#			$TSManager = New-Object Cassia.TerminalServicesManager
#			$TSRemoteServer = $TSManager.GetRemoteServer($ComputerName)
#			$TSRemoteServer.Open()
#
#			if(!$TSRemoteServer.IsOpen)
#			{
#				Throw 'Connection to remote server is not open. Use Connect-TSServer to connect first.'
#			}
#
#			Write-Verbose "[$FuncName] Connection is open '$ComputerName'"
#			Write-Verbose "[$FuncName] Updating global Server name '$ComputerName'"
#			$null = Set-TSGlobalServerName -ComputerName $ComputerName
#		}
#		catch
#		{
#			Throw
#		}
#	}
#
#
#	Process
#	{
#
#		Write-Verbose "[$funcName] Entering Process block."
#
#		try
#		{
#
#			if($PSCmdlet.ParameterSetName -eq 'Name')
#			{
#				Write-Verbose "[$FuncName] Binding to ParameterSetName '$($PSCmdlet.ParameterSetName)'"
#				if($Name -eq '*')
#				{
#					$proc = $TSRemoteServer.GetProcesses()
#				}
#				else
#				{
#					$proc = $TSRemoteServer.GetProcesses() | Where-Object {$_.ProcessName -like $Name}
#				}
#			}
#
#			if($PSCmdlet.ParameterSetName -eq 'Id')
#			{
#				Write-Verbose "[$FuncName] Binding to ParameterSetName '$($PSCmdlet.ParameterSetName)'"
#				if($Id -lt 0)
#				{
#					$proc = $TSRemoteServer.GetProcesses()
#				}
#				else
#				{
#					$proc = $TSRemoteServer.GetProcess($Id)
#				}
#			}
#
#
#			if($PSCmdlet.ParameterSetName -eq 'Session')
#			{
#				Write-Verbose "[$FuncName] Binding to ParameterSetName '$($PSCmdlet.ParameterSetName)'"
#				if($Session)
#				{
#					$proc = $Session.GetProcesses()
#				}
#			}
#
#
#			if($PSCmdlet.ParameterSetName -eq 'InputObject')
#			{
#				Write-Verbose "[$FuncName] Binding to ParameterSetName '$($PSCmdlet.ParameterSetName)'"
#				$proc = $InputObject
#			}
#
#
#			if($proc)
#			{
#				foreach($p in $proc)
#				{
#					if($Force -or $PSCmdlet.ShouldProcess($TSRemoteServer.ServerName,"Stop Process '$($p.ProcessName) ($($p.ProcessID))"))
#					{
#						Write-Verbose "[$FuncName] Killing process '$($p.ProcessName)' ($($p.ProcessId))"
#						$p.Kill()
#					}
#				}
#			}
#		}
#		catch
#		{
#			Throw
#		}
#	}
#
#
#	end
#	{
#		try
#		{
#			Write-Verbose "[$funcName] Entering End block."
#			Write-Verbose "[$funcName] Disconnecting from remote server '$($TSRemoteServer.ServerName)'"
#			$TSRemoteServer.Close()
#			$TSRemoteServer.Dispose()
#		}
#		catch
#		{
#			Throw
#		}
#	}
#}
#
#function Send-TSMessage
#{
#
#	<#
#	.SYNOPSIS
#		Displays a message box in the specified session Id.
#
#	.DESCRIPTION
#		Use Send-TSMessage display a message box in the specified session Id.
#
#	.PARAMETER ComputerName
#	    	The name of the terminal server computer. The default is the local computer. Default value is the local computer (localhost).
#
#	.PARAMETER Text
#		The text to display in the message box.
#
#	.PARAMETER SessionID
#		The number of the session Id.
#
#	.PARAMETER Caption
#		   The caption of the message box. The default caption is 'Alert'.
#
#	.EXAMPLE
#		$Message = "Importnat message`n, the server is going down for maintanace in 10 minutes. Please save your work and logoff."
#		Get-TSSession -State Active -ComputerName comp1 | Send-TSMessage -Message $Message
#
#		Description
#		-----------
#		Displays a message box inside all active sessions of computer name 'comp1'.
#
#	.OUTPUTS
#
#	.COMPONENT
#		TerminalServer
#
#	.NOTES
#		Author: Shay Levy
#		Blog  : http://blogs.microsoft.co.il/blogs/ScriptFanatic/
#
#	.LINK
#		http://code.msdn.microsoft.com/PSTerminalServices
#
#	.LINK
#		http://code.google.com/p/cassia/
#
#	.LINK
#		Get-TSSession
#	#>
#
#
#	[CmdletBinding(DefaultParameterSetName='Session')]
#
#	Param(
#		[Parameter()]
#		[Alias('CN','IPAddress')]
#		[System.String]$ComputerName=$script:server,
#
#		[Parameter(
#			Position=0,
#			Mandatory=$true,
#			HelpMessage='The text to display in the message box.'
#		)]
#		[System.String]$Text,
#
#		[Parameter(
#			HelpMessage='The caption of the message box.'
#		)]
#		[ValidateNotNullOrEmpty()]
#		[System.String]$Caption='Alert',
#
#		[Parameter(
#			Position=0,
#			ValueFromPipelineByPropertyName=$true,
#			ParameterSetName='Session'
#		)]
#		[Alias('SessionID')]
#		[ValidateRange(0,65536)]
#		[System.Int32]$Id=-1,
#
#		[Parameter(
#			Position=0,
#			Mandatory=$true,
#			ValueFromPipeline=$true,
#			ParameterSetName='InputObject'
#		)]
#		[Cassia.Impl.TerminalServicesSession]$InputObject
#	)
#
#	begin
#	{
#		try
#		{
#			$FuncName = $MyInvocation.MyCommand
#			Write-Verbose "[$funcName] Entering Begin block."
#
#			if(!$ComputerName)
#			{
#				Write-Verbose "[$funcName] $ComputerName is not defined, loading global value '$script:Server'."
#				$ComputerName = Get-TSGlobalServerName
#			}
#			else
#			{
#				$ComputerName = Set-TSGlobalServerName -ComputerName $ComputerName
#			}
#
#			Write-Verbose "[$FuncName] Attempting remote connection to '$ComputerName'"
#			$TSManager = New-Object Cassia.TerminalServicesManager
#			$TSRemoteServer = $TSManager.GetRemoteServer($ComputerName)
#			$TSRemoteServer.Open()
#
#			if(!$TSRemoteServer.IsOpen)
#			{
#				Throw 'Connection to remote server is not open. Use Connect-TSServer to connect first.'
#			}
#
#			Write-Verbose "[$FuncName] Connection is open '$ComputerName'"
#			Write-Verbose "[$FuncName] Updating global Server name '$ComputerName'"
#			$null = Set-TSGlobalServerName -ComputerName $ComputerName
#		}
#		catch
#		{
#			Throw
#		}
#	}
#
#
#	process
#	{
#
#		Write-Verbose "[$funcName] Entering Process block."
#
#		try
#		{
#
#			if($PSCmdlet.ParameterSetName -eq 'Session')
#			{
#				Write-Verbose "[$FuncName] Binding to ParameterSetName '$($PSCmdlet.ParameterSetName)'"
#				if($Id -ge 0)
#				{
#					$session = $TSRemoteServer.GetSession($Id)
#				}
#			}
#
#			if($PSCmdlet.ParameterSetName -eq 'InputObject')
#			{
#				Write-Verbose "[$FuncName] Binding to ParameterSetName '$($PSCmdlet.ParameterSetName)'"
#				$session = $InputObject
#			}
#
#			if($session)
#			{
#				Write-Verbose "[$FuncName] Sending alert message to session id: '$($session.SessionId)' on '$ComputerName'"
#				$session.MessageBox($Text,$Caption)
#			}
#		}
#		catch
#		{
#			Throw
#		}
#	}
#
#
#	end
#	{
#		try
#		{
#			Write-Verbose "[$funcName] Entering End block."
#			Write-Verbose "[$funcName] Disconnecting from remote server '$($TSRemoteServer.ServerName)'"
#			$TSRemoteServer.Close()
#			$TSRemoteServer.Dispose()
#		}
#		catch
#		{
#			Throw
#		}
#	}
#}
#
#function Get-TSServers
#{
#
#	<#
#	.SYNOPSIS
#		Enumerates all terminal servers in a given domain.
#
#	.DESCRIPTION
#		Enumerates all terminal servers in a given domain.
#
#	.PARAMETER ComputerName
#	    	The name of the terminal server computer. The default is the local computer. Default value is the local computer (localhost).
#
#	.PARAMETER DomainName
#		The name of the domain. The default is the caller domain name ($env:USERDOMAIN).
#
#	.EXAMPLE
#		Get-TSDomainServers
#
#		Description
#		-----------
#		Get a list of all terminal servers of the caller default domain.
#
#	.OUTPUTS
#
#	.COMPONENT
#		TerminalServer
#
#	.NOTES
#		Author: Shay Levy
#		Blog  : http://blogs.microsoft.co.il/blogs/ScriptFanatic/
#
#	.LINK
#		http://code.msdn.microsoft.com/PSTerminalServices
#
#	.LINK
#		http://code.google.com/p/cassia/
#
#	.LINK
#		Get-TSSession
#	#>
#
#
#	[OutputType('System.Management.Automation.PSCustomObject')]
#	[CmdletBinding()]
#
#	Param(
#		[Parameter(
#			Position=0,
#			ParameterSetName='Name'
#		)]
#		[System.String]$DomainName=$env:USERDOMAIN
#	)
#
#
#	try
#	{
#		$FuncName = $MyInvocation.MyCommand
#		if(!$ComputerName)
#		{
#			Write-Verbose "[$funcName] ComputerName is not defined, loading global value '$script:Server'."
#			$ComputerName = Get-TSGlobalServerName
#		}
#		else
#		{
#			$ComputerName = Set-TSGlobalServerName -ComputerName $ComputerName
#		}
#
#		Write-Verbose "[$funcName] Enumerating terminal servers for '$DomainName' domain."
#		Write-Warning 'Depending on your environment the command may take a while to complete.'
#		$TSManager = New-Object Cassia.TerminalServicesManager
#		$TSManager.GetServers($DomainName)
#	}
#	catch
#	{
#		Throw
#	}
#
#}
#
#function Get-TSCurrentSession
#{
#
#	<#
#	.SYNOPSIS
#		Provides information about the session in which the current process is running.
#
#	.DESCRIPTION
#		Provides information about the session in which the current process is running.
#
#	.EXAMPLE
#		Get-TSCurrentSession
#
#		Description
#		-----------
#		Displays the session in which the current process is running on the local computer.
#
#	.OUTPUTS
#		Cassia.Impl.TerminalServicesSession
#
#	.COMPONENT
#		TerminalServer
#
#	.NOTES
#		Author: Shay Levy
#		Blog  : http://blogs.microsoft.co.il/blogs/ScriptFanatic/
#
#	.LINK
#		http://code.msdn.microsoft.com/PSTerminalServices
#
#	.LINK
#		http://code.google.com/p/cassia/
#
#	.LINK
#		Get-TSSession
#	#>
#
#
#	[OutputType('Cassia.Impl.TerminalServicesSession')]
#	[CmdletBinding()]
#
#	param(
#		[Parameter()]
#		[Alias('CN','IPAddress')]
#		[System.String]$ComputerName=$script:server
#	)
#
#
#	try
#	{
#		$FuncName = $MyInvocation.MyCommand
#
#		if(!$ComputerName)
#		{
#			Write-Verbose "[$funcName] ComputerName is not defined, loading global value '$script:Server'."
#			$ComputerName = Get-TSGlobalServerName
#		}
#		else
#		{
#			$ComputerName = Set-TSGlobalServerName -ComputerName $ComputerName
#		}
#
#		Write-Verbose "[$funcName] Attempting remote connection to '$ComputerName'"
#		$TSManager = New-Object Cassia.TerminalServicesManager
#		$TSRemoteServer = $TSManager.GetRemoteServer($ComputerName)
#		$TSRemoteServer.Open()
#
#		if(!$TSRemoteServer.IsOpen)
#		{
#			Throw 'Connection to remote server is not open. Use Connect-TSServer to connect first.'
#		}
#
#		Write-Verbose "[$funcName] Connection is open '$ComputerName'"
#		Write-Verbose "[$funcName] Updating global Server name '$ComputerName'"
#		$null = Set-TSGlobalServerName -ComputerName $ComputerName
#
#		Write-Verbose "[$funcName] Get CurrentSession from '$ComputerName'"
#		$TSManager.CurrentSession
#
#		Write-Verbose "[$funcName] Disconnecting from remote server '$($TSRemoteServer.ServerName)'"
#		$TSRemoteServer.Close()
#		$TSRemoteServer.Dispose()
#	}
#	catch
#	{
#		Throw
#	}
#}
#
#function Set-TSGlobalServerName
#{
#	[CmdletBinding()]
#
#	Param(
#		[Parameter(Mandatory=$true)]
#		[ValidateNotNullOrEmpty()]
#		[System.String]$ComputerName
#	)
#
#	if($ComputerName -eq "." -OR $ComputerName -eq $env:COMPUTERNAME)
#	{
#		$ComputerName='localhost'
#	}
#
#	$script:Server=$ComputerName
#	$script:Server
#}
#
#function Get-TSGlobalServerName
#{
#	$script:Server
#}
#
#