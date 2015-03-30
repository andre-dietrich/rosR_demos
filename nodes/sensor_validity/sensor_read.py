#!/usr/bin/env python
import roslib; roslib.load_manifest('KheperaNavigation')
import sensor_msgs.msg._Range
import rospy
from KheperaController import KheperaController

import matplotlib.pyplot as plt
import numpy as np

class ir_sensor:
    def __init__(self, x, y, degree, min_val=0, max_val=1023):
        self.x = x
        self.y = y
        self.degree = degree
        
        self.min_val = min_val
        self.max_val = max_val        
        
        self.z = np.polyfit(self.x, self.y, degree)
        self.poly = np.poly1d(self.z)
        
    def getDistance(self, v):
         
        if v == self.max_val:
            return 2.0
        elif v ==self.min_val:
            return -1
        else:
            return self.poly(v)


x = np.array([4., 5., 6., 7., 8., 9., 10., 11., 12., 13., 14., 15., 16., 17., 18., 19., 20., 21., 22., 23., 24., 25., 26., 27., 28., 29., 30.])
y = np.array([1023., 860.6, 742.26, 649.964, 572.588, 521.5, 468.816, 424.624, 387.74, 360.64, 333.072, 308.99, 286.208, 263.312, 247.024, 231.604, 216.42, 201.2, 193.668, 186.236, 178.62, 171.032, 163.38, 155.776, 153.576, 148.228, 140.548])
ir = ir_sensor(x, y, 12)

y = np.arange(2, 30, 0.1)
x = ir.poly(y)
ir_long = ir_sensor(x, y, 12)

khepera = KheperaController()
khepera.connect()

rospy.init_node("Khepera")

pub = rospy.Publisher('ir_distance', sensor_msgs.msg.Range)
msg = sensor_msgs.msg._Range.Range()

msg.radiation_type = 1
msg.min_range = 2
msg.max_range = 50
msg.header.frame_id  = 'ir_distance'

while not rospy.is_shutdown():
    msg.range = ir_long.getDistance(khepera.getADInput(3))
    msg.header.stamp = rospy.Time.now()
    pub.publish(msg)
    
khepera.disconnect()
    