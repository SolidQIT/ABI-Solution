#
# Adaptive BI Framework 3.0
#

#
# Setup Objects
#

# Target Server/Instance
$targetServer = "localhost";


& sqlcmd -i setup-views-1.sql -S $targetServer
