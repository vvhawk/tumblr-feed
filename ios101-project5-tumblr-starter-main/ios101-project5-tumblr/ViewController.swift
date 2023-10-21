//
//  ViewController.swift
//  ios101-project5-tumbler
//

import UIKit
import Nuke

class ViewController: UIViewController, UITableViewDataSource 
{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int 
    {
        // return rows
        return posts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell 
    {
//        // create cell
//        let cell = UITableViewCell()
        
        
        // Get a reusable cell
        // Returns a reusable table-view cell object for the specified reuse identifier and adds it to the table. This helps optimize table view performance as the app only needs to create enough cells to fill the screen and reuse cells that scroll off the screen instead of creating new ones.
        // The identifier references the identifier you set for the cell previously in the storyboard.
        // The `dequeueReusableCell` method returns a regular `UITableViewCell`, so we must cast it as our custom cell (i.e., `as! MovieCell`) to access the custom properties you added to the cell.
        let cell = tableView.dequeueReusableCell(withIdentifier: "PostCell", for: indexPath) as! PostCell
        
        
        // get post for row
        let post = posts[indexPath.row]
        
//        // configure cell
//        cell.textLabel?.text = post.summary
        
        
        // Unwrap the optional poster path
        // Get the first photo in the post's photos array
        if let photo = post.photos.first {
              let url = photo.originalSize.url
              
              // Load the photo in the image view via Nuke library...

            Nuke.loadImage(with: url, into: cell.photoImageView)
        }
        
        cell.summaryLabel.text = post.summary
        
        
        
        
        
        return cell
    }
    

    @IBOutlet weak var tableView: UITableView!
    
    
    
    private var posts: [Post] = []
    
    
    // 1. Add the UIRefreshControl property
       private var refreshControl = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        // 2. Configure the UIRefreshControl
                refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
                refreshControl.addTarget(self, action: #selector(refreshPosts), for: .valueChanged)
                
                // Add the refresh control to the table view (for iOS 10+)
                tableView.refreshControl = refreshControl
        
        
        tableView.dataSource = self
        
        fetchPosts()
        
    }
    
    
    // 3. Implement the refresh action
        @objc func refreshPosts() {
            fetchPosts()
            // Note: The refreshControl.endRefreshing() will be called inside fetchPosts() once data is fetched.
        }



    func fetchPosts() {
        let url = URL(string: "https://api.tumblr.com/v2/blog/humansofnewyork/posts/photo?api_key=1zT8CiXGXFcQDyMFG7RtcfGLwTdDjFUJnZzKJaWTmgyK4lKGYk")!
        let session = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("❌ Error: \(error.localizedDescription)")
                return
            }

            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, (200...299).contains(statusCode) else {
                print("❌ Response error: \(String(describing: response))")
                return
            }

            guard let data = data else {
                print("❌ Data is NIL")
                return
            }

            do {
                let blog = try JSONDecoder().decode(Blog.self, from: data)

                DispatchQueue.main.async { [weak self] in

                    let posts = blog.response.posts
                    
                    self?.posts = posts
                    
                    self?.tableView.reloadData()
                    
                    // Stop the refresh animation
                                self?.refreshControl.endRefreshing()


                    print("✅ We got \(posts.count) posts!")
                    for post in posts {
                        print("🍏 Summary: \(post.summary)")
                    }
                }

            } catch {
                print("❌ Error decoding JSON: \(error.localizedDescription)")
            }
        }
        session.resume()
    }
}
