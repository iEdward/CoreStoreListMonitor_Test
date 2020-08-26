import UIKit
import CoreStore

class ViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView! {
        didSet {
            tableView.register(UITableViewCell.self, forCellReuseIdentifier: "identifier")
        }
    }
    
    let dataStack = DataStack(xcodeModelName: "Model")

    var listMonitor: ListMonitor<Model>?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        do {
            try dataStack.addStorageAndWait(
                SQLiteStore(fileName: "Storage.sqlite")
            )
        } catch { }
        
        let models = try? dataStack.fetchAll(From<Model>().orderBy(.ascending(\.uuid)))
        print(models)
        listMonitor = dataStack.monitorList(From<Model>().orderBy(.ascending(\.uuid)))
        
        listMonitor?.addObserver(self)
    }

    @IBAction func didTapAddButton(_ sender: Any) {
        dataStack.perform(
            asynchronous: { (transaction) -> Void in
                let model = transaction.create(Into<Model>())
                model.uuid = UUID().uuidString
            },
            completion: { (result) -> Void in

            }
        )
    }
    
    @IBAction func didTapRemoveButton(_ sender: Any) {
        dataStack.perform(
            asynchronous: { (transaction) -> Void in
                do {
                    let model = try transaction.fetchOne(From<Model>())
                    transaction.delete(model)
                } catch {}
            },
            completion: { (result) -> Void in

            }
        )
    }
}

extension ViewController: ListObserver {
    func listMonitorDidChange(_ monitor: ListMonitor<Model>) {
        tableView.reloadData()
    }
    
    func listMonitorDidRefetch(_ monitor: ListMonitor<Model>) {
        tableView.reloadData()
    }
}

extension ViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listMonitor?.numberOfObjects() ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "identifier", for: indexPath)

        if let model = listMonitor?.objectsInAllSections()[indexPath.item] {
            cell.textLabel?.text = model.uuid
        }
        
        return cell
    }
}
