# WMGM
Code for the White Mountain Green Mountain simulation exhibit

### White Mountain Green Mountain Simulation Technical Guide
 
## Introduction
Below is a guide to setting up a running the White Mountain Green Mountain simulation. We have attempted to order this logically from installation, operating the simulation, calibrating, adjusting the simulation, and acknowledgments. Of course this is also reliant on first building the tabletop rig and having all the equipment listed. For the purpose of testing the simulation, it will run with just the Kinect 2 input but obviously will not align to your screen or wall projection; but this can be useful simply to check the program runs on your system.
 
## Setup of applications and libraries
This program uses Processing 4 to run, which you will need to install. It also uses a Kinect 2 for depth sensing and video input. You will need to install Open Kinect Library. Please follow the instructions on the below website to ensure your computer and Kinect are setup correctly.

https://processing.org/

https://shiffman.net/p5/kinect/

https://github.com/shiffman/OpenKinect-for-Processing
 
## Technical overview for code
The code is commented so please review the code for detailed descriptions.
The code consists of 4 files: 
WMGM... - this controls the whole simulation, calibrates the system, and allows you to control what layers you can see.
Mover - this controls the particles which move through wind forces and cause rain to happen.
Attractor - this controls the forces that influence the movement of Mover particles.
Rain Map - this controls the layer for visualizing rain as it saturates the ground and evaporates.
 
 
## Operating the simulation
The simulation automatically starts on running the program. You should run the simulation in fullscreen mode by holding 'shift' and pressing the 'play' icon from Processing.

#### Using the keyboard you can toggle various layers depending on what you want to show:
'c' toggles the view of the camera so you can see what the video camera sees. This can be helpful for general alignment of the Kinect unit.

'd' toggles the depth camera view that has been selected. By default this is the whole depth camera view, but this can be selected to better align the projected image to the tabletop and blocks.

's' allows you to select which part of the depth camera view is included in the simulation. Pressing 's' will show the whole depth camera view, you can use a mouse to draw a rectangle over a region of the depth camera view to only include the tabletop and exclude the box walls or wider environment. Click and hold the mouse in the top left corner of the region you want to include, drag the mouse to the bottom right and release. Toggle off 's' and toggle on 'd' and the depth view will be updated to just the rectangle you selected. You need to run this selection process each time you start the program.

'f' toggles the view of the forces. The larger the ring the greater the force at that point. This view can be helpful to see alignment between projection and understand the strength of the forces. For example are only the blocks generating forces or is the tabletop surface also generating forces? If the tabletop surface is generating forces you will want to recalibrate the detection ranges, advised below.

'r' toggles the rain map view. This shows how much rain has recently fallen on any given grid square by a variably-sized circle. The value of rain stored/saturation accumulates over time but also the value reduces through evaporation. This allows the visualization to persist longer than the rain from any single particle so we can appreciate areas which receive higher rainfall, while allowing the simulation to still be dynamic and responsive to blocks moving and conditions changing.

'w' toggles the wind indicator. This shows the direction of the global wind force which is influenced by the albedo generated by the environment.
In future versions we would like to add more layers, such as projected statements about the hydroclimate conditions, and projected animations of environmental conditions such as flora & fauna. Or you could program your own layers!
 
## Calibrating depth
From line 56 there are two variables for controlling the depthTop (which should be your highest block) and depthBot which should be a value just above your tabletop surface. It is important to calibrate the depth so the simulation behaves properly, otherwise too much or too little forces might be generated, giving undesirable results. By default the program runs at a calibration that worked well for our setup and distances between the Kinect and the tabletop surface and blocks.

In future versions there will be a GUI so you can adjust this with the simulation running live rather than restarting the code every time.
 
## Adjusting parameters of the simulation
The parameters of the simulation can be adjusted and are throughout the code. Eventually it would be good to add a GUI to tweak the parameters while the simulation is running. 

You can change the colors of all graphic elements, size of particles, plus the size and amount of rain particles. If you are familiar with Processing it is easy to skim through the code and adjust the colors or sizes of any ellipse() or rect() or point().

#### You can adjust the behavior of the simulation using key parameters listed below???

#### Some key parameters in WMGM...:
Line 15 controls how many particles being driven by the wind. Higher numbers will impact performance.

Line 110 the first value for a Mover is its mass. adjust this for how much a particle is affected by the forces.

Line 173 controls the mass of the forces, the higher the number the more repulsive each force point is.

Line 192 controls the angle (in degrees) that the wind will point depending on the albedo value. It is currently programmed to have a slight southerly direction to take into account the number of white blocks and overall color of the tabletop base map.

#### Some key parameters in Mover:
Line 41 controls the maximum speed a particle can go.

From line 45 (specifically line 53) controls rain threshold, and what values it will set the rain to start falling dependent on the elevation of the terrain the particle is over. Lower values will rain more frequently.

Line 56 controls how much moisture is "picked up" by the particle per frame, which can be adjusted. Note it has a range of negative and positive numbers to consider that it doesn't always pick up moisture and sometimes loses some, but generally does gain moisture over time.

Line 82 controls how many rain particles fall when it does rain. 

Line 90 transfers that rain to the Rain Map.

#### Some key Parameters in Rain Map:
Line 14 controls how quickly any rain stored gets evaporated. The number should be less than 1 or else it will accumulate rain, not evaporate! The higher (for example 0.9) the slower the evaporation with a value of 0 being instant evaporation.
 
## Acknowledgements
This program makes use of code by Daniel Shiffman from his Nature of Code series:
https://shiffman.net/learning/
https://github.com/nature-of-code
