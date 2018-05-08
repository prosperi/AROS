# AROS

AROS is a class project that is built with Apple's ARKit. It implements following functionality:

- Displaying simple 3D objects(cube, pyramid, torus, cylinder...)
- Scaling and rotating objects in AR
- Drawing in AR by using the center of the camera
- Detecting planes 
- Hiding objects under the planes
- Moving objects in AR by interacting with the device surface
- Object recognition, using CoreML

Tech: Swift 4.0, Xcode 9.3, CoreML, ARkit, OpenCV, iOS 11.3, iPad(5th generation)

## Displaying objects in AR

Right now user can place simple 3D objects, scale and rotate them. 

![](https://media.giphy.com/media/macDtWMiBBWKlKgSUj/giphy.gif)

<a href="http://www.youtube.com/watch?feature=player_embedded&v=QDpsCbMRa8g" target="_blank">Demo</a>


## Drawing

Draw button can be used to draw in AR. The tool takes the center of the view and puts a small sphere at each point. Those spheres can be also scaled by selecting the node on the device screen and using the sliders to rotate and scale, providing ability to build various shapes.

![](https://media.giphy.com/media/1k02p8Phw2dboSV9Ec/giphy.gif)

<a href="http://www.youtube.com/watch?feature=player_embedded&v=Wwu_rnEdLpU" target="_blank">Demo</a>

## Plane detection

AROS detects horizontal surfaces using ARKit's `planeDetection` attribute (set to .horizontal). There are two ways to detect vertical planes - holding device next to the vertical plane for couple seconds without moving it and holding device next to the vertical plane and using  a button to generate vertical plane at that position. 

![](https://media.giphy.com/media/8FG8qNOa1HEItuJqtX/giphy.gif)

<a href="http://www.youtube.com/watch?feature=player_embedded&v=WSfaE5cKKjI" target="_blank">Demo</a>

## Hiding objects.

Occlusion is one of the most difficult tasks to be achieved in AR. Right now the tool can hide objects under the horizontal surface. For example, if the tool detects the horizontal surface of the table, any node created in AR that is under the table will be hidden if the device is above the horizontal plane,and will be shown if the device is under the plane. Same logic could be used to hide objects behind the vertical planes.

## Moving objects around

The tool provides ability to move AR nodes around by interacting with the device surface. Right now user can change only `x` and `y` coordinates of the object, but same logic can be used to modify the `z` coordinate too.

![](https://media.giphy.com/media/3f3ppmx2YcvGzviUFZ/giphy.gif)

<a href="http://www.youtube.com/watch?feature=player_embedded&v=KD36G6sLRlE" target="_blank">Demo</a>

## Object recognition

AROS uses CoreML to detect human hand. Right now there are 4 main classifiers - no-hand, hand-fist, hand-spread and hand-together. If user selects a node, one of the following will happen:
  - Node stays as it it (there is no hand in view)
  - Node disappears (user makes a fist)
  - Node starts rotating around y axis (user has the fingers spread)
  - Node stops rotating (user has fingers together)

![](https://media.giphy.com/media/4H8Wiv7XUS8RVHWC8W/giphy.gif)

<a href="http://www.youtube.com/watch?feature=player_embedded&v=tM9XeGntuV0" target="_blank">Demo</a>


# TODO

- Add OpenCV integration


  I started linking OpenCV to the project that could be used to detect and track objects based on their color. This would be greate enhancement for current functionality

- Moving objects so that all the 3 coordinates can change

  Right now only x and y coordinates change while moving the object

- Clean up the code and come up with a better structure



# Credits

- <a href="https://medium.com/@yiweini/opencv-with-swift-step-by-step-c3cc1d1ee5f1" target="_blank">OpenCV with Swift - step by step</a>
- <a href="https://medium.com/@hunter.ley.ward/ml-on-ios-running-coreml-on-ios-f9cb340f3855" target="_blank">Getting Started with Core ML — ML on iOS</a>