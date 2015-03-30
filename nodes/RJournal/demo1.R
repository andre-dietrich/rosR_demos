#!/usr/bin/r
x11(width=6, height=4, title='SharpGP2D120-Monitor')

source(paste(system("rospack find rosR",intern=TRUE),"/lib/ros.R",sep=""),chdir=TRUE)

ros.Init("R_demo1")

subscription <- ros.Subscriber("/sharpGP2D120/Voltage", "std_msgs/Float32")

# create vectors of length 100
Voltage <- Time <- rep(NA,100)

while(ros.OK())
{ 
	ros.SpinOnce()
	if(ros.SubscriberHasNewMessage(subscription))
	{		
		message <- ros.ReadMessage(subscription)
		
		Voltage <- c(Voltage[-1], message$data)
		Time    <- c(Time[-1],   ros.TimeNow())
		plot(Time, Voltage, t='l', main='Measured Voltage')
		lines(Time, filter(Voltage, rep(0.1, 10), sides=1), type="l",col="blue", lwd=2.5)
	}
	
	Sys.sleep(0.02)
}






