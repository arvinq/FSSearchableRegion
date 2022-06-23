//
// Copyright © 2022 arvinq. All rights reserved.
//
	

import UIKit

class RegionViewController: UIViewController {

    var isSearching: Bool = false
    
    lazy var regionsTableView: UITableView = {
        let tableView = UITableView()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(RegionTableViewCell.self, forCellReuseIdentifier: RegionTableViewCell.reuseId)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.tableFooterView = UIView(frame: .zero)
        return tableView
    }()
    
    lazy var activityIndicator: UIActivityIndicatorView = {
        let activityIndicator = UIActivityIndicatorView(style: .large)
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        return activityIndicator
    }()
    
    lazy var searchController: UISearchController = {
        let searchController = UISearchController()
        searchController.searchResultsUpdater = self
        searchController.searchBar.delegate = self
        searchController.searchBar.placeholder = Constant.searchPlaceholder
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.hidesNavigationBarDuringPresentation = false
        return searchController
    }()
    
    lazy var doneBarButton: UIBarButtonItem = {
        let barButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneButtonTapped))
        return barButtonItem
    }()
    
    lazy var backBarButton: UIBarButtonItem = {
        let barButtonItem = UIBarButtonItem(image: SFSymbols.back, style: .plain, target: self, action: #selector(doneButtonTapped))
        return barButtonItem
    }()
    
    lazy var viewModelManager: ViewModelManager = {
       return ViewModelManager()
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        startObservingKeyboardChanges()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        stopObservingKeyboardChanges()
    }

    private func setup() {
        setupView()
        setupConstraint()
        setupViewModel()
        
        // fetch and setup our tableView based on the retrieved regions
        viewModelManager.getRegions()
    }
    
    private func setupView() {
        title = ViewTitle.main
        view.backgroundColor = .systemBackground
        
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        
        /// bar button item doesn't do anything but since it is included in the sample screen to mock, we're including it here.
        navigationItem.setRightBarButton(doneBarButton, animated: true)
        navigationItem.setLeftBarButton(backBarButton, animated: true)
        
        view.addSubview(activityIndicator)
        view.addSubview(regionsTableView)
    }
    
    private func setupConstraint() {
        NSLayoutConstraint.activate([
            regionsTableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            regionsTableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            regionsTableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            regionsTableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    /// Sets up the bindings values that will get triggered upon viewModel's property assignment
    private func setupViewModel() {
        // presenting alert
        viewModelManager.presentAlert = { [weak self] in
            guard let self = self else { return }
            let message = self.viewModelManager.alertMessage ?? ""
            
            DispatchQueue.main.async {
                self.presentAlert(withTitle: ViewTitle.alert, andMessage: message, completion: nil)
            }
        }
        
        // reloading our tableView
        viewModelManager.reloadRegionsTable = { [weak self] in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.regionsTableView.reloadData()
            }
        }
        
        // animating our activity indicator
        viewModelManager.animateLoadView = { [weak self] in
            guard let self = self else { return }
            let isLoading = self.viewModelManager.isLoading
            
            DispatchQueue.main.async {
                if isLoading {
                    self.activityIndicator.startAnimating()
                    UIView.animate(withDuration: Animation.duration) {
                        self.regionsTableView.alpha = Alpha.weakFade
                    }
                } else {
                    self.activityIndicator.stopAnimating()
                    UIView.animate(withDuration: Animation.duration) {
                        self.regionsTableView.alpha = Alpha.solid
                    }
                }
            }
        }
    }
    
    @objc
    func doneButtonTapped() { }
}

extension RegionViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let regionViewModels = viewModelManager.getRegionViewModels(isSearching: isSearching)
        return regionViewModels.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let regionCell = tableView.dequeueReusableCell(withIdentifier: RegionTableViewCell.reuseId, for: indexPath) as! RegionTableViewCell
        regionCell.regionViewModel = viewModelManager.getRegionViewModel(onIndex: indexPath.row, isSearching: isSearching)
        return regionCell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        viewModelManager.configureSelectionState(onIndex: indexPath.row, isSearching: isSearching)
    }

}

extension RegionViewController: UISearchResultsUpdating, UISearchBarDelegate {
    func updateSearchResults(for searchController: UISearchController) {
        guard let searchedRegion = searchController.searchBar.text, !searchedRegion.isEmpty else {
            // if search text is empty, we just use original ViewModel list and set it as the initial value for our filtered list
            viewModelManager.setInitialFilteredRegions()
            return
        }
        
        // invoke filtering on the searched region and update our list
        isSearching = true
        viewModelManager.filterRegion(onName: searchedRegion)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        isSearching = false
        viewModelManager.setInitialFilteredRegions()
    }
    
}

extension RegionViewController {
    /**
     * Abstracted all the keyboard related functions.
     */
    
    func startObservingKeyboardChanges() {
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyBoardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyBoardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    func stopObservingKeyboardChanges() {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func keyBoardWillShow(notification: NSNotification) {
        if let _ = notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? CGRect {
            // once keyboard has shown, we increase the contentInsets, particularly the bottom of the tableView to
            // avoid overlapping keyboard and views
            let contentInsets = UIEdgeInsets(top: 0, left: 0, bottom: Size.keyboardHeight, right: 0)
            self.regionsTableView.contentInset = contentInsets
        }
    }

    @objc func keyBoardWillHide(notification: NSNotification) {
        // remove the insets when keyboard hides.
        self.regionsTableView.contentInset = UIEdgeInsets.zero
    }
}
