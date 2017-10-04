//
//  ARSCNView+Extensions.swift
//  ARVoxelKit
//
//  Created by Gleb on 9/27/17.
//  Copyright © 2017 Gleb Radchenko. All rights reserved.
//

import ARKit
import SceneKit

extension ARSCNView {
    func hitTestNode(from point: CGPoint, nodeType: SCNNode.Type) -> SCNHitTestResult? {
        let options: [SCNHitTestOption: Any] = [SCNHitTestOption.searchMode: SCNHitTestSearchMode.all.rawValue]
        let results = hitTest(point, options: options)
        
        return results.first(where: { type(of: $0.node) == nodeType })
    }
    
    func findNodes<T: SCNNode>(in parent: SCNNode) -> [T] {
        return parent.childs()
    }
}

extension SCNNode {
    func childs<T: SCNNode>(_ test: ((T) -> Bool)? = nil) -> [T] {
        return childNodes(passingTest: { (node, stop) -> Bool in
            guard let passing = node as? T else {
                return false
            }
            
            return test?(passing) ?? true
        }) as! [T]
    }
}