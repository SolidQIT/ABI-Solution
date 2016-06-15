#
# Adaptive BI Framework 3.0
#

#
# Setup Objects
#

# Target Server/Instance
$targetServer = "localhost";

# Execute setup scripts
& sqlcmd -i setup-views-2.sql -S $targetServer
