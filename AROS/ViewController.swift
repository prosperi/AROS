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
        let node = SCNNode()
        node.geometry = SCNBox(width: 0.05, height: 0.05, length: 0.05, chamferRadius: 0.015)
        node.geometry?.firstMaterial?.diffuse.contents = UIColor.blue
        node.geometry?.firstMaterial?.specular.contents = UIColor.red
        
        let x = random(a: -1, b: 1)
        let y = random(a: -1, b: 1)
        let z = random(a: -1, b: 1)

        node.position = SCNVector3(x, y, z)
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

