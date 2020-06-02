import UIKit
import TinkLink

protocol BeneficiaryPickerViewControllerDelegate: AnyObject {
    func beneficiaryPickerViewController(_ viewController: BeneficiaryPickerViewController, didSelectBeneficiary beneficiary: Beneficiary)
    func beneficiaryPickerViewController(_ viewController: BeneficiaryPickerViewController, didEnterBeneficiaryURI beneficiaryURI: Beneficiary.URI)
}

class BeneficiaryPickerViewController: UITableViewController {
    private let transferContext = TransferContext()

    weak var delegate: BeneficiaryPickerViewControllerDelegate?

    private let sourceAccount: Account
    private var beneficiaries: [Beneficiary]
    private let selectedBeneficiary: Beneficiary?
    private var canceller: RetryCancellable?

    init(sourceAccount: Account, selectedBeneficiary: Beneficiary? = nil) {
        self.sourceAccount = sourceAccount
        self.beneficiaries = []
        self.selectedBeneficiary = selectedBeneficiary
        super.init(style: .plain)
        title = "Select Beneficiary"
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .compose, target: self, action: #selector(enterBeneficiary))

        canceller = transferContext.fetchBeneficiaries(for: sourceAccount) { [weak self] result in
            DispatchQueue.main.async {
                do {
                    self?.beneficiaries = try result.get()
                    self?.tableView.reloadData()
                } catch {
                    self?.showAlert(for: error)
                }
            }
        }

        tableView.register(SubtitleTableViewCell.self, forCellReuseIdentifier: "Cell")
    }

    @objc private func enterBeneficiary(_ sender: Any) {
        let alert = UIAlertController(title: "Enter Beneficiary URI", message: nil, preferredStyle: .alert)
        alert.addTextField { (textField) in
            textField.placeholder = "Type"
            textField.autocorrectionType = .no
            textField.autocapitalizationType = .none
        }
        alert.addTextField { (textField) in
            textField.placeholder = "Account Number"
            textField.autocorrectionType = .no
            textField.autocapitalizationType = .none
        }
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Done", style: .default, handler: { _ in
            guard let type = alert.textFields?[0].text,
                let accountNumber = alert.textFields?[1].text,
                let uri = Beneficiary.URI(kind: .init(type), accountNumber: accountNumber)
                else { return }
            self.delegate?.beneficiaryPickerViewController(self, didEnterBeneficiaryURI: uri)
        }))
        present(alert, animated: true)
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return beneficiaries.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let beneficiary = beneficiaries[indexPath.row]
        cell.textLabel?.text = beneficiary.name
        cell.detailTextLabel?.text = "\(beneficiary.accountNumberType): \(beneficiary.accountNumber ?? "")"
        cell.accessoryType = beneficiary == selectedBeneficiary ? .checkmark : .none
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let beneficiary = beneficiaries[indexPath.row]
        delegate?.beneficiaryPickerViewController(self, didSelectBeneficiary: beneficiary)
    }
}
