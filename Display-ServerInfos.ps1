<#
    .SYNOPSIS
        Affiche de nombreuses infos sur le serveur
    .DESCRIPTION
        affiche les infos de :
        - Systeme
        - charge CPU, RAM, SWAP
        - Infos Disques
        - config Reseau
        - Partage SMB
        - ...
    .PARAMETER Computername
        nom DNS ou IP du serveur cible
    .EXAMPLE
        affiche les infos de localhost
        .\Display-ServerInfos.ps1
    .EXAMPLE
        (Get-QADComputer *03).name | %{$_ | .\Display-ServerInfos.ps1}
    .EXAMPLE
        Start-Process -WindowStyle hidden powershell -ArgumentList "-WindowStyle Normal .\Display-ServerInfos.ps1 $Server"
    
#>

param (
    [Parameter(ValueFromPipeline=$true)]
        [Alias('CN','__Server','IPAddress','Server', 'Name')]  
            [string]$ComputerName = $env:COMPUTERNAME
    )
    $version = 1.0
    $Get_All = {
        $Uptime=([DateTime]::Now - ([Management.ManagementDateTimeConverter]::ToDateTime($obj.OS.LastBootUpTime))).tostring().split('.')
        # $Uptyme.text = "$($Uptime[0])j $($Uptime[1])"
        $SrvForm.text = "$($Obj.ComputerName) / Uptime: $($Uptime[0])j $($Uptime[1])"
        $OS.text = "$($Obj.MachineType) -> $($Obj.os.Caption) SP$($Obj.os.ServicePack) ($($Obj.OS.OSArchitecture))"
        $Domain.text = "$($Obj.SYS.Domain)"
        $CPU.text = "$($Obj.SYS.NumberOfLogicalProcessors) CPUs, charge $($obj.CPU.Average)%"
        $CPUBar.value = $obj.CPU.Average
        $Ram.text = "$($Obj.os.FreePhysicalMemory | Convert-Size -from 'KB') libres / $($Obj.os.TotalVisibleMemorySize | Convert-Size -from 'KB')"
        $RAMBar.value = (1-($Obj.os.FreePhysicalMemory / $Obj.os.TotalVisibleMemorySize)) * 100
        $SWAP.text = "$($Obj.os.FreeSpaceInPagingFiles | Convert-Size -from 'KB') libres / $($Obj.os.SizeStoredInPagingFiles | Convert-Size -from 'KB')"
        $SWAPBar.value = (1-($Obj.os.FreeSpaceInPagingFiles / $Obj.os.SizeStoredInPagingFiles)) * 100

        if($Obj.Connector.ping) {
            $ICMP.text = '    Repond au ping'
            #$ICMP.ForeColor = [System.Drawing.Color]::blue
            #$ICMP.BackColor = $SrvForm.BackColor
        } else {
            $ICMP.text = '    <!> Connection impossible <!>'
            $ICMP.ForeColor = [System.Drawing.Color]::Red
            $ICMP.BackColor = $SrvForm.BackColor
        }
        if($Obj.Connector.WSMAN){
            $WSMAN.text = '    > Connecteur : Disponible et avtive'
            #$WSMAN.ForeColor = [System.Drawing.Color]::blue
            #$WSMAN.BackColor = $SrvForm.BackColor
        } else {
            $WSMAN.text = '    <!> Connection impossible <!>'
            $WSMAN.ForeColor = [System.Drawing.Color]::Red
            $WSMAN.BackColor = $SrvForm.BackColor
        }
        if($Obj.Connector.RemoteReg){
            $RemoteReg.text = '    > Connecteur : Disponible et avtive'
            #$RemoteReg.ForeColor = [System.Drawing.Color]::blue
            #$RemoteReg.BackColor = $SrvForm.BackColor
        } else {
            $RemoteReg.text = '    <!> Connection impossible <!>'
            $RemoteReg.ForeColor = [System.Drawing.Color]::Red
            $RemoteReg.BackColor = $SrvForm.BackColor
        }
        if($Obj.Connector.RPC) {
            $RPC.text = '    > Connecteur : Disponible et avtive'
            #$RPC.ForeColor = [System.Drawing.Color]::blue
            #$RPC.BackColor = $SrvForm.BackColor
        } else {
            $RPC.text = '    <!> Connection impossible <!>'
            $RPC.ForeColor = [System.Drawing.Color]::Red
            $RPC.BackColor = $SrvForm.BackColor
        }
        if($Obj.PSSession) {
            $PS.text = '    > Connecteur : Disponible et avtive'
            #$PS.ForeColor = [System.Drawing.Color]::blue
            #$PS.BackColor = $SrvForm.BackColor
        } else {
            $PS.text = '    <!> Connection impossible <!>'
            $PS.ForeColor = [System.Drawing.Color]::Red
            $PS.BackColor = $SrvForm.BackColor
        }
        if($Obj.Connector.RDP) {
            $RDP.text = '    > Connecteur : Disponible et avtive'
            #$RDP.ForeColor = [System.Drawing.Color]::blue
            #$RDP.BackColor = $SrvForm.BackColor
        } else {
            $RDP.text = '    <!> Connection impossible <!>'
            $RDP.ForeColor = [System.Drawing.Color]::Red
            $RDP.BackColor = $SrvForm.BackColor
        }
        if($Obj.Connector.SMB) {
            $SMB.text = '    > Connecteur : Disponible et avtive'
            #$SMB.ForeColor = [System.Drawing.Color]::blue
            #$SMB.BackColor = $SrvForm.BackColor
        } else {
            $SMB.text = '    <!> Connection impossible <!>'
            $SMB.ForeColor = [System.Drawing.Color]::Red
            $SMB.BackColor = $SrvForm.BackColor
        }
        
        $MAC.text = $obj.NetWork.MACAddress
        $DNS.text = $obj.NetWork.DNSServerSearchOrder -join(', ')
        $GateWay.text = $obj.NetWork.DefaultIPGateway -join(', ')
        $MASK.text = $obj.NetWork.IPSubnet -join(', ')
        $IP.text = $obj.NetWork.IPAddress -join(', ')
        if(!$Obj.NetWork.DHCPEnabled) {
            $DHCP.text = '    IP Fixe'
        } else {
            $DHCP.text = '    <!> LE DHCP EST ACTIVE <!>'
            $DHCP.ForeColor = [System.Drawing.Color]::Red
            $DHCP.BackColor = $SrvForm.BackColor
        }

        $DisksString = @()
        $DisksString = $obj.Disks | %{
            $str="$($_.DeviceID)\  ($($_.FileSystem))".padright(12)
            $str+=": $($_.FreeSpace | Convert-Size) libres".padright(16)
            $str+=" / $($_.Size | Convert-Size)".padright(15)
            $str+="soit $([Math]::Round(($_.FreeSpace/$_.Size)*100,1))%"
            $str
        }
        [System.Void]$DisksList.Items.AddRange($DisksString)
        
        $SharesString = @()
        $SharesString = $obj.shares | %{
            $str = "$($_.Name)".padright(15)
            $str += "$($_.ShareState)".padright(8)
            $str += "$($_.Path)".padright(32)
            $str += "$($_.CurrentUsers) / $(if (!$_.ConcurrentUserLimit) {'Infini'} else {$_.ConcurrentUserLimit})".padright(14)
            $str += "$(if ($_.EncryptData) {'Chiffres'} else {'Non Chiffres'} )".padright(12)
            $str += "$($_.Description)".padright(12)
            $str
        }
        [System.Void]$Shares.Items.AddRange($SharesString)
    }

    function Convert-Size {
        [cmdletbinding()]
        param(
            [Parameter(Mandatory=$True,ValueFromPipeline=$True)] 
            [double]$Value,
            [validateset("Bytes","KB","MB","GB","TB","PB")]
                [string]$From='Bytes',
            [validateset("Bytes","KB","MB","GB","TB","PB")]
                [string]$To="Auto",
            [int]$Precision = 2
        ) 
        switch($From) {
            "Bytes" {$value = $Value }
            "KB" {$value = $Value * 1024 }
            "MB" {$value = $Value * 1024 * 1024}
            "GB" {$value = $Value * 1024 * 1024 * 1024}
            "TB" {$value = $Value * 1024 * 1024 * 1024 * 1024}
            "PB" {$value = $Value * 1024 * 1024 * 1024 * 1024 * 1024}
        }
        if ($to -eq "Auto") {
            if     ($value -gt 1024 * 1024 * 1024 * 1024 * 1024 ) {$To="PB"}
            elseif ($value -gt 1024 * 1024 * 1024 * 1024 ) {$To="TB"}
            elseif ($value -gt 1024 * 1024 * 1024 ) {$To="GB"}
            elseif ($value -gt 1024 * 1024 ) {$To="MB"}
            elseif ($value -gt 1024 ) {$To="KB"}
            else {$To="Bytes"}
        }
        switch ($To) {
            "Bytes" {return $value}
            "KB" {$Value = $Value/1KB}
            "MB" {$Value = $Value/1MB}
            "GB" {$Value = $Value/1GB}
            "TB" {$Value = $Value/1TB}
            "PB" {$Value = $Value/1PB}
        }
        return "$([Math]::Round($value,$Precision)) $to"
    }

    function Get-MachineType ($Serial) {
        if ($bios.serialnumber -like "VMware-*") {
            return "Virtuel"
        } else {
            Return "Physique"
        }
    }

    Function Invoke-Ping {
        <#
            .SYNOPSIS
                Ping or test connectivity to systems in parallel
                
            .DESCRIPTION
                Ping or test connectivity to systems in parallel

                Default action will run a ping against systems
                    If Quiet parameter is specified, we return an array of systems that responded
                    If Detail parameter is specified, we test WSMan, RemoteReg, RPC, RDP and/or SMB

            .PARAMETER ComputerName
                One or more computers to test

            .PARAMETER Quiet
                If specified, only return addresses that responded to Test-Connection

            .PARAMETER Detail
                Include one or more additional tests as specified:
                    WSMan      via Test-WSMan
                    RemoteReg  via Microsoft.Win32.RegistryKey
                    RPC        via WMI
                    RDP        via port 3389
                    SMB        via \\ComputerName\C$
                    *          All tests

            .PARAMETER Timeout
                Time in seconds before we attempt to dispose an individual query.  Default is 20

            .PARAMETER Throttle
                Throttle query to this many parallel runspaces.  Default is 100.

            .PARAMETER NoCloseOnTimeout
                Do not dispose of timed out tasks or attempt to close the runspace if threads have timed out

                This will prevent the script from hanging in certain situations where threads become non-responsive, at the expense of leaking memory within the PowerShell host.

            .EXAMPLE
                Invoke-Ping Server1, Server2, Server3 -Detail *

                # Check for WSMan, Remote Registry, Remote RPC, RDP, and SMB (via C$) connectivity against 3 machines

            .EXAMPLE
                $Computers | Invoke-Ping

                # Ping computers in $Computers in parallel

            .EXAMPLE
                $Responding = $Computers | Invoke-Ping -Quiet
                
                # Create a list of computers that successfully responded to Test-Connection

            .LINK
                https://gallery.technet.microsoft.com/scriptcenter/Invoke-Ping-Test-in-b553242a

            .FUNCTIONALITY
                Computers

        #>
        [cmdletbinding(DefaultParameterSetName='Ping')]
        param(
            [Parameter( ValueFromPipeline=$true,
                        ValueFromPipelineByPropertyName=$true, 
                        Position=0)]
            [string[]]$ComputerName,
            
            [Parameter( ParameterSetName='Detail')]
            [validateset("*","WSMan","RemoteReg","RPC","RDP","SMB")]
            [string[]]$Detail,
            
            [Parameter(ParameterSetName='Ping')]
            [switch]$Quiet,
            
            [int]$Timeout = 20,
            
            [int]$Throttle = 100,

            [switch]$NoCloseOnTimeout
        )
        Begin
        {

            #http://gallery.technet.microsoft.com/Run-Parallel-Parallel-377fd430
            function Invoke-Parallel {
                [cmdletbinding(DefaultParameterSetName='ScriptBlock')]
                Param (   
                    [Parameter(Mandatory=$false,position=0,ParameterSetName='ScriptBlock')]
                        [System.Management.Automation.ScriptBlock]$ScriptBlock,

                    [Parameter(Mandatory=$false,ParameterSetName='ScriptFile')]
                    [ValidateScript({test-path $_ -pathtype leaf})]
                        $ScriptFile,

                    [Parameter(Mandatory=$true,ValueFromPipeline=$true)]
                    [Alias('CN','__Server','IPAddress','Server','ComputerName')]    
                        [PSObject]$InputObject,

                        [PSObject]$Parameter,

                        [switch]$ImportVariables,

                        [switch]$ImportModules,

                        [int]$Throttle = 20,

                        [int]$SleepTimer = 200,

                        [int]$RunspaceTimeout = 0,

                        [switch]$NoCloseOnTimeout = $false,

                        [int]$MaxQueue,

                    [validatescript({Test-Path (Split-Path $_ -parent)})]
                        [string]$LogFile = "C:\temp\log.log",

                        [switch] $Quiet = $false
                )
        
                Begin {
                    
                    #No max queue specified?  Estimate one.
                    #We use the script scope to resolve an odd PowerShell 2 issue where MaxQueue isn't seen later in the function
                    if( -not $PSBoundParameters.ContainsKey('MaxQueue') )
                    {
                        if($RunspaceTimeout -ne 0){ $script:MaxQueue = $Throttle }
                        else{ $script:MaxQueue = $Throttle * 3 }
                    }
                    else
                    {
                        $script:MaxQueue = $MaxQueue
                    }

                    Write-Verbose "Throttle: '$throttle' SleepTimer '$sleepTimer' runSpaceTimeout '$runspaceTimeout' maxQueue '$maxQueue' logFile '$logFile'"

                    #If they want to import variables or modules, create a clean runspace, get loaded items, use those to exclude items
                    if ($ImportVariables -or $ImportModules)
                    {
                        $StandardUserEnv = [powershell]::Create().addscript({

                            #Get modules and snapins in this clean runspace
                            $Modules = Get-Module | Select -ExpandProperty Name
                            $Snapins = Get-PSSnapin | Select -ExpandProperty Name

                            #Get variables in this clean runspace
                            #Called last to get vars like $? into session
                            $Variables = Get-Variable | Select -ExpandProperty Name
                    
                            #Return a hashtable where we can access each.
                            @{
                                Variables = $Variables
                                Modules = $Modules
                                Snapins = $Snapins
                            }
                        }).invoke()[0]
                
                        if ($ImportVariables) {
                            #Exclude common parameters, bound parameters, and automatic variables
                            Function _temp {[cmdletbinding()] param() }
                            $VariablesToExclude = @( (Get-Command _temp | Select -ExpandProperty parameters).Keys + $PSBoundParameters.Keys + $StandardUserEnv.Variables )
                            Write-Verbose "Excluding variables $( ($VariablesToExclude | sort ) -join ", ")"

                            # we don't use 'Get-Variable -Exclude', because it uses regexps. 
                            # One of the veriables that we pass is '$?'. 
                            # There could be other variables with such problems.
                            # Scope 2 required if we move to a real module
                            $UserVariables = @( Get-Variable | Where { -not ($VariablesToExclude -contains $_.Name) } ) 
                            Write-Verbose "Found variables to import: $( ($UserVariables | Select -expandproperty Name | Sort ) -join ", " | Out-String).`n"

                        }

                        if ($ImportModules) 
                        {
                            $UserModules = @( Get-Module | Where {$StandardUserEnv.Modules -notcontains $_.Name -and (Test-Path $_.Path -ErrorAction SilentlyContinue)} | Select -ExpandProperty Path )
                            $UserSnapins = @( Get-PSSnapin | Select -ExpandProperty Name | Where {$StandardUserEnv.Snapins -notcontains $_ } ) 
                        }
                    }

                    #region functions
                
                        Function Get-RunspaceData {
                            [cmdletbinding()]
                            param( [switch]$Wait )

                            #loop through runspaces
                            #if $wait is specified, keep looping until all complete
                            Do {

                                #set more to false for tracking completion
                                $more = $false

                                #Progress bar if we have inputobject count (bound parameter)
                                if (-not $Quiet) {
                                    Write-Progress  -Activity "Running Query" -Status "Starting threads"`
                                        -CurrentOperation "$startedCount threads defined - $totalCount input objects - $script:completedCount input objects processed"`
                                        -PercentComplete $( Try { $script:completedCount / $totalCount * 100 } Catch {0} )
                                }

                                #run through each runspace.           
                                Foreach($runspace in $runspaces) {
                        
                                    #get the duration - inaccurate
                                    $currentdate = Get-Date
                                    $runtime = $currentdate - $runspace.startTime
                                    $runMin = [math]::Round( $runtime.totalminutes ,2 )

                                    #set up log object
                                    $log = "" | select Date, Action, Runtime, Status, Details
                                    $log.Action = "Removing:'$($runspace.object)'"
                                    $log.Date = $currentdate
                                    $log.Runtime = "$runMin minutes"

                                    #If runspace completed, end invoke, dispose, recycle, counter++
                                    If ($runspace.Runspace.isCompleted) {
                                
                                        $script:completedCount++
                            
                                        #check if there were errors
                                        if($runspace.powershell.Streams.Error.Count -gt 0) {
                                    
                                            #set the logging info and move the file to completed
                                            $log.status = "CompletedWithErrors"
                                            Write-Verbose ($log | ConvertTo-Csv -Delimiter ";" -NoTypeInformation)[1]
                                            foreach($ErrorRecord in $runspace.powershell.Streams.Error) {
                                                Write-Error -ErrorRecord $ErrorRecord
                                            }
                                        }
                                        else {
                                    
                                            #add logging details and cleanup
                                            $log.status = "Completed"
                                            Write-Verbose ($log | ConvertTo-Csv -Delimiter ";" -NoTypeInformation)[1]
                                        }

                                        #everything is logged, clean up the runspace
                                        $runspace.powershell.EndInvoke($runspace.Runspace)
                                        $runspace.powershell.dispose()
                                        $runspace.Runspace = $null
                                        $runspace.powershell = $null

                                    }

                                    #If runtime exceeds max, dispose the runspace
                                    ElseIf ( $runspaceTimeout -ne 0 -and $runtime.totalseconds -gt $runspaceTimeout) {
                                
                                        $script:completedCount++
                                        $timedOutTasks = $true
                                
                                        #add logging details and cleanup
                                        $log.status = "TimedOut"
                                        Write-Verbose ($log | ConvertTo-Csv -Delimiter ";" -NoTypeInformation)[1]
                                        Write-Error "Runspace timed out at $($runtime.totalseconds) seconds for the object:`n$($runspace.object | out-string)"

                                        #Depending on how it hangs, we could still get stuck here as dispose calls a synchronous method on the powershell instance
                                        if (!$noCloseOnTimeout) { $runspace.powershell.dispose() }
                                        $runspace.Runspace = $null
                                        $runspace.powershell = $null
                                        $completedCount++

                                    }
                       
                                    #If runspace isn't null set more to true  
                                    ElseIf ($runspace.Runspace -ne $null ) {
                                        $log = $null
                                        $more = $true
                                    }

                                    #log the results if a log file was indicated
                                    if($logFile -and $log){
                                        ($log | ConvertTo-Csv -Delimiter ";" -NoTypeInformation)[1] | out-file $LogFile -append
                                    }
                                }

                                #Clean out unused runspace jobs
                                $temphash = $runspaces.clone()
                                $temphash | Where { $_.runspace -eq $Null } | ForEach {
                                    $Runspaces.remove($_)
                                }

                                #sleep for a bit if we will loop again
                                if($PSBoundParameters['Wait']){ Start-Sleep -milliseconds $SleepTimer }

                            #Loop again only if -wait parameter and there are more runspaces to process
                            } while ($more -and $PSBoundParameters['Wait'])
                    
                        #End of runspace function
                        }

                    #endregion functions
            
                    #region Init

                        if($PSCmdlet.ParameterSetName -eq 'ScriptFile')
                        {
                            $ScriptBlock = [scriptblock]::Create( $(Get-Content $ScriptFile | out-string) )
                        }
                        elseif($PSCmdlet.ParameterSetName -eq 'ScriptBlock')
                        {
                            #Start building parameter names for the param block
                            [string[]]$ParamsToAdd = '$_'
                            if( $PSBoundParameters.ContainsKey('Parameter') )
                            {
                                $ParamsToAdd += '$Parameter'
                            }

                            $UsingVariableData = $Null
                    

                            # This code enables $Using support through the AST.
                            # This is entirely from  Boe Prox, and his https://github.com/proxb/PoshRSJob module; all credit to Boe!
                    
                            if($PSVersionTable.PSVersion.Major -gt 2)
                            {
                                #Extract using references
                                $UsingVariables = $ScriptBlock.ast.FindAll({$args[0] -is [System.Management.Automation.Language.UsingExpressionAst]},$True)    

                                If ($UsingVariables)
                                {
                                    $List = New-Object 'System.Collections.Generic.List`1[System.Management.Automation.Language.VariableExpressionAst]'
                                    ForEach ($Ast in $UsingVariables)
                                    {
                                        [void]$list.Add($Ast.SubExpression)
                                    }

                                    $UsingVar = $UsingVariables | Group Parent | ForEach {$_.Group | Select -First 1}
            
                                    #Extract the name, value, and create replacements for each
                                    $UsingVariableData = ForEach ($Var in $UsingVar) {
                                        Try
                                        {
                                            $Value = Get-Variable -Name $Var.SubExpression.VariablePath.UserPath -ErrorAction Stop
                                            $NewName = ('$__using_{0}' -f $Var.SubExpression.VariablePath.UserPath)
                                            [pscustomobject]@{
                                                Name = $Var.SubExpression.Extent.Text
                                                Value = $Value.Value
                                                NewName = $NewName
                                                NewVarName = ('__using_{0}' -f $Var.SubExpression.VariablePath.UserPath)
                                            }
                                            $ParamsToAdd += $NewName
                                        }
                                        Catch
                                        {
                                            Write-Error "$($Var.SubExpression.Extent.Text) is not a valid Using: variable!"
                                        }
                                    }
        
                                    $NewParams = $UsingVariableData.NewName -join ', '
                                    $Tuple = [Tuple]::Create($list, $NewParams)
                                    $bindingFlags = [Reflection.BindingFlags]"Default,NonPublic,Instance"
                                    $GetWithInputHandlingForInvokeCommandImpl = ($ScriptBlock.ast.gettype().GetMethod('GetWithInputHandlingForInvokeCommandImpl',$bindingFlags))
            
                                    $StringScriptBlock = $GetWithInputHandlingForInvokeCommandImpl.Invoke($ScriptBlock.ast,@($Tuple))

                                    $ScriptBlock = [scriptblock]::Create($StringScriptBlock)

                                    Write-Verbose $StringScriptBlock
                                }
                            }
                    
                            $ScriptBlock = $ExecutionContext.InvokeCommand.NewScriptBlock("param($($ParamsToAdd -Join ", "))`r`n" + $Scriptblock.ToString())
                        }
                        else
                        {
                            Throw "Must provide ScriptBlock or ScriptFile"; Break
                        }

                        Write-Debug "`$ScriptBlock: $($ScriptBlock | Out-String)"
                        Write-Verbose "Creating runspace pool and session states"

                        #If specified, add variables and modules/snapins to session state
                        $sessionstate = [System.Management.Automation.Runspaces.InitialSessionState]::CreateDefault()
                        if ($ImportVariables)
                        {
                            if($UserVariables.count -gt 0)
                            {
                                foreach($Variable in $UserVariables)
                                {
                                    $sessionstate.Variables.Add( (New-Object -TypeName System.Management.Automation.Runspaces.SessionStateVariableEntry -ArgumentList $Variable.Name, $Variable.Value, $null) )
                                }
                            }
                        }
                        if ($ImportModules)
                        {
                            if($UserModules.count -gt 0)
                            {
                                foreach($ModulePath in $UserModules)
                                {
                                    $sessionstate.ImportPSModule($ModulePath)
                                }
                            }
                            if($UserSnapins.count -gt 0)
                            {
                                foreach($PSSnapin in $UserSnapins)
                                {
                                    [void]$sessionstate.ImportPSSnapIn($PSSnapin, [ref]$null)
                                }
                            }
                        }

                        #Create runspace pool
                        $runspacepool = [runspacefactory]::CreateRunspacePool(1, $Throttle, $sessionstate, $Host)
                        $runspacepool.Open() 

                        Write-Verbose "Creating empty collection to hold runspace jobs"
                        $Script:runspaces = New-Object System.Collections.ArrayList        
            
                        #If inputObject is bound get a total count and set bound to true
                        $global:__bound = $false
                        $allObjects = @()
                        if( $PSBoundParameters.ContainsKey("inputObject") ){
                            $global:__bound = $true
                        }

                        #Set up log file if specified
                        if( $LogFile ){
                            New-Item -ItemType file -path $logFile -force | Out-Null
                            ("" | Select Date, Action, Runtime, Status, Details | ConvertTo-Csv -NoTypeInformation -Delimiter ";")[0] | Out-File $LogFile
                        }

                        #write initial log entry
                        $log = "" | Select Date, Action, Runtime, Status, Details
                            $log.Date = Get-Date
                            $log.Action = "Batch processing started"
                            $log.Runtime = $null
                            $log.Status = "Started"
                            $log.Details = $null
                            if($logFile) {
                                ($log | convertto-csv -Delimiter ";" -NoTypeInformation)[1] | Out-File $LogFile -Append
                            }

                        $timedOutTasks = $false

                    #endregion INIT
                }

                Process {

                    #add piped objects to all objects or set all objects to bound input object parameter
                    if( -not $global:__bound ){
                        $allObjects += $inputObject
                    }
                    else{
                        $allObjects = $InputObject
                    }
                }

                End {
            
                    #Use Try/Finally to catch Ctrl+C and clean up.
                    Try
                    {
                        #counts for progress
                        $totalCount = $allObjects.count
                        $script:completedCount = 0
                        $startedCount = 0

                        foreach($object in $allObjects){
            
                            #region add scripts to runspace pool
                        
                                #Create the powershell instance, set verbose if needed, supply the scriptblock and parameters
                                $powershell = [powershell]::Create()
                        
                                if ($VerbosePreference -eq 'Continue')
                                {
                                    [void]$PowerShell.AddScript({$VerbosePreference = 'Continue'})
                                }

                                [void]$PowerShell.AddScript($ScriptBlock).AddArgument($object)

                                if ($parameter)
                                {
                                    [void]$PowerShell.AddArgument($parameter)
                                }

                                # $Using support from Boe Prox
                                if ($UsingVariableData)
                                {
                                    Foreach($UsingVariable in $UsingVariableData) {
                                        Write-Verbose "Adding $($UsingVariable.Name) with value: $($UsingVariable.Value)"
                                        [void]$PowerShell.AddArgument($UsingVariable.Value)
                                    }
                                }

                                #Add the runspace into the powershell instance
                                $powershell.RunspacePool = $runspacepool
        
                                #Create a temporary collection for each runspace
                                $temp = "" | Select-Object PowerShell, StartTime, object, Runspace
                                $temp.PowerShell = $powershell
                                $temp.StartTime = Get-Date
                                $temp.object = $object
        
                                #Save the handle output when calling BeginInvoke() that will be used later to end the runspace
                                $temp.Runspace = $powershell.BeginInvoke()
                                $startedCount++

                                #Add the temp tracking info to $runspaces collection
                                Write-Verbose ( "Adding {0} to collection at {1}" -f $temp.object, $temp.starttime.tostring() )
                                $runspaces.Add($temp) | Out-Null
                
                                #loop through existing runspaces one time
                                Get-RunspaceData

                                #If we have more running than max queue (used to control timeout accuracy)
                                #Script scope resolves odd PowerShell 2 issue
                                $firstRun = $true
                                while ($runspaces.count -ge $Script:MaxQueue) {

                                    #give verbose output
                                    if($firstRun){
                                        Write-Verbose "$($runspaces.count) items running - exceeded $Script:MaxQueue limit."
                                    }
                                    $firstRun = $false
                        
                                    #run get-runspace data and sleep for a short while
                                    Get-RunspaceData
                                    Start-Sleep -Milliseconds $sleepTimer
                        
                                }

                            #endregion add scripts to runspace pool
                        }
                         
                        Write-Verbose ( "Finish processing the remaining runspace jobs: {0}" -f ( @($runspaces | Where {$_.Runspace -ne $Null}).Count) )
                        Get-RunspaceData -wait

                        if (-not $quiet) {
                            Write-Progress -Activity "Running Query" -Status "Starting threads" -Completed
                        }

                    }
                    Finally
                    {
                        #Close the runspace pool, unless we specified no close on timeout and something timed out
                        if ( ($timedOutTasks -eq $false) -or ( ($timedOutTasks -eq $true) -and ($noCloseOnTimeout -eq $false) ) ) {
                            Write-Verbose "Closing the runspace pool"
                            $runspacepool.close()
                        }

                        #collect garbage
                        [gc]::Collect()
                    }       
                }
            }

            Write-Verbose "PSBoundParameters = $($PSBoundParameters | Out-String)"
            
            $bound = $PSBoundParameters.keys -contains "ComputerName"
            if(-not $bound)
            {
                [System.Collections.ArrayList]$AllComputers = @()
            }
        }
        Process
        {

            #Handle both pipeline and bound parameter.  We don't want to stream objects, defeats purpose of parallelizing work
            if($bound)
            {
                $AllComputers = $ComputerName
            }
            Else
            {
                foreach($Computer in $ComputerName)
                {
                    $AllComputers.add($Computer) | Out-Null
                }
            }

        }
        End
        {

            #Built up the parameters and run everything in parallel
            $params = @($Detail, $Quiet)
            $splat = @{
                Throttle = $Throttle
                RunspaceTimeout = $Timeout
                InputObject = $AllComputers
                parameter = $params
            }
            if($NoCloseOnTimeout)
            {
                $splat.add('NoCloseOnTimeout',$True)
            }

            Invoke-Parallel @splat -ScriptBlock {
            
                $computer = $_.trim()
                $detail = $parameter[0]
                $quiet = $parameter[1]

                #They want detail, define and run test-server
                if($detail)
                {
                    Try
                    {
                        #Modification of jrich's Test-Server function: https://gallery.technet.microsoft.com/scriptcenter/Powershell-Test-Server-e0cdea9a
                        Function Test-Server{
                            [cmdletBinding()]
                            param(
                                [parameter(
                                    Mandatory=$true,
                                    ValueFromPipeline=$true)]
                                [string[]]$ComputerName,
                                [switch]$All,
                                [parameter(Mandatory=$false)]
                                [switch]$CredSSP,
                                [switch]$RemoteReg,
                                [switch]$RDP,
                                [switch]$RPC,
                                [switch]$SMB,
                                [switch]$WSMAN,
                                [switch]$IPV6,
                                [Management.Automation.PSCredential]$Credential
                            )
                                begin
                                {
                                    $total = Get-Date
                                    $results = @()
                                    if($credssp -and -not $Credential)
                                    {
                                        Throw "Must supply Credentials with CredSSP test"
                                    }

                                    [string[]]$props = write-output Name, IP, Domain, ResponseTime, Ping, WSMAN, CredSSP, RemoteReg, RPC, RDP, SMB

                                    #Hash table to create PSObjects later, compatible with ps2...
                                    $Hash = @{}
                                    foreach($prop in $props)
                                    {
                                        $Hash.Add($prop,$null)
                                    }

                                    function Test-Port{
                                        [cmdletbinding()]
                                        Param(
                                            [string]$srv,
                                            $port=135,
                                            $timeout=3000
                                        )
                                        $ErrorActionPreference = "SilentlyContinue"
                                        $tcpclient = new-Object system.Net.Sockets.TcpClient
                                        $iar = $tcpclient.BeginConnect($srv,$port,$null,$null)
                                        $wait = $iar.AsyncWaitHandle.WaitOne($timeout,$false)
                                        if(-not $wait)
                                        {
                                            $tcpclient.Close()
                                            Write-Verbose "Connection Timeout to $srv`:$port"
                                            $false
                                        }
                                        else
                                        {
                                            Try
                                            {
                                                $tcpclient.EndConnect($iar) | out-Null
                                                $true
                                            }
                                            Catch
                                            {
                                                write-verbose "Error for $srv`:$port`: $_"
                                                $false
                                            }
                                            $tcpclient.Close()
                                        }
                                    }
                                }

                                process
                                {
                                    foreach($name in $computername)
                                    {
                                        $dt = $cdt= Get-Date
                                        Write-verbose "Testing: $Name"
                                        $failed = 0
                                        try{
                                            $DNSEntity = [Net.Dns]::GetHostEntry($name)
                                            $domain = ($DNSEntity.hostname).replace("$name.","")
                                            $ips = $DNSEntity.AddressList | %{
                                                if(-not ( -not $IPV6 -and $_.AddressFamily -like "InterNetworkV6" ))
                                                {
                                                    $_.IPAddressToString
                                                }
                                            }
                                        }
                                        catch
                                        {
                                            $rst = New-Object -TypeName PSObject -Property $Hash | Select -Property $props
                                            $rst.name = $name
                                            $results += $rst
                                            $failed = 1
                                        }
                                        Write-verbose "DNS:  $((New-TimeSpan $dt ($dt = get-date)).totalseconds)"
                                        if($failed -eq 0){
                                            foreach($ip in $ips)
                                            {
            
                                                $rst = New-Object -TypeName PSObject -Property $Hash | Select -Property $props
                                                $rst.name = $name
                                                $rst.ip = $ip
                                                $rst.domain = $domain
                                                $rst.ResponseTime = 0
                        
                                                if($RDP -or $All)
                                                {
                                                    ####RDP Check (firewall may block rest so do before ping
                                                    try{
                                                        $socket = New-Object Net.Sockets.TcpClient($name, 3389) -ErrorAction stop
                                                        if($socket -eq $null)
                                                        {
                                                            $rst.RDP = $false
                                                        }
                                                        else
                                                        {
                                                            $rst.RDP = $true
                                                            $socket.close()
                                                        }
                                                    }
                                                    catch
                                                    {
                                                        $rst.RDP = $false
                                                        Write-Verbose "Error testing RDP: $_"
                                                    }
                                                }
                                            Write-verbose "RDP:  $((New-TimeSpan $dt ($dt = get-date)).totalseconds)"
                                            #########ping
                                            if(test-connection $ip -count 2 -Quiet)
                                            {
                                                Write-verbose "PING:  $((New-TimeSpan $dt ($dt = get-date)).totalseconds)"
                                                $rst.ping = $true
                    
                                                if($WSMAN -or $All)
                                                {
                                                    try{############wsman
                                                        Test-WSMan $ip -ErrorAction stop | Out-Null
                                                        $rst.WSMAN = $true
                                                    }
                                                    catch
                                                    {
                                                        $rst.WSMAN = $false
                                                        Write-Verbose "Error testing WSMAN: $_"
                                                    }
                                                    Write-verbose "WSMAN:  $((New-TimeSpan $dt ($dt = get-date)).totalseconds)"
                                                    if($rst.WSMAN -and $credssp) ########### credssp
                                                    {
                                                        try{
                                                            Test-WSMan $ip -Authentication Credssp -Credential $cred -ErrorAction stop
                                                            $rst.CredSSP = $true
                                                        }
                                                        catch
                                                        {
                                                            $rst.CredSSP = $false
                                                            Write-Verbose "Error testing CredSSP: $_"
                                                        }
                                                        Write-verbose "CredSSP:  $((New-TimeSpan $dt ($dt = get-date)).totalseconds)"
                                                    }
                                                }
                                                if($RemoteReg -or $All)
                                                {
                                                    try ########remote reg
                                                    {
                                                        [Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey([Microsoft.Win32.RegistryHive]::LocalMachine, $ip) | Out-Null
                                                        $rst.remotereg = $true
                                                    }
                                                    catch
                                                    {
                                                        $rst.remotereg = $false
                                                        Write-Verbose "Error testing RemoteRegistry: $_"
                                                    }
                                                    Write-verbose "remote reg:  $((New-TimeSpan $dt ($dt = get-date)).totalseconds)"
                                                }
                                                if($RPC -or $All)
                                                {
                                                    try ######### wmi
                                                    {   
                                                        $w = [wmi] ''
                                                        $w.psbase.options.timeout = 15000000
                                                        $w.path = "\\$Name\root\cimv2:Win32_ComputerSystem.Name='$($Name.split('.')[0])'"
                                                        $w | select none | Out-Null
                                                        $rst.RPC = $true
                                                    }
                                                    catch
                                                    {
                                                        $rst.rpc = $false
                                                        Write-Verbose "Error testing WMI/RPC: $_"
                                                    }
                                                    Write-verbose "WMI/RPC:  $((New-TimeSpan $dt ($dt = get-date)).totalseconds)"
                                                }
                                                if($SMB -or $All)
                                                {

                                                    #Use set location and resulting errors.  push and pop current location
                                                    try ######### C$
                                                    {   
                                                        $path = "\\$name\c$"
                                                        Push-Location -Path $path -ErrorAction stop
                                                        $rst.SMB = $true
                                                        Pop-Location
                                                    }
                                                    catch
                                                    {
                                                        $rst.SMB = $false
                                                        Write-Verbose "Error testing SMB: $_"
                                                    }
                                                    Write-verbose "SMB:  $((New-TimeSpan $dt ($dt = get-date)).totalseconds)"

                                                }
                                            }
                                            else
                                            {
                                                $rst.ping = $false
                                                $rst.wsman = $false
                                                $rst.credssp = $false
                                                $rst.remotereg = $false
                                                $rst.rpc = $false
                                                $rst.smb = $false
                                            }
                                            $results += $rst    
                                        }
                                    }
                                    Write-Verbose "Time for $($Name): $((New-TimeSpan $cdt ($dt)).totalseconds)"
                                    Write-Verbose "----------------------------"
                                    }
                                }
                                end
                                {
                                    Write-Verbose "Time for all: $((New-TimeSpan $total ($dt)).totalseconds)"
                                    Write-Verbose "----------------------------"
                                    return $results
                                }
                            }
                        
                        #Build up parameters for Test-Server and run it
                            $TestServerParams = @{
                                ComputerName = $Computer
                                ErrorAction = "Stop"
                            }

                            if($detail -eq "*"){
                                $detail = "WSMan","RemoteReg","RPC","RDP","SMB" 
                            }

                            $detail | Select -Unique | Foreach-Object { $TestServerParams.add($_,$True) }
                            Test-Server @TestServerParams | Select -Property $( "Name", "IP", "Domain", "Ping" + $detail )
                    }
                    Catch
                    {
                        Write-Warning "Error with Test-Server: $_"
                    }
                }
                #We just want ping output
                else
                {
                    Try
                    {
                        #Pick out a few properties, add a status label.  If quiet output, just return the address
                        $result = $null
                        if( $result = @( Test-Connection -ComputerName $computer -Count 2 -erroraction Stop ) )
                        {
                            $Output = $result | Select -first 1 -Property Address,
                                                                          IPV4Address,
                                                                          IPV6Address,
                                                                          ResponseTime,
                                                                          @{ label = "STATUS"; expression = {"Responding"} }

                            if( $quiet )
                            {
                                $Output.address
                            }
                            else
                            {
                                $Output
                            }
                        }
                    }
                    Catch
                    {
                        if(-not $quiet)
                        {
                            #Ping failed.  I'm likely making inappropriate assumptions here, let me know if this is the case : )
                            if($_ -match "No such host is known")
                            {
                                $status = "Unknown host"
                            }
                            elseif($_ -match "Error due to lack of resources")
                            {
                                $status = "No Response"
                            }
                            else
                            {
                                $status = "Error: $_"
                            }

                            "" | Select -Property @{ label = "Address"; expression = {$computer} },
                                                  IPV4Address,
                                                  IPV6Address,
                                                  ResponseTime,
                                                  @{ label = "STATUS"; expression = {$status} }
                        }
                    }
                }
            }
        }
    }

    function New-BalloonNotification {
        <#
            .SYNOPSIS
                The New-BalloonNotification function will show a message to the user in the notification area of Windows.
            
            .DESCRIPTION
                The New-BalloonNotification function will show a message to the user in the notification area of Windows.
            
            .PARAMETER BalloonIcon
                Specifies the Icon to show. Default is None
            
            .PARAMETER BalloonTipText
                Specifies the Message to show.
            
            .PARAMETER BalloonTipTitle
                Specifies the Title to show.
            
            .PARAMETER CustomIconPath
                Specifies the custom icon literal path to use. Default will use the PowerShell icon.
            
            .PARAMETER TimeOut
                Specifies the display duration of the message. Default is 10000 milliseconds
            
            .EXAMPLE
                PS C:\> New-BalloonNotification -BalloonTipText "test" -BalloonTipTitle "Title" -BalloonIcon Error
            
            .NOTES
                Francois-Xavier Cat
                @lazywinadm
                www.lazywinadmin.com
        #>
        [CmdletBinding()]
        PARAM (
            [String]$CustomIconPath = "C:\Windows\WinSxS\amd64_microsoft-windows-dxp-deviceexperience_31bf3856ad364e35_10.0.9926.0_none_220133b3b110f55a\sync.ico",
        
            [int]$TimeOut = "10000",
        
            [ValidateSet('None', 'Info', 'Warning', 'Error')]
            $BalloonIcon = "None",
            $BalloonTipText,
            $BalloonTipTitle
        )
        BEGIN
        {
            Add-Type -AssemblyName System.Windows.Forms
            #[void][System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms")
        }
        PROCESS
        {
            
            # Create Balloon Notification object
            $BalloonNotification = New-Object -TypeName System.Windows.Forms.NotifyIcon
            
            IF ($PSBoundParameters["CustomIconPath"]) { $BalloonNotification.Icon = $CustomIconPath }
            ELSE
            {
                # Get the Icon of PowerShell
                $path = Get-Process -id $pid | Select-Object -ExpandProperty Path
                $BalloonNotification.Icon = [System.Drawing.Icon]::ExtractAssociatedIcon($path)
            }
            
            # Set properties of the object
            $BalloonNotification.BalloonTipIcon = $BalloonIcon
            $BalloonNotification.BalloonTipText = $BalloonTipText
            $BalloonNotification.BalloonTipTitle = $BalloonTipTitle
            
            $BalloonNotification.Visible = $True
            $BalloonNotification.ShowBalloonTip($TimeOut)
        }
        END
        {
            # Get rid of the Balloon
            #$BalloonNotification.Dispose()
        }
    }

    Function Get-SrvInfos {
       [CmdletBinding()]
        Param(
           [Parameter(Mandatory=$True,ValueFromPipeline=$True)] 
                [string[]]$ComputerName,
            [switch] $full=$false
        )
 
        BEGIN {
            New-BalloonNotification -BalloonTipText "Collecte des informations en cour..." -BalloonTipTitle "$computername" -BalloonIcon Info
        }
         
        PROCESS {
            try {
                $ShareLst = Invoke-Command -ComputerName $computername {Get-SmbShare} -ea stop | select Name,Path,ShareState,Description,EncryptData,CurrentUsers,ConcurrentUserLimit,Online
                $PSSession = $true
            }
            catch {
                $ShareLst = Get-WmiObject Win32_Share -computername $computername | select Name,Path,Description,
                                                                                            @{ label = 'ShareState'; expression = {$_.Status} },
                                                                                            @{ label = 'EncryptData'; expression = {'?'} },
                                                                                            @{ label = 'CurrentUsers'; expression = {'?'} },
                                                                                            @{ label = 'ConcurrentUserLimit'; expression = {$_.ConcurrentUserLimit} },
                                                                                            @{ label = 'Online'; expression = {$_.Status} }
                $PSSession = $false
            }

            Try {
                $bios = Get-WmiObject Win32_BIOS -ComputerName $ComputerName
                $Obj = [pscustomobject][ordered]@{
                    Bios = $bios | select Name,BiosCharacteristics,BIOSVersion,Description,InstallDate,Manufacturer,PrimaryBIOS,ReleaseDate,SerialNumber,SMBIOSBIOSVersion,SMBIOSMajorVersion,SMBIOSMinorVersion,SoftwareElementID,SoftwareElementState,TargetOperatingSystemVersion,ClassPath
                    OS = Get-WmiObject Win32_OperatingSystem -ComputerName $ComputerName | select Name,SystemDrive,FreePhysicalMemory,SizeStoredInPagingFiles,FreeSpaceInPagingFiles,FreeVirtualMemory,Caption,CountryCode,CurrentTimeZone,InstallDate,LastBootUpTime,LocalDateTime,MUILanguages,OSArchitecture,SerialNumber,TotalSwapSpaceSize,TotalVirtualMemorySize,TotalVisibleMemorySize,Version
                    SYS = Get-WmiObject Win32_ComputerSystem -ComputerName $ComputerName | select PSComputerName,NumberOfLogicalProcessors,NumberOfProcessors,AdminPasswordStatus,BootupState,DNSHostName,Domain,PartOfDomain,NetworkServerModeEnabled,NumberOfLogicalProcessorsNumberOfProcessors,SystemType,TotalPhysicalMemory
                    NetWork = Get-WmiObject Win32_NetworkAdapterConfiguration -ComputerName $ComputerName -filter "IPEnabled=True" | select PSComputerName,Description,DHCPEnabled,DNSServerSearchOrder,IPAddress,DefaultIPGateway,IPSubnet,MACAddress
                    Disks = Get-WmiObject Win32_LogicalDisk -ComputerName $ComputerName  -filter "DriveType=3" | select PSComputerName,DeviceID,FileSystem,FreeSpace,Size
                    # TRES lent, dure 2sec | select *
                    CPU = if ($full){ ((Get-WmiObject Win32_Processor -ComputerName $ComputerName).LoadPercentage | Measure-Object -Average) }else{ @{}}
                    Connector = if ($full){ (Invoke-Ping $computername -Detail *) }else{ @{}}
                    MachineType = Get-MachineType ($bios.serialnumber)
                    ComputerName = $bios.PSComputerName
                    PSSession = $PSSession
                    Shares = $ShareLst
                }
            }
            Catch { 
                Write-Error "error $ComputerName"
                return @{}
            }
        }
        END {return $Obj}
    }

    $obj =  Get-SrvInfos $computername -full


    Add-Type -AssemblyName 'System.Drawing'
    Add-Type -AssemblyName 'System.Windows.Forms'

        #region $SrvForm
        $SrvForm = New-Object -TypeName 'System.Windows.Forms.Form'
        $SrvForm.Name = 'SrvForm'
        $SrvForm.KeyPreview = $True
        $SrvForm.Size = New-Object -TypeName 'System.Drawing.Size' -ArgumentList @(500, 365)
        $SrvForm.Padding = New-Object -TypeName 'System.Windows.Forms.Padding' -ArgumentList @(4)
        $SrvForm.add_Load($Get_All)
        $SrvForm.Add_KeyDown({ if ($_.KeyCode -eq 'Escape') {$SrvForm.Close()} })
        $SrvForm.SuspendLayout()
        $font1 = New-Object -TypeName 'System.Drawing.Font' -ArgumentList @('Lucida Console', [System.Single]9, [System.Drawing.FontStyle]::Regular, [System.Drawing.GraphicsUnit]::Point, [System.Byte]1, $false)
        #$Good = New-Object -TypeName 'System.Drawing.Font' -ArgumentList @(, , [System.Drawing.FontStyle]::Regular, [System.Drawing.GraphicsUnit]::Point, [System.Byte]1, $false)
        #$Bad = New-Object -TypeName 'System.Drawing.Font' -ArgumentList @(, , [System.Drawing.FontStyle]::Regular, [System.Drawing.GraphicsUnit]::Point, [System.Byte]1, $false)
        $icon1 = & {
            $iconString = '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'
            $iconStream = New-Object -TypeName 'System.IO.MemoryStream' -ArgumentList @(,([System.Convert]::FromBase64String($iconString)))
            $icon = New-Object -TypeName 'System.Drawing.Icon' -ArgumentList $iconStream
            $iconStream.Dispose()
            return $icon
        }
        $SrvForm.Icon = $icon1

    #region $Tabs
    $Tabs = New-Object -TypeName 'System.Windows.Forms.TabControl'
    $Tabs.Name = 'Tabs'
    $Tabs.Dock = [System.Windows.Forms.DockStyle]::Fill

        #region $tabPage1
        $tabPage1 = New-Object -TypeName 'System.Windows.Forms.TabPage'
        $tabPage1.Padding = New-Object -TypeName 'System.Windows.Forms.Padding' -ArgumentList @(4)
        $tabPage1.Text = 'OS & Charge'
        $tabPage1.SuspendLayout()

            #region $groupBox1
            $groupBox1 = New-Object -TypeName 'System.Windows.Forms.GroupBox'
            $groupBox1.Size = New-Object -TypeName 'System.Drawing.Size' -ArgumentList @(20, 60)
            $groupBox1.Dock = [System.Windows.Forms.DockStyle]::Top
            $groupBox1.Text = 'SWAP / PageFile :'
            $groupBox1.SuspendLayout()

                #region $SWAPBar
                $SWAPBar = New-Object -TypeName 'System.Windows.Forms.ProgressBar'
                $SWAPBar.Dock = [System.Windows.Forms.DockStyle]::Top
                $SWAPBar.Name = 'SWAPBar'
                $SWAPBar.Value = 80
                #endregion $SWAPBar

                [System.Void]$groupBox1.Controls.Add($SWAPBar)

                #region $SWAP
                $SWAP = New-Object -TypeName 'System.Windows.Forms.TextBox'
                $SWAP.Dock = [System.Windows.Forms.DockStyle]::Top
                $SWAP.ReadOnly = $true
                $SWAP.BorderStyle = [System.Windows.Forms.BorderStyle]::None
                $SWAP.Name = 'SWAP'
                $SWAP.TextAlign = [System.Windows.Forms.HorizontalAlignment]::Right
                #endregion $SWAP

                [System.Void]$groupBox1.Controls.Add($SWAP)

            $groupBox1.ResumeLayout($false)
            $groupBox1.PerformLayout()
            #endregion $groupBox1

            [System.Void]$tabPage1.Controls.Add($groupBox1)

            #region $groupBox2
            $groupBox2 = New-Object -TypeName 'System.Windows.Forms.GroupBox'
            $groupBox2.Size = New-Object -TypeName 'System.Drawing.Size' -ArgumentList @(20, 60)
            $groupBox2.Dock = [System.Windows.Forms.DockStyle]::Top
            $groupBox2.Text = 'RAM :'
            $groupBox2.SuspendLayout()

                #region $RAMBar
                $RAMBar = New-Object -TypeName 'System.Windows.Forms.ProgressBar'
                $RAMBar.Dock = [System.Windows.Forms.DockStyle]::Top
                $RAMBar.Name = 'RAMBar'
                $RAMBar.Value = 60
                #endregion $RAMBar

                [System.Void]$groupBox2.Controls.Add($RAMBar)

                #region $RAM
                $RAM = New-Object -TypeName 'System.Windows.Forms.TextBox'
                $RAM.Dock = [System.Windows.Forms.DockStyle]::Top
                $RAM.ReadOnly = $true
                $RAM.BorderStyle = [System.Windows.Forms.BorderStyle]::None
                $RAM.Name = 'RAM'
                $RAM.TextAlign = [System.Windows.Forms.HorizontalAlignment]::Right
                #endregion $RAM

                [System.Void]$groupBox2.Controls.Add($RAM)

            $groupBox2.ResumeLayout($false)
            $groupBox2.PerformLayout()
            #endregion $groupBox2

            [System.Void]$tabPage1.Controls.Add($groupBox2)

            #region $groupBox3
            $groupBox3 = New-Object -TypeName 'System.Windows.Forms.GroupBox'
            $groupBox3.Size = New-Object -TypeName 'System.Drawing.Size' -ArgumentList @(20, 60)
            $groupBox3.Dock = [System.Windows.Forms.DockStyle]::Top
            $groupBox3.Text = 'CPU :'
            $groupBox3.SuspendLayout()

                #region $CPUBar
                $CPUBar = New-Object -TypeName 'System.Windows.Forms.ProgressBar'
                $CPUBar.Dock = [System.Windows.Forms.DockStyle]::Top
                $CPUBar.Name = 'CPUBar'
                $CPUBar.Value = 20
                #endregion $CPUBar

                [System.Void]$groupBox3.Controls.Add($CPUBar)

                #region $CPU
                $CPU = New-Object -TypeName 'System.Windows.Forms.TextBox'
                $CPU.Dock = [System.Windows.Forms.DockStyle]::Top
                $CPU.ReadOnly = $true
                $CPU.BorderStyle = [System.Windows.Forms.BorderStyle]::None
                $CPU.Name = 'CPU'
                $CPU.TextAlign = [System.Windows.Forms.HorizontalAlignment]::Right
                #endregion $CPU

                [System.Void]$groupBox3.Controls.Add($CPU)

            $groupBox3.ResumeLayout($false)
            $groupBox3.PerformLayout()
            #endregion $groupBox3

            [System.Void]$tabPage1.Controls.Add($groupBox3)

            #region $groupBox4
            $groupBox4 = New-Object -TypeName 'System.Windows.Forms.GroupBox'
            $groupBox4.Size = New-Object -TypeName 'System.Drawing.Size' -ArgumentList @(20, 40)
            $groupBox4.Dock = [System.Windows.Forms.DockStyle]::Top
            $groupBox4.Text = 'Domaine :'
            $groupBox4.SuspendLayout()

                #region $Domain
                $Domain = New-Object -TypeName 'System.Windows.Forms.TextBox'
                $Domain.Dock = [System.Windows.Forms.DockStyle]::Top
                $Domain.ReadOnly = $true
                $Domain.BorderStyle = [System.Windows.Forms.BorderStyle]::None
                $Domain.Name = 'Domain'
                #endregion $Domain

                [System.Void]$groupBox4.Controls.Add($Domain)

            $groupBox4.ResumeLayout($false)
            $groupBox4.PerformLayout()
            #endregion $groupBox4

            [System.Void]$tabPage1.Controls.Add($groupBox4)

            #region $groupBox5
            $groupBox5 = New-Object -TypeName 'System.Windows.Forms.GroupBox'
            $groupBox5.Size = New-Object -TypeName 'System.Drawing.Size' -ArgumentList @(20, 40)
            $groupBox5.Dock = [System.Windows.Forms.DockStyle]::Top
            $groupBox5.Text = 'Systeme :'
            $groupBox5.SuspendLayout()

                #region $OS
                $OS = New-Object -TypeName 'System.Windows.Forms.TextBox'
                $OS.Dock = [System.Windows.Forms.DockStyle]::Top
                $OS.ReadOnly = $true
                $OS.BorderStyle = [System.Windows.Forms.BorderStyle]::None
                $OS.Name = 'OS'
                #endregion $OS

                [System.Void]$groupBox5.Controls.Add($OS)

            $groupBox5.ResumeLayout($false)
            $groupBox5.PerformLayout()
            #endregion $groupBox5

            [System.Void]$tabPage1.Controls.Add($groupBox5)

        $tabPage1.ResumeLayout($false)
        $tabPage1.PerformLayout()
        #endregion $tabPage1

        [System.Void]$Tabs.Controls.Add($tabPage1)

        #region $tabPage2
        $tabPage2 = New-Object -TypeName 'System.Windows.Forms.TabPage'
        $tabPage2.Padding = New-Object -TypeName 'System.Windows.Forms.Padding' -ArgumentList @(4)
        $tabPage2.Text = 'Disques'
        $tabPage2.SuspendLayout()

            #region $groupBox6
            $groupBox6 = New-Object -TypeName 'System.Windows.Forms.GroupBox'
            $groupBox6.Dock = [System.Windows.Forms.DockStyle]::Fill
            $groupBox6.Text = 'Disk(s)'
            $groupBox6.SuspendLayout()

                #region $DisksList
                $DisksList = New-Object -TypeName 'System.Windows.Forms.ListBox'
                $DisksList.Font = $font1
                $DisksList.Dock = [System.Windows.Forms.DockStyle]::Fill
                $DisksList.BorderStyle = [System.Windows.Forms.BorderStyle]::None
                $DisksList.Name = 'DisksList'
                #endregion $DisksList

                [System.Void]$groupBox6.Controls.Add($DisksList)

            $groupBox6.ResumeLayout($false)
            $groupBox6.PerformLayout()
            #endregion $groupBox6

            [System.Void]$tabPage2.Controls.Add($groupBox6)

        $tabPage2.ResumeLayout($false)
        $tabPage2.PerformLayout()
        #endregion $tabPage2

        [System.Void]$Tabs.Controls.Add($tabPage2)

        #region $tabPage3
        $tabPage3 = New-Object -TypeName 'System.Windows.Forms.TabPage'
        $tabPage3.Padding = New-Object -TypeName 'System.Windows.Forms.Padding' -ArgumentList @(4)
        $tabPage3.Text = 'Reseau'
        $tabPage3.SuspendLayout()

            #region $groupBox7
            $groupBox7 = New-Object -TypeName 'System.Windows.Forms.GroupBox'
            $groupBox7.Size = New-Object -TypeName 'System.Drawing.Size' -ArgumentList @(20, 40)
            $groupBox7.Dock = [System.Windows.Forms.DockStyle]::Top
            $groupBox7.Text = 'DNS :'
            $groupBox7.SuspendLayout()

                #region $DNS
                $DNS = New-Object -TypeName 'System.Windows.Forms.TextBox'
                $DNS.Dock = [System.Windows.Forms.DockStyle]::Top
                $DNS.ReadOnly = $true
                $DNS.BorderStyle = [System.Windows.Forms.BorderStyle]::None
                $DNS.Name = 'DNS'
                #endregion $DNS

                [System.Void]$groupBox7.Controls.Add($DNS)

            $groupBox7.ResumeLayout($false)
            $groupBox7.PerformLayout()
            #endregion $groupBox7

            [System.Void]$tabPage3.Controls.Add($groupBox7)

            #region $groupBox8
            $groupBox8 = New-Object -TypeName 'System.Windows.Forms.GroupBox'
            $groupBox8.Size = New-Object -TypeName 'System.Drawing.Size' -ArgumentList @(20, 40)
            $groupBox8.Dock = [System.Windows.Forms.DockStyle]::Top
            $groupBox8.Text = 'MAC :'
            $groupBox8.SuspendLayout()

                #region $MAC
                $MAC = New-Object -TypeName 'System.Windows.Forms.TextBox'
                $MAC.Dock = [System.Windows.Forms.DockStyle]::Top
                $MAC.ReadOnly = $true
                $MAC.BorderStyle = [System.Windows.Forms.BorderStyle]::None
                $MAC.Name = 'MAC'
                #endregion $MAC

                [System.Void]$groupBox8.Controls.Add($MAC)

            $groupBox8.ResumeLayout($false)
            $groupBox8.PerformLayout()
            #endregion $groupBox8

            [System.Void]$tabPage3.Controls.Add($groupBox8)

            #region $groupBox9
            $groupBox9 = New-Object -TypeName 'System.Windows.Forms.GroupBox'
            $groupBox9.Size = New-Object -TypeName 'System.Drawing.Size' -ArgumentList @(20, 40)
            $groupBox9.Dock = [System.Windows.Forms.DockStyle]::Top
            $groupBox9.Text = 'GateWay :'
            $groupBox9.SuspendLayout()

                #region $GateWay
                $GateWay = New-Object -TypeName 'System.Windows.Forms.TextBox'
                $GateWay.Dock = [System.Windows.Forms.DockStyle]::Top
                $GateWay.ReadOnly = $true
                $GateWay.BorderStyle = [System.Windows.Forms.BorderStyle]::None
                $GateWay.Name = 'GateWay'
                #endregion $GateWay

                [System.Void]$groupBox9.Controls.Add($GateWay)

            $groupBox9.ResumeLayout($false)
            $groupBox9.PerformLayout()
            #endregion $groupBox9

            [System.Void]$tabPage3.Controls.Add($groupBox9)

            #region $groupBox10
            $groupBox10 = New-Object -TypeName 'System.Windows.Forms.GroupBox'
            $groupBox10.Size = New-Object -TypeName 'System.Drawing.Size' -ArgumentList @(20, 40)
            $groupBox10.Dock = [System.Windows.Forms.DockStyle]::Top
            $groupBox10.Text = 'MASK :'
            $groupBox10.SuspendLayout()

                #region $MASK
                $MASK = New-Object -TypeName 'System.Windows.Forms.TextBox'
                $MASK.Dock = [System.Windows.Forms.DockStyle]::Top
                $MASK.ReadOnly = $true
                $MASK.BorderStyle = [System.Windows.Forms.BorderStyle]::None
                $MASK.Name = 'MASK'
                #endregion $MASK

                [System.Void]$groupBox10.Controls.Add($MASK)

            $groupBox10.ResumeLayout($false)
            $groupBox10.PerformLayout()
            #endregion $groupBox10

            [System.Void]$tabPage3.Controls.Add($groupBox10)

            #region $groupBox11
            $groupBox11 = New-Object -TypeName 'System.Windows.Forms.GroupBox'
            $groupBox11.Size = New-Object -TypeName 'System.Drawing.Size' -ArgumentList @(20, 40)
            $groupBox11.Dock = [System.Windows.Forms.DockStyle]::Top
            $groupBox11.Text = 'IP :'
            $groupBox11.SuspendLayout()

                #region $IP
                $IP = New-Object -TypeName 'System.Windows.Forms.TextBox'
                $IP.Dock = [System.Windows.Forms.DockStyle]::Top
                $IP.ReadOnly = $true
                $IP.BorderStyle = [System.Windows.Forms.BorderStyle]::None
                $IP.Name = 'IP'
                #endregion $IP

                [System.Void]$groupBox11.Controls.Add($IP)

            $groupBox11.ResumeLayout($false)
            $groupBox11.PerformLayout()
            #endregion $groupBox11

            [System.Void]$tabPage3.Controls.Add($groupBox11)

            #region $groupBox12
            $groupBox12 = New-Object -TypeName 'System.Windows.Forms.GroupBox'
            $groupBox12.Size = New-Object -TypeName 'System.Drawing.Size' -ArgumentList @(20, 40)
            $groupBox12.Dock = [System.Windows.Forms.DockStyle]::Top
            $groupBox12.Text = 'DHCP :'
            $groupBox12.SuspendLayout()

                #region $DHCP
                $DHCP = New-Object -TypeName 'System.Windows.Forms.TextBox'
                $DHCP.Dock = [System.Windows.Forms.DockStyle]::Top
                $DHCP.ReadOnly = $true
                $DHCP.BorderStyle = [System.Windows.Forms.BorderStyle]::None
                $DHCP.Name = 'DHCP'
                #endregion $DHCP

                [System.Void]$groupBox12.Controls.Add($DHCP)

            $groupBox12.ResumeLayout($false)
            $groupBox12.PerformLayout()
            #endregion $groupBox12

            [System.Void]$tabPage3.Controls.Add($groupBox12)

        $tabPage3.ResumeLayout($false)
        $tabPage3.PerformLayout()
        #endregion $tabPage3

        [System.Void]$Tabs.Controls.Add($tabPage3)

        #region $tabPage4
        $tabPage4 = New-Object -TypeName 'System.Windows.Forms.TabPage'
        $tabPage4.Padding = New-Object -TypeName 'System.Windows.Forms.Padding' -ArgumentList @(4)
        $tabPage4.Text = 'Lan Connector'
        $tabPage4.SuspendLayout()

            #region $groupBox13
            $groupBox13 = New-Object -TypeName 'System.Windows.Forms.GroupBox'
            $groupBox13.Size = New-Object -TypeName 'System.Drawing.Size' -ArgumentList @(20, 40)
            $groupBox13.Dock = [System.Windows.Forms.DockStyle]::Top
            $groupBox13.Text = 'WSMan :'
            $groupBox13.SuspendLayout()

                #region $WSMan
                $WSMan = New-Object -TypeName 'System.Windows.Forms.TextBox'
                $WSMan.Dock = [System.Windows.Forms.DockStyle]::Top
                $WSMan.ReadOnly = $true
                $WSMan.BorderStyle = [System.Windows.Forms.BorderStyle]::None
                $WSMan.Name = 'WSMan'
                #endregion $WSMan

                [System.Void]$groupBox13.Controls.Add($WSMan)

            $groupBox13.ResumeLayout($false)
            $groupBox13.PerformLayout()
            #endregion $groupBox13

            [System.Void]$tabPage4.Controls.Add($groupBox13)

            #region $groupBox14
            $groupBox14 = New-Object -TypeName 'System.Windows.Forms.GroupBox'
            $groupBox14.Size = New-Object -TypeName 'System.Drawing.Size' -ArgumentList @(20, 40)
            $groupBox14.Dock = [System.Windows.Forms.DockStyle]::Top
            $groupBox14.Text = 'RemoteReg :'
            $groupBox14.SuspendLayout()

                #region $RemoteReg
                $RemoteReg = New-Object -TypeName 'System.Windows.Forms.TextBox'
                $RemoteReg.Dock = [System.Windows.Forms.DockStyle]::Top
                $RemoteReg.ReadOnly = $true
                $RemoteReg.BorderStyle = [System.Windows.Forms.BorderStyle]::None
                $RemoteReg.Name = 'RemoteReg'
                #endregion $RemoteReg

                [System.Void]$groupBox14.Controls.Add($RemoteReg)

            $groupBox14.ResumeLayout($false)
            $groupBox14.PerformLayout()
            #endregion $groupBox14

            [System.Void]$tabPage4.Controls.Add($groupBox14)

            #region $groupBox15
            $groupBox15 = New-Object -TypeName 'System.Windows.Forms.GroupBox'
            $groupBox15.Size = New-Object -TypeName 'System.Drawing.Size' -ArgumentList @(20, 40)
            $groupBox15.Dock = [System.Windows.Forms.DockStyle]::Top
            $groupBox15.Text = 'RPC :'
            $groupBox15.SuspendLayout()

                #region $RPC
                $RPC = New-Object -TypeName 'System.Windows.Forms.TextBox'
                $RPC.Dock = [System.Windows.Forms.DockStyle]::Top
                $RPC.ReadOnly = $true
                $RPC.BorderStyle = [System.Windows.Forms.BorderStyle]::None
                $RPC.Name = 'RPC'
                #endregion $RPC

                [System.Void]$groupBox15.Controls.Add($RPC)

            $groupBox15.ResumeLayout($false)
            $groupBox15.PerformLayout()
            #endregion $groupBox15

            [System.Void]$tabPage4.Controls.Add($groupBox15)

            #region $groupBox16
            $groupBox16 = New-Object -TypeName 'System.Windows.Forms.GroupBox'
            $groupBox16.Size = New-Object -TypeName 'System.Drawing.Size' -ArgumentList @(20, 40)
            $groupBox16.Dock = [System.Windows.Forms.DockStyle]::Top
            $groupBox16.Text = 'SMB :'
            $groupBox16.SuspendLayout()

                #region $SMB
                $SMB = New-Object -TypeName 'System.Windows.Forms.TextBox'
                $SMB.Dock = [System.Windows.Forms.DockStyle]::Top
                $SMB.ReadOnly = $true
                $SMB.BorderStyle = [System.Windows.Forms.BorderStyle]::None
                $SMB.Name = 'SMB'
                #endregion $SMB

                [System.Void]$groupBox16.Controls.Add($SMB)

            $groupBox16.ResumeLayout($false)
            $groupBox16.PerformLayout()
            #endregion $groupBox16

            [System.Void]$tabPage4.Controls.Add($groupBox16)

            #region $groupBox17
            $groupBox17 = New-Object -TypeName 'System.Windows.Forms.GroupBox'
            $groupBox17.Size = New-Object -TypeName 'System.Drawing.Size' -ArgumentList @(20, 40)
            $groupBox17.Dock = [System.Windows.Forms.DockStyle]::Top
            $groupBox17.Text = 'PSSession :'
            $groupBox17.SuspendLayout()

                #region $PS
                $PS = New-Object -TypeName 'System.Windows.Forms.TextBox'
                $PS.Dock = [System.Windows.Forms.DockStyle]::Top
                $PS.ReadOnly = $true
                $PS.BorderStyle = [System.Windows.Forms.BorderStyle]::None
                $PS.Name = 'PS'
                #endregion $PS

                [System.Void]$groupBox17.Controls.Add($PS)

            $groupBox17.ResumeLayout($false)
            $groupBox17.PerformLayout()
            #endregion $groupBox17

            [System.Void]$tabPage4.Controls.Add($groupBox17)

            #region $groupBox18
            $groupBox18 = New-Object -TypeName 'System.Windows.Forms.GroupBox'
            $groupBox18.Size = New-Object -TypeName 'System.Drawing.Size' -ArgumentList @(20, 40)
            $groupBox18.Dock = [System.Windows.Forms.DockStyle]::Top
            $groupBox18.Text = 'RDP :'
            $groupBox18.SuspendLayout()

                #region $RDP
                $RDP = New-Object -TypeName 'System.Windows.Forms.TextBox'
                $RDP.Dock = [System.Windows.Forms.DockStyle]::Top
                $RDP.ReadOnly = $true
                $RDP.BorderStyle = [System.Windows.Forms.BorderStyle]::None
                $RDP.Name = 'RDP'
                #endregion $RDP

                [System.Void]$groupBox18.Controls.Add($RDP)

            $groupBox18.ResumeLayout($false)
            $groupBox18.PerformLayout()
            #endregion $groupBox18

            [System.Void]$tabPage4.Controls.Add($groupBox18)

            #region $groupBox19
            $groupBox19 = New-Object -TypeName 'System.Windows.Forms.GroupBox'
            $groupBox19.Size = New-Object -TypeName 'System.Drawing.Size' -ArgumentList @(20, 40)
            $groupBox19.Dock = [System.Windows.Forms.DockStyle]::Top
            $groupBox19.Text = 'ICMP :'
            $groupBox19.SuspendLayout()

                #region $ICMP
                $ICMP = New-Object -TypeName 'System.Windows.Forms.TextBox'
                $ICMP.Dock = [System.Windows.Forms.DockStyle]::Top
                $ICMP.ReadOnly = $true
                $ICMP.BorderStyle = [System.Windows.Forms.BorderStyle]::None
                $ICMP.Name = 'ICMP'
                #endregion $ICMP

                [System.Void]$groupBox19.Controls.Add($ICMP)

            $groupBox19.ResumeLayout($false)
            $groupBox19.PerformLayout()
            #endregion $groupBox19

            [System.Void]$tabPage4.Controls.Add($groupBox19)

        $tabPage4.ResumeLayout($false)
        $tabPage4.PerformLayout()
        #endregion $tabPage4

        [System.Void]$Tabs.Controls.Add($tabPage4)

        #region $tabPage5
        $tabPage5 = New-Object -TypeName 'System.Windows.Forms.TabPage'
        $tabPage5.Padding = New-Object -TypeName 'System.Windows.Forms.Padding' -ArgumentList @(4)
        $tabPage5.Text = 'Partages'
        $tabPage5.SuspendLayout()

            #region $Shares
            $Shares = New-Object -TypeName 'System.Windows.Forms.ListBox'
            $Shares.Font = $font1
            $Shares.Dock = [System.Windows.Forms.DockStyle]::Fill
            $Shares.BorderStyle = [System.Windows.Forms.BorderStyle]::None
            $Shares.Name = 'Shares'
            #endregion $Shares

            [System.Void]$tabPage5.Controls.Add($Shares)

        $tabPage5.ResumeLayout($false)
        $tabPage5.PerformLayout()
        #endregion $tabPage5

        [System.Void]$Tabs.Controls.Add($tabPage5)

    #endregion $Tabs

    [System.Void]$SrvForm.Controls.Add($Tabs)

$SrvForm.ResumeLayout($false)
$SrvForm.PerformLayout()
#endregion $SrvForm



#region GUI Startup
$SrvForm.ShowDialog()
#endregion GUI Startup





