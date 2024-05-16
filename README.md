# temp12k-regional-composites

ensure docker is running  
open command prompt  
put params.json and proxies/custom_proxy_set.pkl in current directory  
edit params.json as desired (example: reduce ensemblenumber to 10) and save the file  
run the following from the command line (changing directory "C:/Users/dce72/Downloads" to your needs):  
docker run -v C:/Users/dce72/Downloads/proxies:/proxies -v C:/Users/dce72/Downloads:/output -v C:/Users/dce72/Downloads/params.json:params.json davidedge/lipd_webapps:temp12k  
output files will be saved to current directory  
