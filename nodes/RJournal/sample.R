#!/usr/bin/r
source(paste(system("rospack find rosR",intern=T),"/lib/ros.R",sep=""),chdir=T)

ros.Init("R_sample")

publication  <- ros.Publisher("/sharpGP2D120/Voltage", "std_msgs/Float32")

message <- ros.Message("std_msgs/Float32")

distances <- sin(seq(1,13.56,0.04))+1.6
distances <- runif(length(distances), -0.2, 0.2) + distances

counter <- 0
for(dist in distances)
{
	message$data <- dist
	
	ros.WriteMessage(publication, message)
	
	Sys.sleep(0.03)
	
	counter <- counter + 1
	
	if(counter %% 50 == 0) print(counter)
}
