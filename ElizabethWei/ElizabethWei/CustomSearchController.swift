//
//  CustomSearchController.swift
//  ElizabethWei
//
//  Created by Elizabeth Wei on 4/23/16.
//  Copyright © 2016 Elizabeth Wei. All rights reserved.
//

import UIKit

class CustomSearchController: UISearchController, UISearchBarDelegate {
    
    lazy var _searchBar: CustomSearchBar = {
        [unowned self] in
        let result = CustomSearchBar(frame: CGRectZero)
        result.delegate = self
        
        return result
        }()
    
    override var searchBar: UISearchBar {
        get {
            return _searchBar
        }
    }
}
