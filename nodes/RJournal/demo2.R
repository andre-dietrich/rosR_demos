#!/usr/bin/r

# ROS
source(paste(system("rospack find rosR",intern=TRUE),"/lib/ros.R",sep=""),chdir=TRUE)

ros.Init("R_node")

ros.Info("start reading bag-file")
bag.file <- paste(system("rospack find rosR_demos", intern=TRUE), "/nodes/RJournal/sharpGP2D120.bag", sep="")
bag.data <- ros.BagRead(bag.file, "/sharpGP2D120/Linearization")

dist <- sapply(bag.data$message, "[[", "dist")
volt <- sapply(bag.data$message, "[[", "volt")

ros.Info("finished")

sharp.data <- data.frame( dist, volt )
sharp.reg  <- lm( dist ~ poly(volt, 8), sharp.data )
sharp.pred <- function(volt) { predict(sharp.reg, data.frame(volt)) }

sharp.p <- sharp.pred(seq(0.3,3,0.1))
sharp.c <- predict(sharp.reg, data.frame(volt=seq(0.3, 3, 0.1)), interval="confidence")

subscription <- ros.Subscriber("/sharpGP2D120/Voltage", "std_msgs/Float32")

# R
x11(width=10, height=4, title='SharpGP2D120-Monitor')
layout(matrix(c(1,2), 1, 2, byrow = TRUE), widths=c(2,1), heights=c(1,1))
Distance <- Time <- rep(NA,100)

# run
while(ros.OK()){ # evaluates to TRUE as long as the master online
	ros.SpinOnce()
	if(ros.SubscriberHasNewMessage(subscription)){
		
		volt <- ros.ReadMessage(subscription)$data
		dist <- sharp.pred(volt)
		
		Distance <- c(Distance[-1], dist)
		Time  <- c(Time[-1],  ros.TimeNow())

		# R - Plotting
		plot(Time, Distance, t='l', main="Distance Measurements")
		lines(Time, filter(Distance, rep(0.1, 10), sides=1), type="l",col="blue", lwd=2.5)
		
		matplot(seq(0.3, 3, 0.1), cbind(sharp.p, sharp.c[,-1]), lty=c(1,2,2,3,3), col=c(1,2,2,3,3), type="l", xlab='Voltage', ylab='Distance', main='Linearization')
		points(volt, dist)
	}
}
