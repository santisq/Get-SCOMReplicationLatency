# Get-SCOMReplicationLatency

Queries the OpsMgrLatencyMonitors container of a target server and calculates TimeDifference replication with its partners.
Output can be displayed on a GridView using the GridView switch, example screenshot can be found on the Example folder.

### Syntax

- `Get-SCOMReplicationLatency DC01 -GridView`
- `$savingToVar = Get-SCOMReplicationLatency DC01`
- `Get-ADDomainController -Filter * | Get-SCOMReplicationLatency` <b> > This would check replication latency on all Domain Controllers.</b>

### Requirements

[ActiveDirectory](https://docs.microsoft.com/en-us/powershell/module/activedirectory/?view=windowsserver2019-ps) & [ThreadJob](https://docs.microsoft.com/en-us/powershell/module/threadjob/?view=powershell-7.1) PS Modules.

![Alt text](/Example/Example1DC.png?raw=true)
