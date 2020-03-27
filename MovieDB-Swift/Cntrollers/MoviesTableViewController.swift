//
//  ViewController.swift
//  MovieDB-Swift
//
//  Created by Rodrigo Giglio on 24/03/20.
//  Copyright © 2020 Rodrigo Giglio. All rights reserved.
//

import UIKit

class MoviesTableViewController: UITableViewController {
    
    // MARK: - Constants
    fileprivate let DETAIL_SEGUE_ID = "detail"
    
    //MARK: - Variables
    var popularMovies: [Movie] = []
    var nowPlayingMovies: [Movie] = []
    var searchedMovies: [Movie] = []
    
    var currentPage: Int32 = 1
    
    var selectedMovie: Movie?
    
    var currentSearchTask: URLSessionTask?
    
    var searchController: UISearchController = UISearchController()
    var showldDisplaySearch: Bool = false
    
    // MARK: - Computed Variables
    
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Movies"
        navigationController?.navigationBar.prefersLargeTitles = true
        
        setupSearchBar()
        setupTableView()
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
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 150, right: 0)

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
        MovieDBRequest.getNowPlayingMovies(atPage: currentPage) {
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
    
    func loadNextPage() {
        
        currentPage += 1
        
        MovieDBRequest.getNowPlayingMovies(atPage: currentPage) {
            result in
            
            guard let movies = result as? [Movie] else {return}
            self.nowPlayingMovies.append(contentsOf: movies)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                self.tableView.reloadData()
            }
            
        }
        
    }
    
    func searchForMovies(query: String) {
        
        /*
         In case there is a search in progress,
         it is cancelled, in order to save data
         download and parsing.
         */
        currentSearchTask?.cancel()
        
        searchedMovies.removeAll()
        
        /// ...
        
        searchController.searchBar.setShowsCancelButton(true, animated: true)
        
        currentSearchTask = MovieDBRequest.searchMovies(withQuery: query) {
            result in
            
            guard let movies = result as? [Movie] else {return}
            self.searchedMovies = movies
            
            self.showldDisplaySearch = true
            
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    func cancelSearch() {
        
        currentSearchTask?.cancel()
        searchedMovies.removeAll()
        
        showldDisplaySearch = false
        
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
}

// MARK: - Segue
extension MoviesTableViewController {
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        guard let movieDetailVC = segue.destination as? MovieDetailViewController else { return }
        movieDetailVC.movie = selectedMovie
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
        
        let fade = (indexPath.row > movieList.count - 21 && (currentPage == 1 || indexPath.section == 1)) || showldDisplaySearch
        
        cell?.configure(with: movie, fade: fade)
        
        return cell ?? UITableViewCell()
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
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
        selectedMovie = movie
        
        performSegue(withIdentifier: DETAIL_SEGUE_ID, sender: nil)
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        /// Returns if the current list is not now playing
        if showldDisplaySearch { return }
        if indexPath.section == 0 { return }
        
        /// If it is the last cell
        if indexPath.row == nowPlayingMovies.count - 5 {
            
            loadNextPage()
            
        }
        
    }
    
}

// MARK: - UITableViewDelegate
extension MoviesTableViewController {
    
}

// MARK: - UISearchControllerDelegate
extension MoviesTableViewController: UISearchBarDelegate {
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        
        searchBar.setShowsCancelButton(true, animated: true)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        
        searchBar.setShowsCancelButton(false, animated: true)
        
        searchBar.text = ""
        
        cancelSearch()
        
        searchBar.resignFirstResponder()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        if searchText.isEmpty {
            cancelSearch()
        } else {
            searchForMovies(query: searchText)
        }
    }
}

// MARK: - UITextFieldDelegate
extension MoviesTableViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        textField.resignFirstResponder()
        return true
    }
    
}

