import UIKit

final class LoadingViewController: UIViewController {
    override public var preferredStatusBarStyle: UIStatusBarStyle {
        let baseColor = (navigationController?.isNavigationBarHidden ?? true) ? Color.background : Color.navigationBarBackground
        if #available(iOS 13.0, *) {
            return baseColor.resolvedColor(with: traitCollection).isLight ? .darkContent : .lightContent
        } else {
            return baseColor.isLight ? .default : .lightContent
        }
    }

    private var onCancel: (() -> Void)?
    private var onRetry: (() -> Void)?
    private var onClose: (() -> Void)?

    private let activityIndicatorView = ActivityIndicatorView()
    private let label = UILabel()
    private let cancelButton = UIButton(type: .system)
    private let errorView = LoadingErrorView()

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = Color.background
        activityIndicatorView.tintColor = Color.accent

        activityIndicatorView.startAnimating()
        errorView.delegate = self
        errorView.isHidden = true

        cancelButton.setTitleColor(Color.button, for: .normal)
        cancelButton.titleLabel?.font = Font.subtitle1
        cancelButton.addTarget(self, action: #selector(cancel), for: .touchUpInside)
        cancelButton.setTitle(Strings.Generic.cancel, for: .normal)

        label.font = Font.subtitle1
        label.textColor = Color.label
        label.numberOfLines = 0
        label.textAlignment = .center

        label.translatesAutoresizingMaskIntoConstraints = false
        errorView.translatesAutoresizingMaskIntoConstraints = false
        activityIndicatorView.translatesAutoresizingMaskIntoConstraints = false
        cancelButton.translatesAutoresizingMaskIntoConstraints = false

        let contentView = UIView()
        contentView.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(contentView)
        contentView.addSubview(label)
        contentView.addSubview(activityIndicatorView)

        view.addSubview(cancelButton)
        view.addSubview(activityIndicatorView)
        view.addSubview(errorView)

        NSLayoutConstraint.activate([
            activityIndicatorView.topAnchor.constraint(equalTo: contentView.topAnchor),
            activityIndicatorView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            activityIndicatorView.bottomAnchor.constraint(equalTo: label.topAnchor, constant: -24),
            label.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            label.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            label.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),

            contentView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 32),
            contentView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -32),
            contentView.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor),

            cancelButton.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            cancelButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -12),

            errorView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            errorView.topAnchor.constraint(equalTo: view.topAnchor),
            errorView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            errorView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    func showLoadingIndicator() {
        DispatchQueue.main.async {
            self.activityIndicatorView.startAnimating()
            self.errorView.isHidden = true
        }
    }

    func hideLoadingIndicator() {
        DispatchQueue.main.async {
            self.activityIndicatorView.stopAnimating()
        }
    }

    func update(_ text: String?, onCancel: (() -> Void)?) {
        DispatchQueue.main.async {
            if let onCancel = onCancel {
                self.onCancel = onCancel
                self.cancelButton.isHidden = false
            } else {
                self.cancelButton.isHidden = true
            }

            self.label.text = text
        }
    }

    func setError(_ error: Error?, onClose: @escaping () -> Void, onRetry: (() -> Void)?) {
        DispatchQueue.main.async {
            self.hideLoadingIndicator()
            self.onRetry = onRetry
            self.onClose = onClose
            self.errorView.isHidden = false
            self.errorView.configure(with: error, showRetry: onRetry != nil)
        }
    }

    @objc private func cancel() {
        onCancel?()
    }
}

extension LoadingViewController: LoadingErrorViewDelegate {
    func reloadProviderList(loadingErrorView: LoadingErrorView) {
        onRetry?()
    }

    func closeErrorView(loadingErrorView: LoadingErrorView) {
        onClose?()
    }
}
