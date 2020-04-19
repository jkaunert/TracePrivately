//
//  ExposedViewController.swift
//  TracePrivately
//

import UIKit

class ExposedViewController: UITableViewController {

    struct Cells {
        static let standard = "Cell"
    }

    enum RowType {
        case contact(CTContactInfo)
        case nextSteps
    }
    
    struct Section {
        let header: String?
        let footer: String?
        
        let rows: [RowType]
    }
    
    var sections: [Section] = []

    var exposureContacts: [CTContactInfo] = []
    
    lazy var timeFormatter: DateFormatter = {
        let ret = DateFormatter()
        ret.dateStyle = .medium
        ret.timeStyle = .medium
        
        return ret
    }()
    
    lazy var durationFormatter: DateComponentsFormatter = {
        let ret = DateComponentsFormatter()
        ret.allowedUnits = [ .day, .hour, .minute ]
        ret.unitsStyle = .abbreviated
        ret.zeroFormattingBehavior = .dropLeading
        ret.maximumUnitCount = 2
        
        return ret
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = NSLocalizedString("exposure.exposed.title", comment: "")
        
        if self.exposureContacts.count == 0 {
            let title = String(format: NSLocalizedString("exposure.none.message", comment: ""), Disease.current.localizedTitle)
            self.sections = [
                Section(header: nil, footer: title, rows: [])
            ]
        }
        else {
            
            let sortedContacts = self.exposureContacts.sorted { (a, b) -> Bool in
                return a.timestamp < b.timestamp
            }
            
            let title = String(format: NSLocalizedString("exposure.exposed.message", comment: "") , Disease.current.localizedTitle)

            self.sections = [
                Section(header: nil, footer: title, rows: []),
                Section(header: NSLocalizedString("exposure.times.title", comment: ""), footer: nil, rows: sortedContacts.map { .contact($0)} ),
                Section(header: nil, footer: nil, rows: [ .nextSteps ])
            ]
        }
    }
}

extension ExposedViewController {
    override func numberOfSections(in tableView: UITableView) -> Int {
        return self.sections.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.sections[section].rows.count
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return self.sections[section].header
    }
    
    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        return self.sections[section].footer
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Cells.standard, for: indexPath)

        let rowType = self.sections[indexPath.section].rows[indexPath.row]
        
        switch rowType {
        case .contact(let contact):
            cell.textLabel?.text = self.timeFormatter.string(from: contact.date)
            
            
            if let str = self.durationFormatter.string(from: contact.duration) {
                cell.detailTextLabel?.text = String(format: NSLocalizedString("exposure.times.duration", comment: ""), str)
            }
            else {
                cell.detailTextLabel?.text = nil
            }
            
            cell.selectionStyle = .none
            cell.accessoryType = .none
            
        case .nextSteps:
            cell.textLabel?.text = NSLocalizedString("exposure.next_steps.title", comment: "")
            cell.detailTextLabel?.text = nil
            cell.accessoryType = .disclosureIndicator
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let rowType = self.sections[indexPath.section].rows[indexPath.row]
        
        tableView.deselectRow(at: indexPath, animated: true)

        switch rowType {
        case .contact:
            break
            
        case .nextSteps:
            let alert = UIAlertController(title: NSLocalizedString("exposure.next_steps.title", comment: ""), message: NSLocalizedString("exposure.next_steps.message", comment: ""), preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: NSLocalizedString("ok", comment: ""), style: .default, handler: nil))
            
            self.present(alert, animated: true, completion: nil)
        }
        
    }
}
