//
//  TBRPPresetRepeatController.swift
//  TBRepeatPicker
//
//  Created by hongxin on 15/9/23.
//  Copyright © 2015年 Teambition. All rights reserved.
//

import UIKit

private let TBRPPresetRepeatCellID = "TBRPPresetRepeatCell"

@objc public protocol TBRepeatPickerDelegate {
    func didPickRecurrence(_ recurrence: TBRecurrence?, repeatPicker: TBRepeatPicker)
}

public class TBRPPresetRepeatController: UITableViewController, TBRPCustomRepeatControllerDelegate {
    // MARK: - Public properties
    public var cellFont = UIFont.systemFont(ofSize: 17)
    public var cellTextColor = UIColor.black
    public var occurrenceDate = Date()
    public var tintColor = UIColor.blue
    public var language: TBRPLanguage = .english
    public var delegate: TBRepeatPickerDelegate?
    
    public var recurrence: TBRecurrence? {
        didSet {
            setupSelectedIndexPath(recurrence)
        }
    }
    public var selectedIndexPath = IndexPath(row: 0, section: 0)
    
    // MARK: - Private properties
    fileprivate var recurrenceBackup: TBRecurrence?
    fileprivate var presetRepeats = [String]()
    fileprivate var internationalControl: TBRPInternationalControl?
    
