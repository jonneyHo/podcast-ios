import UIKit
import NVActivityIndicatorView

class BookmarkViewController: ViewController, EmptyStateTableViewDelegate, UITableViewDelegate, UITableViewDataSource, BookmarkTableViewCellDelegate, CacheEpisodeObserver {
    

    ///
    /// Mark: Constants
    ///
    var lineHeight: CGFloat = 3
    var topButtonHeight: CGFloat = 30
    var topViewHeight: CGFloat = 60
    
    ///
    /// Mark: Variables
    ///
    var bookmarkTableView: EmptyStateTableView!
    var episodes: [Episode] = []
    var currentlyPlayingIndexPath: IndexPath?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .paleGrey
        title = "Bookmarks"
    
        //tableview.
        bookmarkTableView = EmptyStateTableView(frame: view.frame, type: .bookmarks, isRefreshable: true)
        bookmarkTableView.delegate = self
        bookmarkTableView.emptyStateTableViewDelegate = self
        bookmarkTableView.dataSource = self
        bookmarkTableView.register(BookmarkTableViewCell.self, forCellReuseIdentifier: "BookmarkTableViewCellIdentifier")
        view.addSubview(bookmarkTableView)
        bookmarkTableView.rowHeight = BookmarkTableViewCell.height
        bookmarkTableView.reloadData()
        mainScrollView = bookmarkTableView

        fetchEpisodes()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //bookmarkTableView.reloadData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        Cache.sharedInstance.remove(observer: self, forEpisodes: episodes)
    }
    
    //MARK: -
    //MARK: TableView DataSource
    //MARK: -
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return episodes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "BookmarkTableViewCellIdentifier") as? BookmarkTableViewCell else { return UITableViewCell() }
        cell.delegate = self
        cell.setupWithEpisode(episode: episodes[indexPath.row])

        if episodes[indexPath.row].isPlaying {
            currentlyPlayingIndexPath = indexPath
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let episodeViewController = EpisodeDetailViewController()
        episodeViewController.episode = episodes[indexPath.row]
        navigationController?.pushViewController(episodeViewController, animated: true)
    }
    
    
    //MARK: -
    //MARK: BookmarksTableViewCell Delegate
    //MARK: -
    
    func bookmarkTableViewCellDidPressRecommendButton(bookmarksTableViewCell: BookmarkTableViewCell) {
        guard let episodeIndexPath = bookmarkTableView.indexPath(for: bookmarksTableViewCell) else { return }
        let episode = episodes[episodeIndexPath.row]
        episode.recommendedChange(completion:  bookmarksTableViewCell.setRecommendedButtonToState)
    }
    
    func bookmarkTableViewCellDidPressPlayPauseButton(bookmarksTableViewCell: BookmarkTableViewCell) {
        guard let episodeIndexPath = bookmarkTableView.indexPath(for: bookmarksTableViewCell), let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let episode = episodes[episodeIndexPath.row]

        appDelegate.showPlayer(animated: true)
        Player.sharedInstance.playEpisode(episode: episode)
        bookmarksTableViewCell.updateWithPlayButtonPress(episode: episode)

        // reset previously playings view
        if let playingIndexPath = currentlyPlayingIndexPath, currentlyPlayingIndexPath != episodeIndexPath, let currentlyPlayingCell = bookmarkTableView.cellForRow(at: playingIndexPath) as? BookmarkTableViewCell {
            let playingEpisode = episodes[playingIndexPath.row]
            currentlyPlayingCell.updateWithPlayButtonPress(episode: playingEpisode)
        }

        // update index path
        currentlyPlayingIndexPath = episodeIndexPath
    }
    
    func bookmarkTableViewCellDidPressMoreActionsButton(bookmarksTableViewCell: BookmarkTableViewCell) {
        guard let indexPath = bookmarkTableView.indexPath(for: bookmarksTableViewCell) else { return }
        let episode = episodes[indexPath.row]
        let option1 = ActionSheetOption(type: .download(selected: episode.isDownloaded), action: nil)
        let option2 = ActionSheetOption(type: .bookmark(selected: episode.isBookmarked), action: {
            let success: (Bool) -> () = { _ in
                self.episodes.remove(at: indexPath.row)
                self.bookmarkTableView.reloadData()
            }
            episode.deleteBookmark(success: success)
        })
        
        var header: ActionSheetHeader?
        
        if let image = bookmarksTableViewCell.episodeImage.image, let title = bookmarksTableViewCell.episodeNameLabel.text, let description = bookmarksTableViewCell.dateTimeLabel.text {
            header = ActionSheetHeader(image: image, title: title, description: description)
        }
        
        let actionSheetViewController = ActionSheetViewController(options: [option1, option2], header: header)
        showActionSheetViewController(actionSheetViewController: actionSheetViewController)
    }
    
    func didPressEmptyStateViewActionItem() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate, let tabBarController = appDelegate.tabBarController else { return }
        tabBarController.programmaticallyPressTabBarButton(atIndex: System.discoverTab) //discover index
    }
    
    func observe(episode: Episode) {
        // reload cell with episode in it
        let i = episodes.index(of: episode)
        if let i = i {
            bookmarkTableView.reloadRows(at: [IndexPath(row: i, section: 0)], with: .none)
        }
    }
    
    func equals(_ observer: CacheEpisodeObserver) -> Bool {
        if let observer = observer as? BookmarkViewController {
            return observer == self
        }
        return false
    }
    
    //MARK
    //MARK - Endpoint Requests
    //MARK
    func emptyStateTableViewHandleRefresh() {
        fetchEpisodes()
    }

    @objc func fetchEpisodes() {
        let endpointRequest = FetchBookmarksEndpointRequest()
        endpointRequest.success = { request in
            guard let newEpisodes = request.processedResponseValue as? [Episode] else { return }
            self.episodes = newEpisodes
            Cache.sharedInstance.add(observer: self, forEpisodes: self.episodes)
            self.bookmarkTableView.reloadData()
            self.bookmarkTableView.endRefreshing()
            self.bookmarkTableView.stopLoadingAnimation()
        }
        endpointRequest.failure = { _ in
            self.bookmarkTableView.endRefreshing()
            self.bookmarkTableView.stopLoadingAnimation()
        }
        System.endpointRequestQueue.addOperation(endpointRequest)
    }
}
