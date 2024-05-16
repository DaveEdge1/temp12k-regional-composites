# temp12k-regional-composites

[install Docker](https://docs.docker.com/get-docker/)


ensure docker is running  
open command prompt  
pull the image: 'docker pull davidedge/lipd_webapps:temp12k'
put params.json in current directory  
write a .lpd file with your sustom set of proxies and put that in the directory too, naming it as follows: "proxies/custom_proxy_set.lpd"  
edit params.json as desired (example: reduce ensemblenumber to 10) and save the file  
run the following from the command line (changing directory "C:/Users/dce72/Downloads" to your needs):  
'docker run -v C:/Users/dce72/Downloads/regional_composites.R:/regional_composites.R -v C:/Users/dce72/Downloads/proxies:/proxies -v C:/Users/dce72/Downloads:/output -v C:/Users/dce72/Downloads/params.json:params.json davidedge/lipd_webapps:temp12k'  
output files will be saved to current directory  
