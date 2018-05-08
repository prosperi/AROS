//
//  ViewController.swift
//  AROS
//
//  Created by Zura Mestiashvili on 4/1/18.
//  Copyright © 2018 Zura Mestiashvili. All rights reserved.
//

import UIKit
import ARKit
import Vision
import AVFoundation

class ViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet weak var sceneView: ARSCNView!
    @IBOutlet weak var matrixLabel: UILabel!
    @IBOutlet weak var slideScale: UISlider!
    @IBOutlet weak var draw: UIButton!
    @IBOutlet weak var location: UILabel!
    @IBOutlet weak var angle: UILabel!
    @IBOutlet weak var results: UILabel!
    @IBOutlet weak var grayView: UIImageView!
    
    let configuration = ARWorldTrackingConfiguration()
    var node = SCNNode(geometry: SCNPyramid(width: 0.1, height: 0.1, length: 0.1))
    var floor: SCNNode?
    var currentTime = 0
    var wall: SCNVector3?
    var lastOrientation = SCNVector3(0,0,0)
    var position = SCNVector3(0, 0, 0)

    // vision
    var visionRequests = [VNRequest]()
    let dispatchQueueML = DispatchQueue(label: "com.hw.dispatchqueueml")

    let PIXEL_TO_METERS : Float = 0.00026458333333333 * 5
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if #available(iOS 11.3, *) {
            configuration.planeDetection = .vertical
        } else {
            // Fallback on earlier versions
        }
        
        configuration.planeDetection = .horizontal
        self.sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints, ARSCNDebugOptions.showWorldOrigin]
        self.sceneView.session.run(configuration)
        self.sceneView.autoenablesDefaultLighting = true
        self.sceneView.delegate = self
        
        self.slideScale.transform = CGAffineTransform.init(rotationAngle: -.pi / 2)
        self.grayView.transform = CGAffineTransform.init(rotationAngle: .pi / 2)
        self.draw.layer.cornerRadius = 10
        self.draw.clipsToBounds = true
        
        guard let visionModel = try? VNCoreMLModel(for: Hand().model) else {
            fatalError("Could not load model")
        }

        let classificationRequest = VNCoreMLRequest(model: visionModel, completionHandler: handleClassifications)
        classificationRequest.imageCropAndScaleOption = VNImageCropAndScaleOption.centerCrop
        visionRequests = [classificationRequest]
        
        loopCoreMLUpdate()
    }
    
    func loopCoreMLUpdate () {
        dispatchQueueML.async {
            self.updateCoreML()
            
            self.loopCoreMLUpdate()
        }
    }
    
    func updateCoreML () {
        
        guard let pixelBuffer = self.sceneView.session.currentFrame?.capturedImage else {
            return
        }

        let ciImage = CIImage(cvPixelBuffer: pixelBuffer)
        let imageRequestHandler = VNImageRequestHandler(ciImage: ciImage, options: [:])
        
        do {
            try imageRequestHandler.perform(self.visionRequests)
        } catch {
            print(error)
        }
    }
    
    func handleClassifications(request: VNRequest, error: Error?) {
        if let theError = error {
            print("Error: \(theError.localizedDescription)")
            return
        }
        
        guard let observations = request.results else {
            print("No results")
            return
        }
       
        
        let observation = observations[0] as? VNClassificationObservation

        switch observation?.identifier {
        case "hand-spread":
            self.node.opacity = 1
            self.node.eulerAngles.y += 0.05
        case "hand-together":
//            self.node.opacity = CGFloat(((observation?.confidence)! * 100.0).rounded() / 100.0)
            self.node.opacity = 1
        case "no-hand":
            self.node.opacity = 1
        default:
            self.node.opacity = 0
        }
        
        let classifications = observations
            .compactMap({ $0 as? VNClassificationObservation })
            .map({ "\($0.identifier) \(($0.confidence * 100.0).rounded())" })
            .joined(separator: "\n")
        
        
        DispatchQueue.main.async {
            self.results.text = classifications
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        guard let planeAnchor = anchor as? ARPlaneAnchor else { return }
        
        if self.floor?.name == "floor" {return}
        
        let width = CGFloat(planeAnchor.extent.x)
        let height = CGFloat(planeAnchor.extent.z)
        let plane = SCNPlane(width: width, height: height)
        
        plane.materials.first?.diffuse.contents = UIColor(red: 0, green: 0, blue: 1, alpha: 0.7)
        
        let floor = SCNNode(geometry: plane)
        floor.position = SCNVector3(
            CGFloat(planeAnchor.center.x),
            CGFloat(planeAnchor.center.y),
            CGFloat(planeAnchor.center.z)
        )
        floor.eulerAngles.x = -.pi / 2
        floor.name = "floor"
        
        node.name = "floor"
        //node.addChildNode(floor)
        self.floor = floor
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didRenderScene scene: SCNScene, atTime time: TimeInterval) {

        guard let pointOfView = sceneView.pointOfView else {return}
        
        guard let pixelBuffer = self.sceneView.session.currentFrame?.capturedImage else {
           return
        }
        
        
        
        let transform = pointOfView.transform
        let orientation = SCNVector3(-transform.m31, -transform.m32, -transform.m33)
        let location = SCNVector3(transform.m41, transform.m42, transform.m43)
        let angles = pointOfView.eulerAngles
       
      
        let position = orientation + location
        self.position = position

        if abs(angles.x - lastOrientation.x) < 0.001 && abs(angles.z - lastOrientation.z) < 0.001 {
            currentTime += 1
            if currentTime > 2000 {
                wall = location
                
                let plane = SCNPlane(width: 0.5, height: 0.5)
                plane.materials.first?.diffuse.contents = UIColor(red: 0, green: 0, blue: 1, alpha: 0.7)
                let node = SCNNode(geometry: plane)
                node.position = location
                node.eulerAngles.y = pointOfView.eulerAngles.y

                
                node.name = "wall"
                
                scene.rootNode.addChildNode(node)
                
                currentTime = 0
            } else {
                lastOrientation = angles
            }
        } else {
            lastOrientation = angles
            currentTime = 0
        }
        
        
        if self.floor?.name == "floor" && false {
            self.sceneView.scene.rootNode.enumerateChildNodes({ (node, _) in
                if node.name != "wall" && node.name != "floor" && node.position.y < (self.floor?.position.y)! && location.y > (self.floor?.position.y)! {

                    node.isHidden = true

                } else {
                    node.isHidden = false
                }
            })
        }
        
        DispatchQueue.main.async {
            
            let ciImage = CIImage(cvPixelBuffer: pixelBuffer)
            let uiImage = self.convert(cmage: ciImage)
            
            let grayImage = OpenCVWrapper.toGray(uiImage)
            self.grayView.image = grayImage
            
            if self.draw.isHighlighted {
                let node = SCNNode(geometry: SCNSphere(radius: 0.01))
                node.position = position
                self.sceneView.scene.rootNode.addChildNode(node)
                node.geometry?.firstMaterial?.diffuse.contents = UIColor.blue
            } else {
                let pointer = SCNNode(geometry: SCNSphere(radius: 0.005))
                pointer.position = position
                pointer.name = "pointer"
                self.sceneView.scene.rootNode.enumerateChildNodes({ (node, _) in
                    if node.name == "pointer" {
                        node.removeFromParentNode()
                    }
                })
                self.sceneView.scene.rootNode.addChildNode(pointer)
                pointer.geometry?.firstMaterial?.diffuse.contents = UIColor.red
            }
            
            
            
        }
    }
    
    func convert(cmage:CIImage) -> UIImage {
        let context:CIContext = CIContext.init(options: nil)
        let cgImage:CGImage = context.createCGImage(cmage, from: cmage.extent)!
        let image:UIImage = UIImage.init(cgImage: cgImage)
        return image
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first as! UITouch
        if (touch.view == self.sceneView) {
            
            let location = touch.location(in: self.sceneView)
            guard let result = sceneView.hitTest(location, options: nil).first else {
                return
            }
            
            
            self.node = result.node

        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first as! UITouch
        
        if self.node.name != "cube" &&
            self.node.name != "sphere" &&
            self.node.name != "cone" &&
            self.node.name != "pyramid" &&
            self.node.name != "cylinder" &&
            self.node.name != "capsule" &&
            self.node.name != "tube" &&
            self.node.name != "torus"
        {
            return
        }
        
        if (touch.view == self.sceneView) {
            
            let location = touch.location(in: self.sceneView)
            let previousLocation = touch.previousLocation(in: self.sceneView)
            
            let change = (location - previousLocation) * self.PIXEL_TO_METERS
            
            
            self.node.position.x = self.node.position.x + Float(change.x)
            self.node.position.y = self.node.position.y - Float(change.y)
            
        }
    }
    
    @IBAction func slideX(_ sender: UISlider) {
        self.node.eulerAngles = SCNVector3(
            Float(sender.value) * .pi / 180,
            self.node.eulerAngles.y,
            self.node.eulerAngles.z
        )
    }
    
    @IBAction func slideZ(_ sender: UISlider) {
         self.node.eulerAngles = SCNVector3(
            self.node.eulerAngles.x,
            self.node.eulerAngles.y,
            Float(sender.value) * .pi / 180
        )
    }
    
    @IBAction func slideY(_ sender: UISlider) {
         self.node.eulerAngles = SCNVector3(
            self.node.eulerAngles.x,
            Float(sender.value) * .pi / 180,
            self.node.eulerAngles.z
        )
    }
    
    @IBAction func slideScale(_ sender: UISlider) {
        self.node.scale = SCNVector3(
            x: Float(sender.value),
            y: Float(sender.value),
            z: Float(sender.value)
        )
    }
    
    @IBAction func wall(_ sender: Any) {
        guard let pointOfView = sceneView.pointOfView else {return}
        
        
        let transform = pointOfView.transform
        let location = SCNVector3(transform.m41, transform.m42, transform.m43)
        
        self.location.text = "Location: \(location.x)\t\(location.y)\t\(location.z)"
        self.angle.text = "Y Angle: \(pointOfView.eulerAngles.y)"
        
        node = SCNNode(geometry: SCNBox(width: 0.1, height: 0.1, length: 0.005, chamferRadius: 0))
        node.geometry?.firstMaterial?.diffuse.contents = UIColor.blue
        node.geometry?.firstMaterial?.specular.contents = UIColor.yellow
        
        node.position = location
        node.eulerAngles.y = pointOfView.eulerAngles.y
        
        node.name = "wall"
        
        self.sceneView.scene.rootNode.addChildNode(node)
    }
    
    @IBAction func add(_ sender: Any) {
        self.node = SCNNode(geometry: SCNPyramid(width: 0.1, height: 0.1, length: 0.1))
        let door = SCNNode(geometry: SCNPlane(width: 0.03, height: 0.06))
        let box = SCNNode(geometry: SCNBox(width: 0.1, height: 0.1, length: 0.1, chamferRadius: 0))
        
        door.geometry?.firstMaterial?.diffuse.contents = UIColor.brown
        box.geometry?.firstMaterial?.diffuse.contents = UIColor.blue

        self.node.geometry?.firstMaterial?.diffuse.contents = UIColor.red
        self.node.geometry?.firstMaterial?.specular.contents = UIColor.yellow

        self.node.position = SCNVector3(0.3, -1, 0.3)
        box.position = SCNVector3(0, -0.05, 0)
        door.position = SCNVector3(0, -0.02, 0.051)
        
        self.node.addChildNode(box)
        box.addChildNode(door)
        
        self.sceneView.scene.rootNode.addChildNode(self.node)
    }


    @IBAction func reset(_ sender: Any) {
        self.restartSession()
    }
    
    @IBAction func cube(_ sender: Any) {
        
        let node = SCNNode(geometry: SCNBox(width: 0.1, height: 0.1, length: 0.1, chamferRadius: 0))
        node.geometry?.firstMaterial?.diffuse.contents = UIColor.blue
        node.geometry?.firstMaterial?.specular.contents = UIColor.yellow

        node.position = self.position
        node.name = "cube"
        
        self.sceneView.scene.rootNode.addChildNode(node)
    }
    
    @IBAction func sphere(_ sender: Any) {
        
        let node = SCNNode(geometry: SCNSphere(radius: 0.1))
        node.geometry?.firstMaterial?.diffuse.contents = UIColor.blue
        node.geometry?.firstMaterial?.specular.contents = UIColor.yellow
        
        node.position = self.position
        node.name = "sphere"
        
        self.sceneView.scene.rootNode.addChildNode(node)
    }
    
    @IBAction func cone(_ sender: Any) {
        
        let node = SCNNode(geometry: SCNCone(topRadius: 0.3, bottomRadius: 0.5, height: 0.7))
        node.geometry?.firstMaterial?.diffuse.contents = UIColor.blue
        node.geometry?.firstMaterial?.specular.contents = UIColor.yellow
        
        node.position = self.position
        node.name = "cone"
        
        self.sceneView.scene.rootNode.addChildNode(node)
    }
    
    @IBAction func pyramid(_ sender: Any) {
        
        let node = SCNNode(geometry: SCNPyramid(width: 0.5, height: 0.5, length: 0.5))
        node.geometry?.firstMaterial?.diffuse.contents = UIColor.blue
        node.geometry?.firstMaterial?.specular.contents = UIColor.yellow
        
        node.position = self.position
        node.name = "pyramid"
        
        self.sceneView.scene.rootNode.addChildNode(node)
    }
    
    @IBAction func cylinder(_ sender: Any) {
        
        let node = SCNNode(geometry: SCNCylinder(radius: 0.3, height: 0.5))
        node.geometry?.firstMaterial?.diffuse.contents = UIColor.blue
        node.geometry?.firstMaterial?.specular.contents = UIColor.yellow
        
        node.position = self.position
        node.name = "cylinder"
        
        self.sceneView.scene.rootNode.addChildNode(node)
    }
    
    @IBAction func capsule(_ sender: Any) {
        
        let node = SCNNode(geometry: SCNCapsule(capRadius: 0.3, height: 0.5))
        node.geometry?.firstMaterial?.diffuse.contents = UIColor.blue
        node.geometry?.firstMaterial?.specular.contents = UIColor.yellow
        
        node.position = self.position
        node.name = "capsule"
        
        self.sceneView.scene.rootNode.addChildNode(node)
    }
    
    @IBAction func tube(_ sender: Any) {
        
        let node = SCNNode(geometry: SCNTube(innerRadius: 0.3, outerRadius: 0.5, height: 1))
        node.geometry?.firstMaterial?.diffuse.contents = UIColor.blue
        node.geometry?.firstMaterial?.specular.contents = UIColor.yellow
        
        node.position = self.position
        node.name = "tube"
        
        self.sceneView.scene.rootNode.addChildNode(node)
    }
    
    @IBAction func torus(_ sender: Any) {
        
        let node = SCNNode(geometry: SCNTorus(ringRadius: 0.5, pipeRadius: 0.1))
        node.geometry?.firstMaterial?.diffuse.contents = UIColor.blue
        node.geometry?.firstMaterial?.specular.contents = UIColor.yellow
        
        node.position = self.position
        
        self.sceneView.scene.rootNode.addChildNode(node)
    }
    
    func restartSession () {
        self.sceneView.session.pause()
        self.sceneView.scene.rootNode.enumerateChildNodes{(node, _) in node.removeFromParentNode()}
        self.sceneView.session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
    }
    
    func random (a: CGFloat, b: CGFloat) -> CGFloat {
        return CGFloat(arc4random()) / CGFloat(UINT32_MAX) * abs(a - b) + min (a, b)
    }
}

func +(left: SCNVector3, right: SCNVector3) -> SCNVector3 {
    return SCNVector3Make(left.x + right.x, left.y + right.y, left.z + right.z)
}

func -(left: CGPoint, right: CGPoint) -> CGPoint {
    return CGPoint(x: left.x - right.x, y: left.y - right.y)
}

func *(left: CGPoint, right: Float) -> CGPoint {
    return CGPoint(x: left.x * CGFloat(right), y: left.y * CGFloat(right))
}


