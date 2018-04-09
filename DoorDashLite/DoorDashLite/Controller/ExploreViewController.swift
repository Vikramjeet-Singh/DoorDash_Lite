//
//  ExploreViewController.swift
//  DoorDashLite
//
//  Created by Vikramjeet Singh on 4/7/18.
//  Copyright © 2018 Vikramjeet Singh. All rights reserved.
//

import UIKit

protocol DependecyInjectable {
    associatedtype Dependency
    
    func inject(_ : Dependency)
    func assertDependencies()
}

final class ExploreViewController: UIViewController {

    // MARK: - IBOutlets
    
    @IBOutlet weak private var tableView: UITableView! {
        didSet {
            tableView.delegate = self
            tableView.dataSource = self
        }
    }
    
    // MARK: - Private Properties
    
    private var viewModel: ExploreViewModel?
    
    private var location: Location? {
        didSet {
            guard let loc = location else { return }
            self.viewModel = ExploreViewModel(location: loc) { error in
                DispatchQueue.main.async { [weak self] in
                    if let weakSelf = self {
                        weakSelf.hideHUD()
                        if let error = error {
                            let offlineController = UIAlertController(title: "Error fetching restaurants", message: error.localizedDescription, preferredStyle: .alert)
                            let doneAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                            offlineController.addAction(doneAction)
                            weakSelf.present(offlineController, animated: true, completion: nil)
                        } else {
                            weakSelf.updateView()
                        }
                    }
                }
            }
        }
    }
    
    // MARK: - View Controller lifecycle methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Confirm that dependencies are injected
        assertDependencies()
        initialSetup()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Cancel all outstanding/pending requests
        viewModel?.cancelAllPendingRequests()
    }
    
    private func initialSetup() {
        // Show HUD
        showHud(NSLocalizedString("Fetching Restaurants...", comment: ""))
        
        // set up title attributes
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor(red: 229.0/255.0, green: 0.0/255.0, blue: 0.0/255.0, alpha: 1.0)]
    }
    
    private func updateView() {
        if let viewModel = viewModel,
            viewModel.restaurantCount <= 0
        {
            let emptyResultController = UIAlertController(title: "", message:NSLocalizedString("No available restaurants", comment: ""), preferredStyle: .alert)
            let doneAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            emptyResultController.addAction(doneAction)
            present(emptyResultController, animated: true, completion: nil)
        } else {
            tableView.reloadData()
        }
    }
}

// MARK: - UITableViewDataSource methods

extension ExploreViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel?.numberOfSections() ?? 0
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel?.numberOfRowsInSection(section) ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let vModel = viewModel else { return UITableViewCell() }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: NearbyRestaurantCell.reuseIdentifier, for: indexPath) as? NearbyRestaurantCell
        cell?.configure(at: indexPath, with: vModel)
        return cell!
    }
}

// MARK: - UITableViewDelegate methods

extension ExploreViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {}
}

// MARK: - DependencyInjectable protocol methods
extension ExploreViewController: DependecyInjectable {
    func inject(_ location: Location?) {
        self.location = location
    }
    
    func assertDependencies() {
        assert(self.location != nil)
    }
}
