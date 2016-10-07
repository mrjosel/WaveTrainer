//
//  CollapsibleTableViewHeader.swift
//  WaveTrainer
//
//  Created by Brian Josel on 10/2/16.
//  Copyright © 2016 Brian Josel. All rights reserved.
//

import UIKit

//manages collapsing/expanding views
protocol CollapsibleTableViewHeaderDelegate {
    
    //called whenever header cell is tapped
    func toggleSection(header: CollapsibleTableViewHeader)
    
    //called whenever a header collapses and hides its content
    func didCollapseHeader(header: CollapsibleTableViewHeader)
}

//header view for settings table
class CollapsibleTableViewHeader: UITableViewHeaderFooterView {
    
    //section that header resides in
    var section : Int!
    
    //delegate
    var delegate : CollapsibleTableViewHeaderDelegate?

    //label for each cell, populated by Setting enum
    let titleLabel = UILabel()
    
    //boolean to managed whether section is collapsed or not
    var isCollapsed : Bool {
        didSet {
            //if header is set to collapse, then call delegate
            if isCollapsed {
                self.delegate?.didCollapseHeader(header: self)
            }
        }
    }
    
    //initializer
    override init(reuseIdentifier: String?) {
        
        //isCollapsed is always true at init
        self.isCollapsed = true
        
        //call super
        super.init(reuseIdentifier: reuseIdentifier)
        
        //add titleLabel
        self.contentView.addSubview(titleLabel)
        
        //add gesture recognizer for collapsing/expaning
        self.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.tapHeader(_:))))
        
        //for use in autolayout
        self.titleLabel.translatesAutoresizingMaskIntoConstraints = false

    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //layout
    override func layoutSubviews() {
        super.layoutSubviews()
        
        //only view is the title label
        let views = ["titleLabel" : self.titleLabel]
        
        //set constraints
        self.contentView.addConstraints(NSLayoutConstraint.constraints(
            withVisualFormat: "V:|-[titleLabel]-|",
            options: [],
            metrics: nil,
            views: views
        ))
    }

    //function called whenever header is tapped
    func tapHeader(_ gestureRecognizer: UITapGestureRecognizer) {
        //call delegate
        self.delegate?.toggleSection(header: self)
    }
}
