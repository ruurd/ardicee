//
//  ViewController.swift
//  ARDicee
//
//  Created by Ruurd Pels on 01-06-2018.
//  Copyright © 2018 Bureau Pels. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {

    var diceArray: [SCNNode] = []

    @IBOutlet var sceneView: ARSCNView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        sceneView.delegate = self
        sceneView.autoenablesDefaultLighting = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .horizontal
       sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        sceneView.session.pause()
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            let touchLocation = touch.location(in: sceneView)
            let results = sceneView.hitTest(touchLocation, types: .existingPlaneUsingExtent)
            if let hit = results.first {
                addDice(atLocation: hit)
            }
        }
    }

    func rollAll() {
        if diceArray.isEmpty == false {
            for dice in diceArray {
                roll(dice: dice)
            }
        }
    }

    func roll(dice: SCNNode) {
        let randomX = Float(arc4random_uniform(4) + 1) * (Float.pi/2)
        let randomZ = Float(arc4random_uniform(4) + 1) * (Float.pi/2)
        dice.runAction(SCNAction.rotateBy(x: CGFloat(randomX * 5),
                                          y: 0,
                                          z: CGFloat(randomZ * 5),
                                          duration: 0.5))
    }

    func addDice(atLocation hit: ARHitTestResult) {
        let scene = SCNScene(named: "art.scnassets/diceCollada.scn")
        if let node = scene?.rootNode.childNode(withName: "Dice", recursively: true) {
            node.position = SCNVector3(
                x: hit.worldTransform.columns.3.x,
                y: hit.worldTransform.columns.3.y + node.boundingSphere.radius,
                z: hit.worldTransform.columns.3.z
            )
            diceArray.append(node)
            roll(dice: node)
            sceneView.scene.rootNode.addChildNode(node)
        }
    }

    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        if anchor is ARPlaneAnchor {
            let planeAnchor = anchor as! ARPlaneAnchor
            let plane = SCNPlane(width: CGFloat(planeAnchor.extent.x), height: CGFloat(planeAnchor.extent.z))
            let planeNode = SCNNode()
            planeNode.position = SCNVector3(x: planeAnchor.center.x, y: 0, z: planeAnchor.center.z)
            planeNode.transform = SCNMatrix4MakeRotation(-Float.pi / 2, 1, 0, 0)
            let material = SCNMaterial()
            material.diffuse.contents = UIImage(named: "art.scnassets/grid.png")
            plane.materials = [material]
            planeNode.geometry = plane
            node.addChildNode(planeNode)
        } else {
            return
        }
    }

    override func motionEnded(_ motion: UIEventSubtype, with event: UIEvent?) {
        rollAll()
    }

    @IBAction func removeAll(_ sender: UIBarButtonItem) {
        if diceArray.isEmpty == false {
            for dice in diceArray {
                dice.removeFromParentNode()
            }
        }
    }

    @IBAction func rollAllTapped(_ sender: UIBarButtonItem) {
        rollAll()
    }
}
