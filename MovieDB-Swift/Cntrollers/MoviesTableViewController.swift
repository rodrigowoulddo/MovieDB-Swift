//
//  ViewController.swift
//  MovieDB-Swift
//
//  Created by Rodrigo Giglio on 24/03/20.
//  Copyright © 2020 Rodrigo Giglio. All rights reserved.
//

import UIKit

class MoviesTableViewController: UITableViewController {
    
    //MARK: - Variables
    var popularMovies: [Movie] = []
    var nowPlayingMovies: [Movie] = []
    var searchedMovies: [Movie] = []
    
    var selectedMovie: Movie?
    
    var currentSearchTask: URLSessionTask?
    var searchController: UISearchController = UISearchController()
    var showldDisplaySearch: Bool = false
    
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Movies"
        navigationController?.navigationBar.prefersLargeTitles = true
        
        setupSearchBar()
        loadMovies()
    }
    
    
    // MARK: - Methods
    func setupSearchBar() {
        
        /// Sets searchbar appearence and behaiviour
        searchController.searchBar.sizeToFit()
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.hidesNavigationBarDuringPresentation = true
        searchController.searchBar.searchTextField.clearButtonMode = .never
        searchController.searchBar.returnKeyType = .done
        
        /// Sets searchbar delegates
        searchController.searchBar.delegate = self
        searchController.searchBar.searchTextField.delegate = self
        
        /// Adds searchbar to navigation
        navigationItem.searchController = searchController
        
    }
    
    func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    func loadMovies() {
        
        popularMovies.removeAll()
        nowPlayingMovies.removeAll()
        
        let dispatchGroup = DispatchGroup()
        
        dispatchGroup.enter()
        MovieDBRequest.getPopularMovies {
            result in
            
            guard let movies = result as? [Movie] else {return}
            self.popularMovies = movies
            
            dispatchGroup.leave()
        }
        
        dispatchGroup.enter()
        MovieDBRequest.getNowPlayingMovies {
            result in
            
            guard let movies = result as? [Movie] else {return}
            self.nowPlayingMovies = movies
            
            dispatchGroup.leave()
        }
        
        dispatchGroup.notify(queue: .main) {
            self.showldDisplaySearch = false
            
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
            
        }
        
    }
    
}

// MARK: - UITableViewDataSource
extension MoviesTableViewController {
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return showldDisplaySearch ? 1 : 2
        
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if showldDisplaySearch {
            
            return searchedMovies.count
            
        } else {
            
            switch section {
                case 0: return self.popularMovies.count;
                case 1: return self.nowPlayingMovies.count;
                default: return 0;
            }
            
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 148
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        if showldDisplaySearch {
            
            return "Results";

        } else {
            
            switch (section) {
                case 0: return "Popular";
                case 1: return "Now Playing";
                default: return nil;
            }
            
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: MovieTableViewCell.identifier) as? MovieTableViewCell
        
        var movieList: [Movie]
        
        if showldDisplaySearch {
            
            movieList = searchedMovies
            
        } else {
            
            switch (indexPath.section) {
                case 0: movieList = popularMovies
                case 1: movieList = nowPlayingMovies
                default: movieList = []
            }
            
        }
        
        let movie = movieList[indexPath.row]
        
        cell?.configure(with: movie)
        
        return cell ?? UITableViewCell()
    }
    
}

// MARK: - UITableViewDelegate
extension MoviesTableViewController {
    
}

// MARK: - UISearchControllerDelegate
extension MoviesTableViewController: UISearchBarDelegate {
    
}

// MARK: - UITextFieldDelegate
extension MoviesTableViewController: UITextFieldDelegate {
    
}

