Description
===========
Installs and configures the Groundwork Server and Distributed Monitoring Agent.

Requirements
============
recipe[postfix]

Attributes
==========
["groundwork"]["gdma_target_server"] = "gdma-autohost" # Where GDMA will send check results
["groundwork"]["gdma_username"] = "gdma"               # Username under which GDMA will run
["groundwork"]["gdma_protocol"] = "http"               # Protocol to download plugins/configs. Allowed: http https
["groundwork"]["gdma_multihost"] = "0"                      # Multihost mode. Allows 0 (off), 1 (on)

Usage
=====
Set override attribes at the appropriate level to have nodes retrieve, install, and configure GroundWork Server and GDMA.
