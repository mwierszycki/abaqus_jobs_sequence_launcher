Write-Host 'Abaqus Jobs Sequence Launcher ver. 0.1'
Write-Host 'Created by MWierszycki. Licensed under GPL-2.0-only.' 
Write-Host 'See https://github.com/mwierszycki/abaqus_job_sequence_launcher'`n

$currDir = Get-Location
$MaxNbOfCores = Get-WmiObject -class Win32_processor | select-object -property NumberOfCores
$useJobsFile = 'N'
$jobsFile = ''
$cpusArg = ''

if ( $args.count -gt 0 )
{
  $argFileName = Split-Path $($args[0]) -leaf
  if ( Test-Path -Path $currDir\$argFileName -PathType Leaf )
  {
    $jobsFile = $argFileName
  }
}
elseif ( Test-Path -Path $currDir\jobs.txt -PathType Leaf )
{
  $jobsFile = 'jobs.txt' 
}

if ( $jobsFile -gt 0)
{
  $useJobsFileMsg =  "The $jobsFile file has been found. Would you use it? [Y]es/[N]o/[Q]uit"
  while( ($useJobsFile = Read-Host -Prompt $useJobsFileMsg ) -ine 'Q' )
  {
    if ( $useJobsFile -inotmatch '[YNQ]' )
    {
      $useJobsFileMsg = 'Type [Y]es, [N]o or [Q]uit'
    }
    elseif ( $useJobsFile -ieq 'Y' )
    {
      $jobsList = Get-Content -Path $currDir'\'$jobsFile 
#      Write-Host 'INP files in jobs.txt:'
#      Write-Host $jobsList
      $bjobsFileOk = $True
      foreach($job in $jobsList)
      {
        $jobArray = $job -replace '\s+', ' ' -split(' ')
        if ( $jobArray[0] -inotmatch '.+\.inp+$' ) {$bjobsFileOk = $False}
      }
      if ( $bjobsFileOk )
      {
        break
      }
      else
      {
        $useJobsFileMsg =  "The format of $jobsFile is incorret. [N]ext/[Q]uit"
        $jobsFile = ''
        Remove-Variable jobsList
      }
    }
    elseif ( $useJobsFile -ieq 'N' )
    {
      Write-Host 'The file' $jobsFile 'will be skipped.'
      break
    }
  }
}

if ( $useJobsFile -ieq 'N' )
{
  Write-Host 'All INP files in current directory will be run one by one.'

  while( ($CPUs = Read-Host -Prompt "How many cores to use to run jobs? No of cores [from 1 to $($MaxNbOfCores.NumberOfCores)]/[Q]uit") -ine 'Q' )
  {
    if ( $CPUs -notmatch '\d+' )
    {
      Write-Host 'Type number of cores (max is' $MaxNbOfCores.NumberOfCores') or type Q to exit'
    }
    elseif ( [Int]$CPUs -gt $MaxNbOfCores.NumberOfCores ) 
    {
      Write-Host 'The machine has only' $MaxNbOfCores.NumberOfCores 'physical cores. Try again or type Q to exit'
    }
    elseif ( [Int]$CPUs -lt 1 )
    {
      Write-Host 'Number of cores must be greater than or equal 1. Try again or type Q to exit' 
    }
    else
    {
      $cpusArg = '-cpus ' + $CPUs
      $jobsList = Get-ChildItem -Path $currDir\* -File -Name -Include *.inp
#      Write-Host 'INP files in ' $currDir ':'
#      Write-Host $inpList
      break
    }
  }
}

$outputFileMsg = @()

foreach($job in $jobsList)
{
  $jobArray = $job -replace '\s+', ' ' -split(' ')
  $jobName, $jobArgs = $jobArray
  $inputName = $jobName
  $jobName = $jobName -replace '.{4}$'
  $jobCmd = '-job ' + $jobName + ' -input ' + $inputName + ' ' + $cpusArg + ' ' + "$jobArgs"
#  Write-Host $jobCmd
  $startTime = Get-Date -Format "HH:mm dd/MM/yyyy"
#  Write-Host '[*] Job'$jobName' is running (started at' $startTime')'
  $outputFileMsg += "[*] Job $jobName is running (started at $startTime)" 
  Write-Host ''$outputFileMsg[-1]  -NoNewLine
  Start-Process abaqus -Wait -NoNewWindow -ArgumentList $jobCmd
  $stopTime = Get-Date -Format "HH:mm dd/MM/yyyy"
  
  if ( Test-Path -Path $currDir'\'$jobName'.log' -PathType Leaf )
  {
    $jobLog = Get-Content -Path $currDir'\'$jobName'.log' 
    if ( $jobLog[-1] -ilike 'Abaqus JOB * COMPLETED' )
    {
      $outputFileMsg +="[*] Job $jobName was finished successfully at $stopTime" 
      Write-Host `r $outputFileMsg[-1] -ForegroundColor Green
    }
    elseif ( $jobLog[-1] -ilike '*exited with errors*' )
    {
      $outputFileMsg += "[*] Job $jobName was terminated with errors at $stopTime"
      Write-Host `r $outputFileMsg[-1] -ForegroundColor Red
    }
    else
    {
      $outputFileMsg += "[*] Job $jobName was closed in an unexpected way at $stopTime"
      Write-Host `r $outputFileMsg[-1] -ForegroundColor Yellow
    }
  }
  else
  {
      $outputFileMsg += "[*] Job $jobName didn't start correctly at $stopTime"
      Write-Host `r $outputFileMsg[-1] -ForegroundColor Red
  }
}
if ( $outputFileMsg.Count -gt 0 ) 
{
  $saveLogFileMsg =  "The jobs sequence has been finished. Would you like to save log file? [Y]es/[N]o"
  while( ($saveLogFile = Read-Host -Prompt $saveLogFileMsg ) -ine 'N' )
  {
    if ( $saveLogFile -ieq 'Y' )
    {
      if ( $jobsFile -eq '' )
      {
        $jobsLogFile = 'jobs.log'
      }
      else
      {
        $jobsLogFile = $jobsFile  -replace '.{4}$'
        $jobsLogFile = $jobsLogFile + '.log'
      }
      $outputFileMsg | Out-File -FilePath $currDir'\'$jobsLogFile 
      break
    }
  }
}
else
{
  Read-Host -Prompt 'Press ENTER to exit'
}
