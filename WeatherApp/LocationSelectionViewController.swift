import UIKit
import CoreLocation

protocol LocationSelectionDelegate: AnyObject {
    func didSelectLocation(_ location: SavedLocation)
    func didSelectCurrentLocation()
}

class LocationSelectionViewController: UIViewController {
    
    // MARK: - Properties
    private let tableView = UITableView(frame: .zero, style: .grouped)
    private let searchController = UISearchController(searchResultsController: nil)
    
    private var savedLocations: [SavedLocation]
    private var filteredLocations: [SavedLocation] = []
    private var searchResults: [Location] = []
    
    private let weatherService = WeatherService()
    weak var delegate: LocationSelectionDelegate?
    
    // MARK: - Lifecycle
    init(savedLocations: [SavedLocation]) {
        self.savedLocations = savedLocations
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        title = "Weather Locations"
        view.backgroundColor = .systemBackground
        
        // Configure navigation items
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .close,
            target: self,
            action: #selector(closeButtonTapped)
        )
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .add,
            target: self,
            action: #selector(addButtonTapped)
        )
        
        // Configure search controller
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search for a city"
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        definesPresentationContext = true
        
        // Configure table view
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "LocationCell")
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "CurrentLocationCell")
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "SearchResultCell")
        
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    // MARK: - Actions
    @objc private func closeButtonTapped() {
        dismiss(animated: true)
    }
    
    @objc private func addButtonTapped() {
        // This will make the search bar active
        searchController.isActive = true
    }
    
    // MARK: - Search Methods
    private func searchForLocation(query: String) {
        weatherService.geocodeLocation(query: query) { [weak self] result in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                switch result {
                case .success(let locations):
                    self.searchResults = locations
                    self.tableView.reloadData()
                case .failure(let error):
                    self.showErrorAlert(message: error.localizedDescription)
                }
            }
        }
    }
    
    private func filterSavedLocations(searchText: String) {
        filteredLocations = savedLocations.filter { location in
            return location.name.lowercased().contains(searchText.lowercased()) ||
                   location.country.lowercased().contains(searchText.lowercased()) ||
                   (location.state?.lowercased().contains(searchText.lowercased()) ?? false)
        }
    }
    
    // MARK: - Helper Methods
    private func showErrorAlert(message: String) {
        let alert = UIAlertController(
            title: "Error",
            message: message,
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        
        present(alert, animated: true)
    }
    
    private func confirmAddLocation(location: Location) {
        let alert = UIAlertController(
            title: "Add Location",
            message: "Add \(location.name), \(location.country) to your saved locations?",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Add", style: .default) { [weak self] _ in
            self?.addLocationToSaved(location: location)
        })
        
        present(alert, animated: true)
    }
    
    private func addLocationToSaved(location: Location) {
        // First check if location already exists
        let exists = savedLocations.contains { savedLocation in
            return savedLocation.lat == location.lat && savedLocation.lon == location.lon
        }
        
        if exists {
            showErrorAlert(message: "This location is already in your saved locations")
            return
        }
        
        // Create a new saved location with generated ID
        let newLocation = SavedLocation(
            id: UUID().uuidString,
            name: location.name,
            lat: location.lat,
            lon: location.lon,
            country: location.country,
            state: location.state
        )
        
        // Add to the array
        savedLocations.append(newLocation)
        
        // Update the table view
        tableView.reloadData()
        
        // Close search
        searchController.isActive = false
    }
    
    private func confirmRemoveLocation(at indexPath: IndexPath) {
        let location = savedLocations[indexPath.row]
        
        let alert = UIAlertController(
            title: "Remove Location",
            message: "Remove \(location.name) from your saved locations?",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Remove", style: .destructive) { [weak self] _ in
            self?.removeLocation(at: indexPath)
        })
        
        present(alert, animated: true)
    }
    
    private func removeLocation(at indexPath: IndexPath) {
        savedLocations.remove(at: indexPath.row)
        tableView.deleteRows(at: [indexPath], with: .automatic)
    }
}

// MARK: - UITableViewDataSource
extension LocationSelectionViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return isSearchActive() ? 1 : 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isSearchActive() {
            return searchResults.isEmpty ? 0 : searchResults.count
        } else {
            return section == 0 ? 1 : savedLocations.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if isSearchActive() {
            // Display search results
            let cell = tableView.dequeueReusableCell(withIdentifier: "SearchResultCell", for: indexPath)
            let location = searchResults[indexPath.row]
            
            var locationText = location.name
            if let state = location.state {
                locationText += ", \(state)"
            }
            locationText += ", \(location.country)"
            
            cell.textLabel?.text = locationText
            cell.accessoryType = .none
            
            return cell
            
        } else if indexPath.section == 0 {
            // Current location cell
            let cell = tableView.dequeueReusableCell(withIdentifier: "CurrentLocationCell", for: indexPath)
            cell.textLabel?.text = "Current Location"
            cell.imageView?.image = UIImage(systemName: "location.fill")
            cell.imageView?.tintColor = .systemBlue
            
            return cell
            
        } else {
            // Saved location cell
            let cell = tableView.dequeueReusableCell(withIdentifier: "LocationCell", for: indexPath)
            let location = savedLocations[indexPath.row]
            
            var locationText = location.name
            if let state = location.state {
                locationText += ", \(state)"
            }
            locationText += ", \(location.country)"
            
            cell.textLabel?.text = locationText
            cell.accessoryType = .none
            
            return cell
        }
    }
    
    private func isSearchActive() -> Bool {
        return searchController.isActive && !(searchController.searchBar.text?.isEmpty ?? true)
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if isSearchActive() {
            return "Search Results"
        } else {
            return section == 0 ? nil : "Saved Locations"
        }
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Only allow editing saved locations (not current location or search results)
        return !isSearchActive() && indexPath.section == 1
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            confirmRemoveLocation(at: indexPath)
        }
    }
}

// MARK: - UITableViewDelegate
extension LocationSelectionViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if isSearchActive() {
            // Handle search result selection
            let selectedLocation = searchResults[indexPath.row]
            confirmAddLocation(location: selectedLocation)
            
        } else if indexPath.section == 0 {
            // Handle current location selection
            delegate?.didSelectCurrentLocation()
            dismiss(animated: true)
            
        } else {
            // Handle saved location selection
            let selectedLocation = savedLocations[indexPath.row]
            delegate?.didSelectLocation(selectedLocation)
            dismiss(animated: true)
        }
    }
}

// MARK: - UISearchResultsUpdating
extension LocationSelectionViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        guard let searchText = searchController.searchBar.text, !searchText.isEmpty else {
            searchResults = []
            tableView.reloadData()
            return
        }
        
        // If search text is at least 3 characters, perform network search
        if searchText.count >= 3 {
            searchForLocation(query: searchText)
        } else {
            searchResults = []
            tableView.reloadData()
        }
    }
}