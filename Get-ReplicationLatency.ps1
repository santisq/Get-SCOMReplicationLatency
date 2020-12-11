function Get-ReplicationLatency{
[cmdletbinding()]
[alias('grl')]
param(
    [parameter(mandatory,valuefrompipelinebypropertyname)]
    [string]$Name,
    [switch]$GridView
)

begin{

#Requires -Modules ActiveDirectory, ThreadJob

$UTC=(Get-Date).ToUniversalTime()

}

process{

Start-ThreadJob {

    $Name=$using:Name
    $defNamingContext=$namingContext=(Get-ADRootDSE -Server $Name).defaultNamingContext
    $objDirDomain=New-Object System.DirectoryServices.DirectoryEntry("LDAP://{0}/CN=OpsMgrLatencyMonitors,{1}" -f $Name,$defNamingContext)

    $objDirSearcher=New-Object System.DirectoryServices.DirectorySearcher
    $objDirSearcher.SearchRoot=$objDirDomain
    $objDirSearcher.PageSize=2000
    $objDirSearcher.Filter="(&(objectClass=Container))"
    $objDirSearcher.SearchScope = "OneLevel"
    'Name,whenChanged,adminDescription'.Split(',')|%{$objDirSearcher.PropertiesToLoad.Add($_) > $null}

    $Containers=$objDirSearcher.FindAll()

    foreach($Container in $Containers)
    {
        $DCName=$Container.Properties['Name']
        $whenChanged=[datetime]$Container.Properties['whenChanged'][0]
        $adminDescription=$Container.Properties['adminDescription'][0]
        $adminDescription=[datetime]::ParseExact($adminDescription,'yyyyMMdd.HHmmss',[Globalization.CultureInfo]::CurrentCulture)

        [timespan]$timeDiff=[datetime]$adminDescription-[datetime]$using:UTC
        [timespan]$repTime=[datetime]$whenChanged-[datetime]$adminDescription
    
        [pscustomObject]@{
            Source=$Name.ToUpper()
            Destination=$DCName.ToUpper()
            'WhenChanged (UTC)'=$whenChanged
            'AdminDescription (UTC)'=$adminDescription
            ReplicationTime=$repTime
            TimeDifference=$timeDiff
        }
    }

} -ThrottleLimit 10 > $null

}

end{

$Grid=[System.Collections.ArrayList]@(Get-Job|Wait-Job|Receive-Job)
Get-Job|Remove-Job

if($GridView.IsPresent){return $Grid|sort Source,ReplicationTime|Out-GridView -Title DCReplication}
else{return $Grid|sort Source,ReplicationTime}

}

}