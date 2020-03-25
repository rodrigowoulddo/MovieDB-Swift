//
//  MovieDetailViewController.swift
//  MovieDB-Swift
//
//  Created by Rodrigo Giglio on 25/03/20.
//  Copyright © 2020 Rodrigo Giglio. All rights reserved.
//

import UIKit

class MovieDetailViewController: UIViewController {
    
    // MARK: - Outlets
    @IBOutlet weak var movieCoverImageView: UIImageView!
    @IBOutlet weak var movieTitleLabel: UILabel!
    @IBOutlet weak var movieRatingLabel: UILabel!
    @IBOutlet weak var movieOverviewTextView: UITextView!
    
    // MARK: - Variables
    var movie: Movie?
    var coverSessionTask: URLSessionTask?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "MovieDetail"
        
        guard let movie = self.movie else { return }
        configure(with: movie)
    }
    
    func configure(with movie: Movie) {
        
        /// Set texts
        movieTitleLabel.text = movie.title
        movieOverviewTextView.text = movie.overview
        
        /// Sets rating
        let roundedRating = Double(round(10 * movie.rating.floatValue / 10))
        movieRatingLabel.text = String(roundedRating)
        
        
        /// Sets image
        movieCoverImageView.layer.cornerRadius = 8
        
        coverSessionTask?.cancel()
        
        print("Will load cover for: \(movie.title)")
        
        guard let imageUrl = movie.imageUrl else {
            print("No cover image available")
            movieCoverImageView.image = nil
            return
        }
        
        print ("Loading cover from: \(imageUrl)")
        coverSessionTask = MovieDBRequest.getMovieImageData(fromPath: imageUrl, andSize: ImageSize.init(rawValue: 1)) {
            data in
            
            guard let data = data else {
                print("Image data response was NULL")
                self.movieCoverImageView.image = nil
                return
            }
            
            guard let image = UIImage(data: data) else {
                print("Error converting data response to image")
                self.movieCoverImageView.image = nil
                return
            }
            
            DispatchQueue.main.async {
                self.movieCoverImageView.image = image
            }
            
            print("Successfuly loaded image")
            
        }
    }

}
