import UIKit

protocol MedicationListViewControllerDelegate: AnyObject {
    func didEditMedication()
}

class MedicationListViewController: UIViewController {
    var selectedDate: Date?
    weak var delegate: MedicationListViewControllerDelegate?
    
    private var medications: [Medication] = [] {
        didSet {
            saveMedications()
        }
    }
    
    private let tableView = UITableView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Medication List"
        view.backgroundColor = .white
        
        setupTableView()
        setupNavigationBar()
        loadMedications()
    }
    
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
    
    private func setupNavigationBar() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addMedication))
    }
    
    @objc private func addMedication() {
        let addMedicationVC = AddMedicationViewController()
        addMedicationVC.delegate = self
        navigationController?.pushViewController(addMedicationVC, animated: true)
    }
}

// MARK: - UITableViewDelegate & UITableViewDataSource

extension MedicationListViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return medications.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let medication = medications[indexPath.row]
        cell.textLabel?.text = "\(medication.name) - Dosage: \(medication.dosage)"
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let medication = medications[indexPath.row]
        let alertController = UIAlertController(title: "Options for \(medication.name)", message: nil, preferredStyle: .actionSheet)
        
        let editAction = UIAlertAction(title: "Edit", style: .default) { [unowned self] _ in
            self.editMedication(medication) { editedMedication in
                if let index = self.medications.firstIndex(where: { $0 == medication }) {
                    self.medications[index] = editedMedication
                    self.tableView.reloadData()
                    self.saveMedications()
                }
            }
        }
        
        let deleteAction = UIAlertAction(title: "Delete", style: .destructive) { [weak self] _ in
            self?.deleteMedication(medication)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alertController.addAction(editAction)
        alertController.addAction(deleteAction)
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true, completion: nil)
    }
}

// MARK: - AddMedicationDelegate

extension MedicationListViewController: AddMedicationDelegate {
    func didAddMedication(_ medication: Medication) {
        medications.append(medication)
        tableView.reloadData()
    }
}

// MARK: - Private Methods

private extension MedicationListViewController {
    private func editMedication(_ medication: Medication, completion: @escaping (Medication) -> Void) {
        var editedMedication = medication
        
        let alertController = UIAlertController(title: "Edit Medication", message: nil, preferredStyle: .alert)
        alertController.addTextField { textField in
            textField.text = medication.name
            textField.placeholder = "Medication Name"
        }
        alertController.addTextField { textField in
            textField.text = medication.dosage
            textField.placeholder = "Dosage"
        }
        
        let saveAction = UIAlertAction(title: "Save", style: .default) { _ in
            guard let nameTextField = alertController.textFields?[0],
                  let dosageTextField = alertController.textFields?[1],
                  let name = nameTextField.text,
                  let dosage = dosageTextField.text else {
                return
            }
            
            editedMedication.name = name
            editedMedication.dosage = dosage
            
            completion(editedMedication)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alertController.addAction(saveAction)
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true, completion: nil)
    }
    
    private func deleteMedication(_ medication: Medication) {
        if let index = medications.firstIndex(of: medication) {
            medications.remove(at: index)
            tableView.reloadData()
        }
    }
    
    // MARK: - Data Persistence
    
    private func saveMedications() {
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(medications) {
            UserDefaults.standard.set(encoded, forKey: "medications")
        }
    }
    
    private func loadMedications() {
        if let savedData = UserDefaults.standard.data(forKey: "medications"),
           let loadedMedications = try? JSONDecoder().decode([Medication].self, from: savedData) {
            medications = loadedMedications
            tableView.reloadData()
        }
    }
}

// Sources:
//https://developer.apple.com/documentation/uikit/uitableview
//https://developer.apple.com/documentation/foundation/jsonencoder
//https://programmingwithswift.com/uitableviewcell-swipe-actions-with-swift/
//https://developer.apple.com/documentation/swiftdata/adding-and-editing-persistent-data-in-your-app"
//https://developer.apple.com/documentation/uikit/uibarbuttonitem
//https://developer.apple.com/documentation/uikit/uinavigationitem
