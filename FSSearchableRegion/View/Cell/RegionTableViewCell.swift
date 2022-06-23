//
// Copyright © 2022 arvinq. All rights reserved.
//
	

import UIKit

class RegionTableViewCell: UITableViewCell {
    static let reuseId = "RegionCell"
    
    lazy var globeImage: UIImageView = {
        let imageView = UIImageView()
        imageView.image = SFSymbols.globe
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    lazy var regionNameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    var regionViewModel: RegionViewModel? {
        didSet { bindValues() }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setupView()
        setupConstraints()
    }
    
    override var isSelected: Bool {
        // Edit the controls in the cell based on the cell's selected state
        didSet {
            self.accessoryType        = isSelected ? .checkmark : .none
            self.globeImage.tintColor = isSelected ? .systemGreen : .systemGray5
            self.regionNameLabel.font = isSelected ? .boldSystemFont(ofSize: Size.fontSize) :
                                                     .systemFont(ofSize: Size.fontSize)
        }
    }
    
    private func setupView() {
        self.selectionStyle = .none
        self.separatorInset = UIEdgeInsets.init(top: 0, left: Space.margin, bottom: 0, right: 0)
        
        addSubview(globeImage)
        addSubview(regionNameLabel)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            globeImage.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            globeImage.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: Space.padding),
            globeImage.widthAnchor.constraint(equalToConstant: Size.globeHeight),
            globeImage.heightAnchor.constraint(equalToConstant: Size.globeHeight),
            
            regionNameLabel.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            regionNameLabel.leadingAnchor.constraint(equalTo: globeImage.trailingAnchor, constant: Space.adjacent)
        ])
    }
    
    // bind values to populate the controls in each of the cell.
    private func bindValues() {
        regionNameLabel.text = regionViewModel?.name
        self.isSelected = regionViewModel?.isSelected ?? false
    }

}
