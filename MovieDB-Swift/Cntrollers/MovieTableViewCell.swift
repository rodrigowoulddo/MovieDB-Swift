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
    
    func configure(with movie: Movie, fade: Bool = true) {
        
        /// Set texts
        movieTitleLabel.text = movie.title
        movieOverviewLabel.text = movie.overview
        
        /// Sets rating
        let roundedRating = Double(round(10 * movie.rating.floatValue / 10))
        movieRatingLabel.text = String(roundedRating)
        
        
        if fade {
            
            DispatchQueue.main.async {

                UIView.animate(withDuration: 0.3) {
                    self.contentView.alpha = 1
                }
            }
        }
         
        /// Sets image
        
        if fade {
            self.contentView.alpha = 0
        }

        DispatchQueue.main.async {
            self.movieCoverImageView.image = nil
        }
        
        movieCoverImageView.layer.cornerRadius = 8
        
        coverSessionTask?.cancel()
        
        print("Will load cover for: \(movie.title)")
        
        guard let imageUrl = movie.imageUrl else {
            print("No cover image available")
            self.setImage(nil, fade: fade)
            return
        }
        
        print ("Loading cover from: \(imageUrl)")
        coverSessionTask = MovieDBRequest.getMovieImageData(fromPath: imageUrl, andSize: ImageSize.init(rawValue: 0)) {
            data in
            
            if let data = data,
                let image = UIImage(data: data) {
                
                self.setImage(image, fade: fade)
                print("Successfuly loaded image")
                
            } else {
                
                self.setImage(nil, fade: fade)

            }
            
        }
    }
    
    func setImage(_ image: UIImage?, fade: Bool) {
        
        DispatchQueue.main.async {
            
            self.movieCoverImageView.image = image
            
            if fade {
                UIView.animate(withDuration: 0.3) { self.movieCoverImageView.alpha = 1 }
            } else {
                self.movieCoverImageView.alpha = 1
            }
            
        }
    }
    
}
