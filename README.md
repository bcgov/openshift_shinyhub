This is a project for hosting R/R-Shiny apps https://shiny.posit.co/ in OpenShift https://www.redhat.com/en/technologies/cloud-computing/openshift

*** This is a work in progress ***

Parts:
* /containers/shiny - Dockerfile and scripts for the shiny-server, which will display the individual apps.
* /containers/proxy - Dockerfile and scripts for shiny-proxy, which will receive the web request and spin up the shiny container with the app.
* /containers/valkey - Dockerfile and scripts for valkey (redis), which will keep track of session state for the users.
* /containes/operator - Dockerfile and scripts for shiny-operator, which will manage the shiny-proxy instances when the application.yaml changes * (listing of reports/permissions).
* /containers/EasyPublish - Dockerfile and scripts for EasyPublish, a dotnet application for managing the uploading of apps to Persistant Volumes, User assignments, etc.

Volume mappings:
* shiny@/srv/shiny-server - will be mapped to a PVC volume containing the applications.
* operator@/resources/shinyproxy.shinyproxy.yaml
* EasyPublish@/applications - will be mapped to the same PVC volume as shiny@/srv/shiny-server
* EasyPublish@/resources/shinyproxy.shinyproxy.yaml - Will map to the same PVC as the operator
* EasyPublish@/manifest - will contain the information needed to rebuild the shinyproxy.shinyproxy.yaml, then use kubectl to apply the change.

Authentication:
* EasyPublish will be authenticated/authorized through the usage of KeyCloak.
* The shiny stack will exist as both an authenticated instance(s), using KeyCloak. As well as an unauthenticated instance(s). Each set of applications will be stored on seperate volumes.

*** All code is copyright per their respective licences. Everything else is under the BSD licence ***