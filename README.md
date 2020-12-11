# Get-SCOMReplicationLatency

Queries the OpsMgrLatencyMonitors container of a target server and calculates TimeDifference replication with its partners.
Output can be displayed on a GridView using the GridView switch, example screenshot can be found on the Example folder.

##### Syntax

- Get-SCOMReplicationLatency DC01 -GridView
- $savingToVar = Get-SCOMReplicationLatency DC01
- Get-ADDomainController -Filter * | Get-SCOMReplicationLatency > This would check replication latency on all Domain Controllers.

##### Requirements

ActiveDirectory & ThreadJob PS Modules.