//
//  MovieTableViewCell.swift
//  MovieDB-Swift
//
//  Created by Rodrigo Giglio on 24/03/20.
//  Copyright © 2020 Rodrigo Giglio. All rights reserved.
//

import UIKit

class MovieTableViewCell: UITableViewCell {

    // MARK: - Constants
    public static let identifier = "MovieTableViewCell"
    
    // MARK: - Outlets
    @IBOutlet weak var movieCoverImageView: UIImageView!
    @IBOutlet weak var movieTitleLabel: UILabel!
    @IBOutlet weak var movieOverviewLabel: UILabel!
    @IBOutlet weak var movieRatingLabel: UILabel!
    
    // MARK: - Variables
    var coverSessionTask: URLSessionTask?
    

    
    override func awakeFromNib() {
        super.awakeFromNib()

        
    }
    
    func configure(with movie: Movie) {
        
        /// Set texts
        movieTitleLabel.text = movie.title
        movieOverviewLabel.text = movie.overview
        
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
        coverSessionTask = MovieDBRequest.getMovieImageData(fromPath: imageUrl, andSize: ImageSize.init(rawValue: 0)) {
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
