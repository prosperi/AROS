//
//  ViewController.swift
//  AROS
//
//  Created by Zura Mestiashvili on 4/1/18.
//  Copyright © 2018 Zura Mestiashvili. All rights reserved.
//

import UIKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet weak var sceneView: ARSCNView!
    @IBOutlet weak var matrixLabel: UILabel!
    @IBOutlet weak var slideScale: UISlider!
    @IBOutlet weak var draw: UIButton!

    let configuration = ARWorldTrackingConfiguration()
    var node = SCNNode(geometry: SCNPyramid(width: 0.1, height: 0.1, length: 0.1))
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configuration.planeDetection = .horizontal
        self.sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints, ARSCNDebugOptions.showWorldOrigin]
        self.sceneView.session.run(configuration)
        self.sceneView.autoenablesDefaultLighting = true
        self.sceneView.delegate = self
        
        self.slideScale.transform = CGAffineTransform.init(rotationAngle: -.pi / 2)
        self.draw.layer.cornerRadius = 10
        self.draw.clipsToBounds = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        guard let planeAnchor = anchor as? ARPlaneAnchor else { return }
        
        let width = CGFloat(planeAnchor.extent.x)
        let height = CGFloat(planeAnchor.extent.z)
        let plane = SCNPlane(width: width, height: height)
        
        plane.materials.first?.diffuse.contents = UIColor.red
        let tmp = SCNNode(geometry: plane)
        tmp.position = SCNVector3(
            CGFloat(planeAnchor.center.x),
            CGFloat(planeAnchor.center.y),
            CGFloat(planeAnchor.center.z)
        )
        tmp.eulerAngles.x = -.pi / 2
        
        node.addChildNode(tmp)
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didRenderScene scene: SCNScene, atTime time: TimeInterval) {
        guard let pointOfView = sceneView.pointOfView else {return}
        
        let transform = pointOfView.transform
        let orientation = SCNVector3(-transform.m31, -transform.m32, -transform.m33)
        let location = SCNVector3(transform.m41, transform.m42, transform.m43)
    
        let position = orientation + location
        
        DispatchQueue.main.async {
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
    
    @IBAction func add(_ sender: Any) {
        let door = SCNNode(geometry: SCNPlane(width: 0.03, height: 0.06))
        let box = SCNNode(geometry: SCNBox(width: 0.1, height: 0.1, length: 0.1, chamferRadius: 0))
        
        door.geometry?.firstMaterial?.diffuse.contents = UIColor.brown
        box.geometry?.firstMaterial?.diffuse.contents = UIColor.blue

        self.node.geometry?.firstMaterial?.diffuse.contents = UIColor.red
        self.node.geometry?.firstMaterial?.specular.contents = UIColor.yellow

        self.node.position = SCNVector3(0.3, 0.3, 0.3)
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
        self.node.removeFromParentNode()
        
        self.node = SCNNode(geometry: SCNBox(width: 0.1, height: 0.1, length: 0.1, chamferRadius: 0))
        self.node.geometry?.firstMaterial?.diffuse.contents = UIColor.blue
        self.node.geometry?.firstMaterial?.specular.contents = UIColor.yellow

        self.node.position = SCNVector3(0, 0, 0)
        
        self.sceneView.scene.rootNode.addChildNode(self.node)
    }
    
    @IBAction func sphere(_ sender: Any) {
        self.node.removeFromParentNode()
        
        self.node = SCNNode(geometry: SCNSphere(radius: 0.1))
        self.node.geometry?.firstMaterial?.diffuse.contents = UIColor.blue
        self.node.geometry?.firstMaterial?.specular.contents = UIColor.yellow
        
        self.node.position = SCNVector3(0, 0, 0)
        
        self.sceneView.scene.rootNode.addChildNode(self.node)
    }
    
    @IBAction func cone(_ sender: Any) {
        self.node.removeFromParentNode()
        
        self.node = SCNNode(geometry: SCNCone(topRadius: 0.3, bottomRadius: 0.5, height: 0.7))
        self.node.geometry?.firstMaterial?.diffuse.contents = UIColor.blue
        self.node.geometry?.firstMaterial?.specular.contents = UIColor.yellow
        
        self.node.position = SCNVector3(0, 0, 0)
        
        self.sceneView.scene.rootNode.addChildNode(self.node)
    }
    
    @IBAction func pyramid(_ sender: Any) {
        self.node.removeFromParentNode()
        
        self.node = SCNNode(geometry: SCNPyramid(width: 0.5, height: 0.5, length: 0.5))
        self.node.geometry?.firstMaterial?.diffuse.contents = UIColor.blue
        self.node.geometry?.firstMaterial?.specular.contents = UIColor.yellow
        
        self.node.position = SCNVector3(0, 0, 0)
        
        self.sceneView.scene.rootNode.addChildNode(self.node)
    }
    
    @IBAction func cylinder(_ sender: Any) {
        self.node.removeFromParentNode()
        
        self.node = SCNNode(geometry: SCNCylinder(radius: 0.3, height: 0.5))
        self.node.geometry?.firstMaterial?.diffuse.contents = UIColor.blue
        self.node.geometry?.firstMaterial?.specular.contents = UIColor.yellow
        
        self.node.position = SCNVector3(0, 0, 0)
        
        self.sceneView.scene.rootNode.addChildNode(self.node)
    }
    
    @IBAction func capsule(_ sender: Any) {
        self.node.removeFromParentNode()
        
        self.node = SCNNode(geometry: SCNCapsule(capRadius: 0.3, height: 0.5))
        self.node.geometry?.firstMaterial?.diffuse.contents = UIColor.blue
        self.node.geometry?.firstMaterial?.specular.contents = UIColor.yellow
        
        self.node.position = SCNVector3(0, 0, 0)
        
        self.sceneView.scene.rootNode.addChildNode(self.node)
    }
    
    @IBAction func tube(_ sender: Any) {
        self.node.removeFromParentNode()
        
        self.node = SCNNode(geometry: SCNTube(innerRadius: 0.3, outerRadius: 0.5, height: 1))
        self.node.geometry?.firstMaterial?.diffuse.contents = UIColor.blue
        self.node.geometry?.firstMaterial?.specular.contents = UIColor.yellow
        
        self.node.position = SCNVector3(0, 0, 0)
        
        self.sceneView.scene.rootNode.addChildNode(self.node)
    }
    
    @IBAction func torus(_ sender: Any) {
        self.node.removeFromParentNode()
        
        self.node = SCNNode(geometry: SCNTorus(ringRadius: 0.5, pipeRadius: 0.1))
        self.node.geometry?.firstMaterial?.diffuse.contents = UIColor.blue
        self.node.geometry?.firstMaterial?.specular.contents = UIColor.yellow
        
        self.node.position = SCNVector3(0, 0, 0)
        
        self.sceneView.scene.rootNode.addChildNode(self.node)
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


