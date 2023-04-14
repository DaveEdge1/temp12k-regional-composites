# temp12k-regional-composites

ensure docker is running\n
open command prompt\n
put params.json in current directory\n
edit params.json as desired (example: reduce ensemblenumber to 10) and save\n
run the following from the command line (changing directory "C:/Users/dce72/Downloads" to your needs):\n
docker run -v C:/Users/dce72/Downloads:/output -v C:/Users/dce72/Downloads/params.json:params.json davidedge/lipd_webapps:temp12k\n
output files will be saved to current directory\n
