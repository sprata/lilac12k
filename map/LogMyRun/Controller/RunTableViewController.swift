import UIKit
import MapKit
import HealthKit
import CoreLocation
import Foundation
import CoreData

class RunTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    var runs = [Run]()
    var selectedRun:Run!
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.loadData()
        self.tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "cell")
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print(runs.count)
        return runs.count;
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell:RunPageCell = (self.tableView.dequeueReusableCellWithIdentifier("RunCell"))! as! RunPageCell
        if runs.isEmpty == false {
            let run = runs[indexPath.row]
            //floor(1.5679999 * 1000) / 1000
            let distanceQuantity = HKQuantity(unit: HKUnit.mileUnit(), doubleValue: floor(((run.distance?.doubleValue)! / 1609.34)*1000)/1000)
            cell.CellDistance.text = distanceQuantity.description
            
            let dateFormatter = NSDateFormatter()
            dateFormatter.dateStyle = .MediumStyle
            cell.CellTimestamp.text = dateFormatter.stringFromDate(run.timestamp!)
            
            let secondQuantity = HKQuantity(unit: HKUnit.secondUnit(), doubleValue:(run.duration?.doubleValue)!)
            cell.CellDuration.text = secondQuantity.description
        }
        return cell
    }
    
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        print("You selected cell #\(indexPath.row)!")
        selectedRun = runs[indexPath.row]
        self.performSegueWithIdentifier("ShowRunDetail", sender: nil)
        //sender.selected=!sender.selected;
        //UserInformation.sharedInstance.currentPersonTrackingByIndex = indexPath.row
    }
    
    func loadData() {
        let appDelegate =
        UIApplication.sharedApplication().delegate as! AppDelegate
        
        let managedContext = appDelegate.managedObjectContext
        let fetchRequest = NSFetchRequest(entityName: "Run")
        do {
            let results =
            try managedContext.executeFetchRequest(fetchRequest)
            runs = results as! [Run]
            //runs.sort({ $0.date.compare($1.date) == NSComparisonResult.OrderedAscending })
            runs = runs.sort({ $0.timestamp!.compare($1.timestamp!) == NSComparisonResult.OrderedAscending })
            runs = runs.reverse()
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if let detailViewController = segue.destinationViewController as? IBRunDetailViewController {
            detailViewController.run = selectedRun
        }
    }
    
}