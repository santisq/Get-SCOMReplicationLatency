#Requires -Modules ActiveDirectory, ThreadJob

function Get-SCOMReplicationLatency{
<#
.DESCRIPTION
Queries the OpsMgrLatencyMonitors container of a target server and calculates TimeDifference replication with its partners.
Output can be displayed on a GridView using the GridView switch or standard output to save in a variable.
.EXAMPLE
Get-SCOMReplicationLatency DC01 -GridView
.EXAMPLE
$savingToVar = Get-SCOMReplicationLatency DC01
.EXAMPLE
Get-ADDomainController -Filter * | Get-SCOMReplicationLatency > This would check replication latency on all Domain Controllers.
.NOTES
Requirements: ActiveDirectory & ThreadJob PS Modules.
#>

[cmdletbinding()]
[alias('grl')]
param(
    [parameter(Mandatory, ValueFromPipelineByPropertyName)]
    [string] $Name,
    [int] $ThrottleLimit = 10,
    [switch] $GridView
)

    begin {
        $threadJob = {
            $UTC = [datetime]::Now.ToUniversalTime()
            $Name = $using:Name
            $defNamingContext = (Get-ADRootDSE -Server $Name).defaultNamingContext
            $ldap = "LDAP://{0}/CN=OpsMgrLatencyMonitors,{1}" -f $Name, $defNamingContext
            $entry    = [System.DirectoryServices.DirectoryEntry]::new($ldap)
            $searcher = [System.DirectoryServices.DirectorySearcher]::new()
            $searcher.SearchRoot  = $entry
            $searcher.PageSize    = 2000
            $searcher.Filter      = "(&(objectClass=Container))"
            $searcher.SearchScope = "OneLevel"
            $searcher.PropertiesToLoad.AddRange(@('Name', 'whenChanged', 'adminDescription'))
            $Containers = $searcher.FindAll()
    
            foreach($Container in $Containers) {
                $destination = $Container.Properties['Name'][0]
                $whenChanged = $Container.Properties['whenChanged'][0]
                $adminDescription = $Container.Properties['adminDescription'][0]
                $adminDescription = [datetime]::ParseExact(
                    $adminDescription,
                    'yyyyMMdd.HHmmss',
                    [Globalization.CultureInfo]::CurrentCulture
                )
    
                $timeDiff = $adminDescription - $UTC
                $repTime  = $whenChanged - $adminDescription
    
                [pscustomObject]@{
                    Source                   = $Name.ToUpper()
                    Destination              = $destination.ToUpper()
                    'WhenChanged (UTC)'      = $whenChanged
                    'AdminDescription (UTC)' = $adminDescription
                    ReplicationTime          = $repTime
                    TimeDifference           = $timeDiff
                }
            }
        }
    }

    process {
        $null = Start-ThreadJob -ScriptBlock $threadJob -ThrottleLimit $ThrottleLimit
    }

    end {
        $result = Get-Job | Receive-Job -Wait -AutoRemoveJob | Sort-Object Source, ReplicationTime
        if($GridView.IsPresent) {
            return $result | Out-GridView -Title DCReplication
        }
        $result
    }
}
