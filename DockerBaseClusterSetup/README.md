# kafka cluster setup


This tutorial is helpful for users who are running a single kafka cluster and wants to use CCFE

Goal
By the end of this exercise you will have CCFE (cruise-control-ui) setup inside CC (cruise-control) and accessible via CC (cruise-control) IP Address & Port.

Assumptions
Your kafka cluster is up and running (and zookeeper as well)
Cruise Control is setup correctly and running on host cc-host.example.com at path /opt/cruise-control
Cruise Control is configured to listen on ip 0.0.0.0 & port 9090 (or any configured port)
Cruise Control REST API is available under /kafkacruisecontrol path (Modern CC has this set in cruise-control/config/cruisecontrol.properties with variable webserver.api.urlprefix)
Cruise Control UI webapp directory is configured under ./cruise-control-ui/dist (relative to cruise-control folder). Modern CC has this variable controlled via webserver.ui.diskpath property in the cruise-control/config/cruise-control.properties file.
Setting up Cruise Control Frontend
Download the latest compiled artifacts from https://github.com/linkedin/cruise-control-ui/releases page
This will have the following files once extracted (you don't have to extract now)

/home/user/Downloads $ tar zxvf cruise-control-ui.tar.gz
cruise-control-ui/
cruise-control-ui/dist/
cruise-control-ui/README.txt
cruise-control-ui/dist/index.html
cruise-control-ui/dist/static/
cruise-control-ui/dist/static/cc-logo.png
cruise-control-ui/dist/static/css/
cruise-control-ui/dist/static/js/
cruise-control-ui/dist/static/config.csv
cruise-control-ui/dist/static/js/manifest.js
cruise-control-ui/dist/static/js/vendor.js
cruise-control-ui/dist/static/js/app.js
cruise-control-ui/dist/static/css/app.css
cruise-control-ui/dist/static/css/app.css.map
Copy the cruise-control-ui.tar.gz to the server where your Cruise Control is running
scp cruise-control-ui.tar.gz user@cc-host.example.com:/tmp/
Extract the cruise-control-ui.tar.gz inside the cruise-control runtime (deployment path)
ssh user@cc-host.example.com
cd /opt/cruise-control/
sudo tar zxvf /tmp/cruise-control-ui.tar.gz
Update the cruise-control-ui/dist/static/config.csv so that webapp can reach the Cruise Control Server REST API
ssh user@cc-host.example.com
cd /opt/cruise-control/cruise-control-ui/dist/static/
cat config.csv
dev,dev,/kafkacruisecontrol
NOTE: /kafkacruisecontrol is relative to CC which is listening on 0.0.0.0 & port 9090. So all requests made by CCFE will go to http://0.0.0.0:9090/kafkacruisecontrol end point

Hit the Cruise Control host & port in the browser to access CCFE
http://cc-host.example.com:9090/

You might want to bounce Cruise Control in case it doesn't recognize the newly deployed CCFE code.
Few Notes
URL portion in the config.csv (third value in CSV row) is relative to the webserver in which the CCFE is deployed. So, please take some extra caution understanding how the URL routing happens.

Security
When you are deploying Cruise Control on wildcard ip (0.0.0.0), please make sure only authorized clients can access the service (by leveraging iptables on linux). Or else any unauthorized user can control your setup.