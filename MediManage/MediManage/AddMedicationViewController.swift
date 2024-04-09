import UIKit

protocol AddMedicationDelegate: AnyObject {
    func didAddMedication(_ medication: Medication)
}

class AddMedicationViewController: UIViewController {

    weak var delegate: AddMedicationDelegate?

    private let nameTextField = UITextField()
    private let dosageTextField = UITextField()
    private let timePicker = UIDatePicker()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Add Medication"
        view.backgroundColor = .white

        setupTextFields()
        setupTimePicker()
        setupSaveButton()
    }

    private func setupTextFields() {
        // Setup name text field
        nameTextField.placeholder = "Medication Name"
        nameTextField.borderStyle = .roundedRect
        view.addSubview(nameTextField)
        nameTextField.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            nameTextField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            nameTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            nameTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            nameTextField.heightAnchor.constraint(equalToConstant: 40)
        ])

        // Setup dosage text field
        dosageTextField.placeholder = "Dosage"
        dosageTextField.borderStyle = .roundedRect
        view.addSubview(dosageTextField)
        dosageTextField.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            dosageTextField.topAnchor.constraint(equalTo: nameTextField.bottomAnchor, constant: 20),
            dosageTextField.leadingAnchor.constraint(equalTo: nameTextField.leadingAnchor),
            dosageTextField.trailingAnchor.constraint(equalTo: nameTextField.trailingAnchor),
            dosageTextField.heightAnchor.constraint(equalTo: nameTextField.heightAnchor)
        ])
    }

    private func setupTimePicker() {
        timePicker.datePickerMode = .time
        timePicker.preferredDatePickerStyle = .compact
        view.addSubview(timePicker)
        timePicker.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            timePicker.topAnchor.constraint(equalTo: dosageTextField.bottomAnchor, constant: 20),
            timePicker.leadingAnchor.constraint(equalTo: dosageTextField.leadingAnchor),
            timePicker.trailingAnchor.constraint(equalTo: dosageTextField.trailingAnchor)
        ])
    }

    private func setupSaveButton() {
        let saveButton = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(saveMedication))
        navigationItem.rightBarButtonItem = saveButton
    }

    @objc private func saveMedication() {
        guard let name = nameTextField.text, !name.isEmpty,
              let dosage = dosageTextField.text, !dosage.isEmpty else {
            // Show alert for invalid input
            let alertController = UIAlertController(title: "Error", message: "Please enter medication name and dosage", preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            present(alertController, animated: true, completion: nil)
            return
        }

        let medication = Medication(name: name, dosage: dosage, timeOfDay: timePicker.date) 
        delegate?.didAddMedication(medication)
        NotificationManager.scheduleNotification(for: medication) 
        navigationController?.popViewController(animated: true)
    }
}
