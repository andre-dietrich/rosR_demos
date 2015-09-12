#!/usr/bin/r
source(paste(system("rospack find rosR", intern=TRUE), "/lib/ros.R", sep=""), chdir=TRUE)
X11()
monitor1 <- dev.cur()
X11()
monitor2 <- dev.cur()

ros.Info("start reading undisturbed sample")
file <- paste(system("rospack find rosR", intern=TRUE), "/nodes/sensor_validity/training.bag", sep="")
bag <- ros.BagRead(file, "/ir_distance")
perfect_sample <- c()
for(msg in bag$message){
	perfect_sample <- c(perfect_sample, msg$range)
}
perfect_sample <- sort(perfect_sample)
perfect_sample <- (perfect_sample-median(perfect_sample))/(max(perfect_sample) + min(perfect_sample))

ros.Info("reading undisturbed sample finished")

ros.Init("R_SensorChecker")
subscriber <- ros.Subscriber("ir_distance", "sensor_msgs/Range")

x <- seq(1,65)
p <- rep(0,65)
measurements <- rep(0,65)
z <- seq(0,50, 5)

i_measurement <- 0

while(ros.OK()){
	ros.SpinOnce()
	if(ros.SubscriberHasNewMessage(subscriber)){
		i_measurement <- i_measurement + 1
		message <- ros.ReadMessage(subscriber)
		
		measurements <- c(measurements[-1], message$range)
		
		norm_measurements <- (measurements-median(measurements))/(max(measurements) + min(measurements))
		
		check <- fligner.test(list(norm_measurements,perfect_sample))
		
		p <- c(p, check$p.value)
		x <- seq(i_measurement, i_measurement+65) #c(x, ROS_TimeNow())
		
		x <- x[2:66]
		p <- p[2:66]
		
			
		dev.set(monitor2)
		plot(density(perfect_sample, adjust=2), xlim=c(-0.05, 0.05), lty="dotted", lwd=2, main="Density functions (training sample = dotted)", xlab=paste("N = 65  Bandwidth = ", density(norm_measurements)$bw))
		lines(density(norm_measurements, adjust=2), lwd=2)
				
		dev.set(monitor1)
		
		if(p[65] <= 0.00000000001) {
			disturbed = "(disturbed)"
		} else {
			disturbed = "(undisturbed)"
		}
		
		plot(x, p, t="l", ylim=c(0.000000000001,1), log="y", xlab="Time in msec", lwd=2, main=paste("Cur. Measurements", disturbed), ylab="Fligner p = black, distance = blue")
		lines(x, rep(0.00000000001, 65), lwd=2, col="red", lty = "dotted")

		par(new=TRUE)
		plot(x, measurements, col="blue", t="l", lwd=2, yaxt='n', ann=FALSE, ylim=c(0,35))
		axis(4, at=z, col.axis="blue", las=2, xlab="XXX")
		
	}
}
