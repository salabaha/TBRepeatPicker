//
//  TBRPPresetRepeatController.swift
//  TBRepeatPicker
//
//  Created by hongxin on 15/9/23.
//  Copyright © 2015年 Teambition. All rights reserved.
//

import UIKit

private let TBRPPresetRepeatCellID = "TBRPPresetRepeatCell"

class TBRPPresetRepeatController: UITableViewController {
    // MARK: - Public properties
    var tintColor = UIColor.blueColor()
    var locale = NSLocale.currentLocale()
    var language: TBRPLanguage = .English
    var selectedIndexPath = NSIndexPath(forRow: 0, inSection: 0)
    
    // MARK: - Private properties
    private var presetRepeat = [String]()
    private var internationalControl: TBRPInternationalControl?
    
    // MARK: - View life cycle
    convenience init(locale: NSLocale!, language: TBRPLanguage!, tintColor: UIColor!) {
        self.init()
        
        self.tableView = UITableView(frame: view.frame, style: .Grouped)
        self.locale = locale
        self.language = language
        self.tintColor = tintColor
        self.selectedIndexPath = NSIndexPath(forRow: 0, inSection: 0)
        
        commonInit()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    private func commonInit() {
        internationalControl = TBRPInternationalControl(language: language)
        navigationItem.title = internationalControl?.localized("TBRPPresetRepeatController.navigation.title", comment: "Repeat")
        
        navigationController?.navigationBar.barTintColor = tintColor
        tableView.tintColor = tintColor
        
        presetRepeat = TBRPHelper.presetRepeat(language)
    }

    // MARK: - Table view data source
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 6
        } else {
            return 1
        }
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 44.0
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier(TBRPPresetRepeatCellID)
        if cell == nil {
            cell = UITableViewCell(style: .Default, reuseIdentifier: TBRPPresetRepeatCellID)
        }
        
        if indexPath.section == 1 {
            cell?.accessoryType = .DisclosureIndicator
            cell?.textLabel?.text = internationalControl?.localized("TBRPPresetRepeatController.textLabel.custom", comment: "Custom")
        } else {
            cell?.accessoryType = .None
            cell?.textLabel?.text = presetRepeat[indexPath.row]
        }
        
        cell?.imageView?.image = UIImage(named: "TBRP-Checkmark")?.imageWithRenderingMode(.AlwaysTemplate)
        
        if indexPath == selectedIndexPath {
            cell?.imageView?.hidden = false
        } else {
            cell?.imageView?.hidden = true
        }
        
        return cell!
    }

    // MARK: - Table view delegate
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let lastSelectedCell = tableView.cellForRowAtIndexPath(selectedIndexPath)
        let currentSelectedCell = tableView.cellForRowAtIndexPath(indexPath)
        
        lastSelectedCell?.imageView?.hidden = true
        currentSelectedCell?.imageView?.hidden = false
        
        selectedIndexPath = indexPath
        
        if indexPath.section == 1 {
            let customRepeatController = TBRPCustomRepeatController(style: .Grouped)
            customRepeatController.tintColor = tintColor
            customRepeatController.locale = locale
            customRepeatController.language = language
            customRepeatController.frequency = .Daily
            customRepeatController.every = 1
            
            navigationController?.pushViewController(customRepeatController, animated: true)
        }
        
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }

}
