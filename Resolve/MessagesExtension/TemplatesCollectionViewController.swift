//
//  TemplatesCollectionViewController.swift
//  Resolve
//
//  Created by Elizabeth Wei on 6/14/16.
//  Copyright © 2016 Elizabeth Wei. All rights reserved.
//

import UIKit

class TemplatesCollectionViewController: UICollectionViewController {
    
    let reuseIdentifier = "TemplateCell"

    static let storyboardIdentifier = "TemplatesCollectionViewController"
    
    private let templates = ["day", "date", "time", "interval", "meal"]
    
    weak var delegate: TemplatesCollectionViewControllerDelegate?
    
    override func viewDidLoad() {
        view.backgroundColor = UIColorFromHex(rgbValue: 0x88d8b0)
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return templates.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return dequeueTemplateCell(at: indexPath)
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {        
        delegate?.templatesCollectionViewControllerDidSelectAdd(self, pollType: templates[indexPath.item])
    }
    
    private func dequeueTemplateCell(at indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView?.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as? TemplateCollectionViewCell else { fatalError("Unable to dequeue a TemplateCell") }
        
        cell.backgroundView = UIImageView(image: UIImage(named: templates[indexPath.item])!)
        cell.layer.cornerRadius = 8
        
        return cell
    }
    
    func UIColorFromHex(rgbValue:UInt32, alpha:Double=1.0)->UIColor {
        let red = CGFloat((rgbValue & 0xFF0000) >> 16)/256.0
        let green = CGFloat((rgbValue & 0xFF00) >> 8)/256.0
        let blue = CGFloat(rgbValue & 0xFF)/256.0
        
        return UIColor(red:red, green:green, blue:blue, alpha:CGFloat(alpha))
    }
}

protocol TemplatesCollectionViewControllerDelegate: class {
    func templatesCollectionViewControllerDidSelectAdd(_ controller: TemplatesCollectionViewController, pollType: String)

}
