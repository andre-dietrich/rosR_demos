#!/usr/bin/r
source(paste(system("rospack find rosR",intern=T),"/lib/ros.R",sep=""),chdir=T)

ros.Init("R_sample2")

publication  <- ros.Publisher("/sharpGP2D120/Linearization", "rosR/Linearization")

message <- ros.Message("rosR/Linearization")

dist <- c(0.031, 0.035, 0.039, 0.05, 0.06, 0.071, 0.08, 0.09, 0.1, 0.12, 0.14, 0.16, 0.18, 0.2, 0.25, 0.3, 0.4)
volt <- c(3.02, 2.98, 2.72, 2.34, 2.01, 1.76, 1.55, 1.39, 1.26, 1.06, 0.93, 0.82, 0.73, 0.65, 0.53, 0.43, 0.32)

for(i in (1:length(volt)))
{
	
	message$dist <- dist[i]
	
	num <- floor(runif(1,10,20))
	
	for(j in 1:num){
		message$volt <- volt[i] + rnorm(1)/(volt[i]*9)
		ros.WriteMessage(publication, message)
		Sys.sleep(0.03)
		
		print( message )
	}
	
	
	
	Sys.sleep(runif(1,10,20))
}


