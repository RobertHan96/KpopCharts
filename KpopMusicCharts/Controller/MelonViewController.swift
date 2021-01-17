//
//  ViewController.swift
//  KpopMusicCharts
//
//  Created by Mac on 2020/12/24.
//

import UIKit
import Firebase
import FirebaseFirestore

class MelonViewController: UIViewController {
    @IBOutlet weak var melonTableView: UITableView!
    var songs :[Song] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        fetchData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    private func setupUI() {
        melonTableView.delegate = self
        melonTableView.dataSource = self
        melonTableView.register(UINib(nibName: "SongTableViewCell", bundle: nil), forCellReuseIdentifier: "songCell")
    }


    func fetchData()  {
        let docRef = Firestore.firestore().collection("songs")
        docRef.whereField("from", isEqualTo: "Melon").getDocuments() { (querySnapshot, err) in
                if let err = err {
                    print("Error getting documents: \(err)")
                } else {
                    var count : Int = 0
                    for document in querySnapshot!.documents {
                        guard let title = document.data()["title"] as? String else {return}
                        guard let artist = document.data()["artist"] as? String else {return}
                        guard let url = document.data()["url"] as? String else {return}
                        guard let rank = document.data()["rank"] as? Int else {return}
                        guard let from = document.data()["from"] as? String else {return}
                        let song : Song = Song(title : title, artist : artist, url : url,
                            rank: rank, from : from)
                        
                        self.songs.append(song)
                        count += 1
                        if count == 100 {
                            break
                        }
                }
                    self.melonTableView.reloadData()
            }
        }
    }

}

extension MelonViewController : UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        songs.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let tableViewCellHeight = tableView.frame.width / 5
        return tableViewCellHeight
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "songCell", for: indexPath) as? SongTableViewCell
            else { return UITableViewCell() }
        let url = URL(string: songs[indexPath.row].url)
        var albumart = Data()
        do {
            albumart = try Data(contentsOf: url!)
            } catch {
                popupError(currentView: self)
            }
        songs = songs.sorted(by: {$0.rank < $1.rank})
        cell.titleLabel.text = songs[indexPath.row].title
        cell.artistLabel.text = songs[indexPath.row].artist
        cell.rankLabel.text = "\(indexPath.row+1)"
        cell.albumartImageView.image = UIImage(data: albumart)
        
        return cell
    }
}