    // MARK: - View life cycle
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        commonInit()
    }
    
    fileprivate func commonInit() {
        internationalControl = TBRPInternationalControl(language: language)
        navigationItem.title = internationalControl?.localized("TBRPPresetRepeatController.navigation.title", comment: "Repeat")
        
        navigationController?.navigationBar.tintColor = tintColor
        tableView.tintColor = tintColor
        
        presetRepeats = TBRPHelper.presetRepeats(language)
        
        if let _ = recurrence {
            recurrenceBackup = recurrence!.recurrenceCopy()
        }
    }
    
    override public func didMove(toParentViewController parent: UIViewController?) {
        if parent == nil {
            // navigation was popped
            if TBRecurrence.isEqualRecurrence(recurrence, recurrence2: recurrenceBackup) == false {
                if let _ = delegate {
                    delegate?.didPickRecurrence(recurrence, repeatPicker: self as! TBRepeatPicker)
                }
            }
        }
    }
    
    // MARK: - Helper
    fileprivate func setupSelectedIndexPath(_ recurrence: TBRecurrence?) {
        guard let recurrence = recurrence else {
            selectedIndexPath = IndexPath(row: 0, section: 0)
            return
        }
        if recurrence.isDailyRecurrence() {
            selectedIndexPath = IndexPath(row: 1, section: 0)
        } else if recurrence.isWeeklyRecurrence() {
            selectedIndexPath = IndexPath(row: 2, section: 0)
        } else if recurrence.isBiWeeklyRecurrence() {
            selectedIndexPath = IndexPath(row: 3, section: 0)
        } else if recurrence.isMonthlyRecurrence() {
            selectedIndexPath = IndexPath(row: 4, section: 0)
        } else if recurrence.isYearlyRecurrence() {
            selectedIndexPath = IndexPath(row: 5, section: 0)
        } else {
            selectedIndexPath = IndexPath(row: 0, section: 1)
        }
    }
    
    fileprivate func updateRecurrence(_ indexPath: IndexPath) {
        if indexPath.section == 1 {
            return
        }
        
        switch indexPath.row {
        case 0:
            recurrence = nil
            
        case 1:
            recurrence = TBRecurrence.dailyRecurrence()
        
        case 2:
            recurrence = TBRecurrence.weeklyRecurrence()
            
        case 3:
            recurrence = TBRecurrence.biWeeklyRecurrence()
            
        case 4:
            recurrence = TBRecurrence.monthlyRecurrence()
            
        case 5:
            recurrence = TBRecurrence.yearlyRecurrence()
            
        default:
            break
        }
    }
    
    fileprivate func updateFooterTitle() {
        let footerView = tableView.footerView(forSection: 1)
        
        tableView.beginUpdates()
        footerView?.textLabel?.text = footerTitle()
        tableView.endUpdates()
        footerView?.setNeedsLayout()
    }
    
    fileprivate func footerTitle() -> String? {
        if let _ = recurrence {
            if selectedIndexPath.section == 0 {
                return nil
            }
            return TBRPHelper.recurrenceString(recurrence!, language: language)
        }
        return nil
    }
    
    // MARK: - Table view data source
    override public func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    override public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return presetRepeats.count
        } else {
            return 1
        }
    }
    
    override public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44.0
    }
    
    override public func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        if section == 1 && recurrence != nil {
            return footerTitle()
        }
        return nil
    }
    
    override public func tableView(_ tableView: UITableView, willDisplayFooterView view: UIView, forSection section: Int) {
        if view.isKind(of: UITableViewHeaderFooterView.self) {
            let tableViewHeaderFooterView = view as! UITableViewHeaderFooterView
            tableViewHeaderFooterView.textLabel?.font = UIFont.systemFont(ofSize: CGFloat(13.0))
        }
    }
    
    override public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: TBRPPresetRepeatCellID)
        if cell == nil {
            cell = UITableViewCell(style: .default, reuseIdentifier: TBRPPresetRepeatCellID)
        }
        
        if indexPath.section == 1 {
            cell?.accessoryType = .disclosureIndicator
            cell?.textLabel?.text = internationalControl?.localized("TBRPPresetRepeatController.textLabel.custom", comment: "Custom")
        } else {
            cell?.accessoryType = .none
            cell?.textLabel?.text = presetRepeats[indexPath.row]
        }

        cell?.textLabel?.font = self.cellFont
        cell?.textLabel?.textColor = self.cellTextColor

        cell?.imageView?.image = self.checkmark()
        
        if indexPath == selectedIndexPath {
            cell?.imageView?.isHidden = false
        } else {
            cell?.imageView?.isHidden = true
        }


        return cell!
    }

    // MARK: - Table view delegate
    override public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let lastSelectedCell = tableView.cellForRow(at: selectedIndexPath)
        let currentSelectedCell = tableView.cellForRow(at: indexPath)
        
        lastSelectedCell?.imageView?.isHidden = true
        currentSelectedCell?.imageView?.isHidden = false
        
        selectedIndexPath = indexPath
        
        if indexPath.section == 1 {
            let customRepeatController = TBRPCustomRepeatController(style: .grouped)
            customRepeatController.occurrenceDate = occurrenceDate
            customRepeatController.tintColor = tintColor
            customRepeatController.language = language
            customRepeatController.cellFont = self.cellFont
            customRepeatController.cellTextColor = self.cellTextColor
            
            if let _ = recurrence {
                customRepeatController.recurrence = recurrence!
            } else {
                customRepeatController.recurrence = TBRecurrence.dailyRecurrence(occurenceDate: occurrenceDate)
            }
            customRepeatController.delegate = self
            
            navigationController?.pushViewController(customRepeatController, animated: true)
        } else {
            updateRecurrence(indexPath)
            updateFooterTitle()
            
            _ = navigationController?.popViewController(animated: true)
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
    }

    private func checkmark() -> UIImage? {
        let bundle = Bundle(for: type(of: self)).url(forResource: "TBRepeatPicker", withExtension: "bundle")
                                                .flatMap(Bundle.init(url:))
        return UIImage(named: "TBRP-Checkmark", in: bundle,
                       compatibleWith: nil)?.withRenderingMode(.alwaysTemplate)
    }

    // MARK: - TBRPCustomRepeatController delegate
    func didFinishPickingCustomRecurrence(_ recurrence: TBRecurrence) {
        self.recurrence = recurrence
        updateFooterTitle()
        tableView.reloadData()
    }
}
