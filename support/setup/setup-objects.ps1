#
# Adaptive BI Framework 3.0
#

#
# Setup Objects
#

# Target Server/Instance
$targetServer = "localhost";

# Execute setup scripts
& sqlcmd -i setup-objects.sql -S $targetServer
