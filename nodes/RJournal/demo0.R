#!/usr/bin/r
source(paste(system("rospack find rosR",intern=TRUE),"/lib/ros.R",sep=""),chdir=TRUE)

ros.Init("R_demo")

subscription <- ros.Subscriber("/sharpGP2D120/Voltage", "std_msgs/Float32")

while(ros.OK()) # evaluates to TRUE as long as the master online
{ 
	ros.SpinOnce()
	if(ros.SubscriberHasNewMessage(subscription))
	{
		message <- ros.ReadMessage(subscription)
		ros.Info( paste('Measured Voltage', message$data) )
		#ros.Error( paste('Measured Voltage', message$data) )
	}
}
