//
//  ViewController.swift
//  AROS
//
//  Created by Zura Mestiashvili on 4/1/18.
//  Copyright © 2018 Zura Mestiashvili. All rights reserved.
//

import UIKit
import ARKit

class ViewController: UIViewController {

    @IBOutlet weak var sceneView: ARSCNView!
    let configuration = ARWorldTrackingConfiguration()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints, ARSCNDebugOptions.showWorldOrigin]
        self.sceneView.session.run(configuration)
        self.sceneView.autoenablesDefaultLighting = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func slide(_ sender: UISlider) {
        print("interesting")
    }
    
    @IBAction func add(_ sender: Any) {
        let door = SCNNode(geometry: SCNPlane(width: 0.03, height: 0.06))
        let box = SCNNode(geometry: SCNBox(width: 0.1, height: 0.1, length: 0.1, chamferRadius: 0))
        let node = SCNNode(geometry: SCNPyramid(width: 0.1, height: 0.1, length: 0.1))
        
        door.geometry?.firstMaterial?.diffuse.contents = UIColor.brown
        box.geometry?.firstMaterial?.diffuse.contents = UIColor.blue

        node.geometry?.firstMaterial?.diffuse.contents = UIColor.red
        node.geometry?.firstMaterial?.specular.contents = UIColor.yellow

        node.position = SCNVector3(0.3, 0.3, 0.3)
        box.position = SCNVector3(0, -0.05, 0)
        door.position = SCNVector3(0, -0.02, 0.051)
        
        node.addChildNode(box)
        box.addChildNode(door)
        
        self.sceneView.scene.rootNode.addChildNode(node)
    }


    @IBAction func reset(_ sender: Any) {
        self.restartSession()
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

