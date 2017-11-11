//
//  SeriesDetailHeaderView.swift
//  Podcast
//
//  Created by Drew Dunne on 2/13/17.
//  Copyright © 2017 Cornell App Development. All rights reserved.
//

import UIKit
import SnapKit

protocol TagsCollectionViewDataSource: class {
    func tagForCollectionViewCell(collectionView: UICollectionView, dataForItemAt index: Int) -> Tag
    func numberOfTags(collectionView: UICollectionView) -> Int
}

protocol SeriesDetailHeaderViewDelegate: class {
    func seriesDetailHeaderViewDidPressSubscribeButton(seriesDetailHeader: SeriesDetailHeaderView)
    func seriesDetailHeaderViewDidPressTagButton(seriesDetailHeader: SeriesDetailHeaderView, index: Int)
    func seriesDetailHeaderViewDidPressMoreTagsButton(seriesDetailHeader: SeriesDetailHeaderView)
    func seriesDetailHeaderViewDidPressSettingsButton(seriesDetailHeader: SeriesDetailHeaderView)
    func seriesDetailHeaderViewDidPressShareButton(seriesDetailHeader: SeriesDetailHeaderView)
}

class SeriesDetailHeaderView: UIView, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    // Constants
    static let minHeight: CGFloat = 328
    static let separatorHeight: CGFloat = 1.0
    static let tagsHeight: CGFloat = 86.0
    
    let separatorHeight: CGFloat = SeriesDetailHeaderView.separatorHeight
    let tagsHeight: CGFloat = SeriesDetailHeaderView.tagsHeight
    let padding: CGFloat = 18.0
    let imageHeight: CGFloat = 80.0
    let subscribeWidth: CGFloat = 120.0
    let subscribeHeight: CGFloat = 34.0
    let subscribeTopOffset: CGFloat = 18.0
    let tagButtonHeight: CGFloat = 34.0
    let tagButtonOuterXPadding: CGFloat = 6.0
    let tagButtonInnerXPadding: CGFloat = 12.0
    let headerViewHeight: CGFloat = 328.5
    let imageViewTopOffset: CGFloat = 24
    let titleLabelTopOffset: CGFloat = 16
    let titleLabelWidth: CGFloat = 259.5
    let titleLabelHeight: CGFloat = 30
    let publisherLabelOffset: CGFloat = 1
    let viewSeparatorHeight: CGFloat = 1
    let viewSeparatorTopOffset: CGFloat = 18
    let viewSeparatorInset: CGFloat = 18
    let tagsViewTopOffset: CGFloat = 19.5
    let tagsViewHeight: CGFloat = 34
    let reuseIdentifier = "Cell"
    let episodeSeparatorHeight: CGFloat = 12
    
    var infoView: UIView!
    var gradientView: GradientView!
    var viewSeparator: UIView!
    var tagsCollectionView: UICollectionView!
    
    // Contain all Series information, not accessible outside, set through series variable
    var backgroundImageView: ImageView!
    var imageView: ImageView!
    var titleLabel: UILabel!
    var publisherLabel: UILabel!
    var subscribeButton: FillNumberButton!
    var settingsButton: UIButton!
    var shareButton: UIButton!
    var episodeSeparator: UIView!
    
    weak var dataSource: TagsCollectionViewDataSource?
    weak var delegate: SeriesDetailHeaderViewDelegate?
        
    init() {
        super.init(frame: .zero)

        infoView = UIView()
        infoView.backgroundColor = .offWhite
        infoView.clipsToBounds = true
        addSubview(infoView)
        
        backgroundImageView = ImageView(frame: CGRect(x: 0.0, y: 0.0, width: 1, height: 1)) //placeholder
        backgroundImageView.contentMode = .scaleAspectFill
        infoView.addSubview(backgroundImageView)

        gradientView = GradientView()
        infoView.addSubview(gradientView)

        imageView = ImageView(frame: CGRect(x: 0.0, y: 0.0, width: imageHeight, height: imageHeight))
        infoView.addSubview(imageView)
        
        titleLabel = UILabel()
        titleLabel.textColor = .offBlack
        titleLabel.font = ._20SemiboldFont()
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 0 // used so autolayout makes it as big as it needs to be
        infoView.addSubview(titleLabel)
        
        publisherLabel = UILabel()
        publisherLabel.font = ._14RegularFont()
        publisherLabel.textColor = .charcoalGrey
        publisherLabel.numberOfLines = 0
        publisherLabel.textAlignment = .center
        infoView.addSubview(publisherLabel)
        
        subscribeButton = FillNumberButton(type: .subscribe)
        subscribeButton.addTarget(self, action: #selector(didPressSubscribeButton), for: .touchUpInside)
        infoView.addSubview(subscribeButton)
        
        shareButton = UIButton(type: .custom)
        shareButton.adjustsImageWhenHighlighted = true
        shareButton.setImage(#imageLiteral(resourceName: "shareButton"), for: .normal)
        shareButton.addTarget(self, action: #selector(shareWasPressed), for: .touchUpInside)
        
        tagsCollectionView = UICollectionView(frame: .zero, collectionViewLayout: RecommendedTagsCollectionViewFlowLayout())
        tagsCollectionView.delegate = self
        tagsCollectionView.dataSource = self
        tagsCollectionView.register(RecommendedTagsCollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        tagsCollectionView.showsHorizontalScrollIndicator = false
        tagsCollectionView.backgroundColor = .clear
        infoView.addSubview(tagsCollectionView)
        
        viewSeparator = UIView()
        viewSeparator.backgroundColor = .paleGrey
        infoView.addSubview(viewSeparator)
        
        episodeSeparator = UIView()
        episodeSeparator.backgroundColor = .paleGrey
        infoView.addSubview(episodeSeparator)
        
        infoView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        backgroundImageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        imageView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(imageViewTopOffset)
            make.size.equalTo(imageHeight)
        }

        gradientView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        titleLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(imageView.snp.bottom).offset(titleLabelTopOffset)
            make.leading.trailing.equalToSuperview().inset(padding)
        }
        
        publisherLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(titleLabel.snp.bottom).offset(publisherLabelOffset)
            make.leading.trailing.equalToSuperview().inset(padding)
        }
        
        subscribeButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(publisherLabel.snp.bottom).offset(subscribeTopOffset)
            make.width.equalTo(subscribeWidth)
            make.height.equalTo(subscribeHeight)
        }
        
        viewSeparator.snp.makeConstraints { make in
            make.height.equalTo(viewSeparatorHeight)
            make.leading.lessThanOrEqualToSuperview().offset(viewSeparatorInset)
            make.trailing.lessThanOrEqualToSuperview().inset(viewSeparatorInset)
            make.top.equalTo(subscribeButton.snp.bottom).offset(viewSeparatorTopOffset)
        }

        tagsCollectionView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(tagsViewHeight)
            make.top.equalTo(viewSeparator.snp.bottom).offset(tagsViewTopOffset)
        }
        
        episodeSeparator.snp.makeConstraints { make in
            make.height.equalTo(episodeSeparatorHeight)
            make.leading.trailing.equalToSuperview()
            make.top.equalTo(tagsCollectionView.snp.bottom).offset(tagsViewTopOffset)
            make.bottom.equalToSuperview()
        }
        
        infoView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setSeries(series: Series) {
        titleLabel.text = series.title
        publisherLabel.text = series.author
        tagsCollectionView.reloadData()
        subscribeButtonChangeState(isSelected: series.isSubscribed, numberOfSubscribers: series.numberOfSubscribers)
        imageView.setImageAsynchronouslyWithDefaultImage(url: series.largeArtworkImageURL, defaultImage: #imageLiteral(resourceName: "nullSeries"))
        backgroundImageView.setImageAsynchronouslyWithDefaultImage(url: series.largeArtworkImageURL)
    }
    
    // MARK: - CollectionView
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        delegate?.seriesDetailHeaderViewDidPressTagButton(seriesDetailHeader: self, index: indexPath.row)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataSource?.numberOfTags(collectionView: collectionView) ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as? RecommendedTagsCollectionViewCell,
            let tag = dataSource?.tagForCollectionViewCell(collectionView: collectionView, dataForItemAt: indexPath.row) else { return UICollectionViewCell() }
        cell.setup(with: tag, fontColor: .charcoalGrey)
        return cell
    }

    // MARK: - SeriesDetailHeaderViewDelegate
    
    @objc func tagButtonPressed(button: FillButton) {
        delegate?.seriesDetailHeaderViewDidPressTagButton(seriesDetailHeader: self, index: button.tag)
    }
    
    func moreTagsPressed() {
        delegate?.seriesDetailHeaderViewDidPressMoreTagsButton(seriesDetailHeader: self)
    }
    
    @objc func didPressSubscribeButton() {
        delegate?.seriesDetailHeaderViewDidPressSubscribeButton(seriesDetailHeader: self)
    }
    
    func subscribeButtonChangeState(isSelected: Bool, numberOfSubscribers: Int) {
        subscribeButton.setupWithNumber(isSelected: isSelected, numberOf: numberOfSubscribers)
    }
    
    @objc func settingsWasPressed() {
        delegate?.seriesDetailHeaderViewDidPressSettingsButton(seriesDetailHeader: self)
    }
    
    @objc func shareWasPressed() {
        delegate?.seriesDetailHeaderViewDidPressShareButton(seriesDetailHeader: self)
    }
    
}
